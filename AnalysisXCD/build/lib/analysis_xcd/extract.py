from xml.etree import ElementTree
import pandas as pd
import logging
from collections import defaultdict
from analysis_xcd.plots import prepare_data_plots


# =============================================================================
def parse_xcd_file(list_xcd_files, label_file,
                   label_property=None, avg_time_properties=None):

    """
    Given a list of xcd file names (**list_xcd_files**) containing the **label_file**,
    this function extracts the XY points of the serie
    with name **label_property**. If **label_property** is `None`.

    This function produces two files:
        <label_property>.dat is an ascii file with the data for the files
        <label_property>.gnu a template to plot in GNUPLOT.
        <label_property>.avg a file containing the average values.

    Args:
        list_xcd_files (list): A list with the names of the xcd files to analyze.
        label_file (str): Filter xcd files with this label.
        label_property (str): Property to extract from the xcd files.
        avg_time_properties (list): A list containing the [Initial time, End time, stride] to calculate the averages.


    """

    logger = logging.getLogger("Output")
    data = defaultdict(list)

    # Each ENERGY xcd file in the working directory
    if label_property is None:
        m = "\t\t{} to analyze\n".format(label_file)
    else:
        m = "\t\t{} to analyze ({})\n".format(label_file, label_property)
    m += "\t\t{}\n".format("=" * len(m))

    # Extract points from xcd for each file
    istherefiles = False
    for ifile in list_xcd_files:
        ll = "{}.xcd".format(label_file)
        if ifile.find(ll) != -1:
            m += "\t\t  {0:s}\n".format(ifile)
            istherefiles = True
            if label_property is None:
                # Assume that label_property is equal to label_file
                _, data[ifile] = extract_xy_points_xcd(ifile, property_name=label_file)
                label_property = label_file
            else:
                # Name of the property
                _, data[ifile] = extract_xy_points_xcd(ifile, property_name=label_property)

    if istherefiles:
        print(m) if logger is None else logger.info(m)
        mean_list = calculate_avg(data, avg_time_properties, label_property)
        # Create plots for data
        prepare_data_plots(data, label=label_property, meandata=mean_list)


# =============================================================================
def parse_std_files(list_std_files, label_property, avg_time_properties=None):

    logger = logging.getLogger("Output")
    data = defaultdict(list)

    # Each std file in the working directory
    m = "\t\t{} to analyze from std file\n".format(label_property)
    m += "\t\t{}\n".format("="*len(m))

    istherefiles = False
    for ifile in list_std_files:
        istherefiles = True
        _, data[ifile] = extract_data_xcd(ifile)

    if istherefiles:
        print(m) if logger is None else logger.info(m)


# =============================================================================
def extract_data_xcd(filename_std):

    tree = ElementTree.parse(filename_std)
    root = tree.getroot()

    # Get number of columns and the name of the properties
    name_of_series = []
    for node in root.iter('field'):
        d = node.attrib.get('description')
        if d is not None:
            name_of_series.append(d)

    # Get number of rows
    for node in root.iter('value'):
        d = node.attrib.get("type")
        if d == "I4":
            nrows = node.text

    print(len(name_of_series), nrows)
    print("POR AKI!!!!!!")
    pass
    return None, None



# =============================================================================
def extract_xy_points_xcd(filename_xcd, property_name=None):

    """
    Materials Studio (MS) generates xcd files are a native BIOVIA format for the representation of graphs in MS Viewer.
    The format is XML-based format to codify the data.

    This function takes a xcd file extracting the X,Y points to a list.

    The function has been tested only with the XCD Version="19.1"

    Args:
        filename_xcd (str): Path to the xcd file
        property_name (str): Name of the property to extract

    Returns:
        A string containing the name of the extracted property and a DataFrame with the XY values
        The format of the dataframe is as follows:

            time (ps) Temperature (K)
        0     0.101    156.914
        1     0.202    153.914
        2     0.303    157.914
        ...

    """

    result_list = []
    tree = ElementTree.parse(filename_xcd)
    root = tree.getroot()
    version = root.attrib.get("Version")

    # Check version of the xcd file
    if version != "19.1":
        line = "WARNING: The version xcd version of {} is {}. " \
               "This program only has been tested with version 19.1".format(filename_xcd, version)
        print(line)

    # Extract xy points for the property_name
    for node in root.iter('SERIES_2D'):
        # Name of the data serie, i.e Potential energy, Temperature, ...
        prop = node.attrib.get('Name')
        if prop == property_name:
            for point in node.iter():
                data = point.attrib.get("XY")
                if data is None:
                    continue
                d = data.split(",")
                x = float(d[0])
                y = float(d[1])
                result_list.append([x, y])

    # Extract title of the first and second column
    name_col1 = "X"
    name_col2 = "Y"
    for node in root.iter('AXIS_X'):
        name_col1 = node.attrib.get('Title')
    for node in root.iter('AXIS_Y'):
        name_col2 = node.attrib.get('Title')

    df = pd.DataFrame(result_list, columns=[name_col1, name_col2])
    return property, df


# =============================================================================
def calculate_avg(df_dict, avg_time_properties, label_property):

    logger = logging.getLogger("Output")

    ti = avg_time_properties[0]
    te = avg_time_properties[1]
    stride = avg_time_properties[2]

    means_list = []
    last_value = []
    # For each dataframe in the dictionary
    unit_time = 'ps'
    unit_value = 'kcal/mol'
    npoints = 0
    for key, idf in df_dict.items():
        c1name = idf.columns[0]
        c2name = idf.columns[1]
        s = list(idf.columns)[0]  # Time (ps)
        unit_time = s[s.find("(")+1:s.find(")")]  # Extract ps
        s = list(idf.columns)[1]  # Temperature (K)
        unit_value = s[s.find("(")+1:s.find(")")]  # Extract K
        # Select the case for the interval
        if ti is None and te is None:
            avg_time_properties[0] = idf.iloc[0][0]
            avg_time_properties[1] = idf.iloc[-1][0]
            avg_time_properties[2] = 1
            df_tmp = idf
        elif ti is None and te is not None:
            avg_time_properties[0] = idf.iloc[0][0]
            avg_time_properties[2] = 1
            df_tmp = idf[idf[c1name] <= te]
        elif ti is not None and te is None:
            avg_time_properties[1] = idf.iloc[-1][0]
            avg_time_properties[2] = 1
            df_tmp = idf[idf[c1name] >= ti]
        elif ti is not None and te is not None:
            avg_time_properties[2] = 1
            df_tmp = idf[(idf[c1name] >= ti) & (idf[c1name] <= te)]
        else:
            df_tmp = None

        # Take into account the stride
        if stride is not None and stride > 1:
            df_sel = df_tmp[::stride]
        else:
            df_sel = df_tmp
        npoints = len(df_sel)

        # Mean +- std
        means_list.append([df_sel[c2name].mean(axis=0, skipna=True), df_sel[c2name].std(axis=0, skipna=True)])
        last_value.append(df_tmp[c2name].iloc[-1])

    m = "\t\tAVG {0}({5}): Averaged from {1} {4} to {2} {4} (steps {3} npoints {6} deltat {7:.3f} {4})\n". \
        format(label_property, avg_time_properties[0], avg_time_properties[1], avg_time_properties[2],
               unit_time, unit_value, npoints, (avg_time_properties[1]-avg_time_properties[0])/npoints)
    m += "\t\t{}\n".format("="*len(m))
    i = 1
    for item in means_list:
        m += "\t\t  #Frame {0:04d}: {1:.4f} +- {2:.4f} \n".format(i, item[0], item[1])
        i += 1
    print(m) if logger is None else logger.info(m)

    if label_property.upper() == "DENSITY":
        m = "\t\tLAST VALUE {0}({2}) at {3:.3f}{1}: \n". \
            format(label_property, unit_time, unit_value, df_tmp[c1name].iloc[-1])
        m += "\t\t{}\n".format("="*len(m))
        i = 1
        for item in last_value:
            m += "\t\t  #Frame {0:04d}: {1:.4f} \n".format(i, item)
            i += 1
        print(m) if logger is None else logger.info(m)

    del df_tmp
    return means_list


# =============================================================================
def check_xcd_file(filename_xcd):

    """
    Materials Studio (MS) generates xcd files are a native BIOVIA format for the representation of graphs in MS Viewer.
    The format is XML-based format to codify the data.

    This function checks the ....

    Args:
        filename_xcd (str): Path to the xcd file

    """
    tree = ElementTree.parse(filename_xcd)
    root = tree.getroot()
    version = root.attrib.get("Version")

    # Check version of the xcd file
    if version != "19.1":
        line = "WARNING: The version xcd version of {} is {}. " \
               "This program only has been tested with version 19.1".format(filename_xcd, version)
        print(line)

    # Extract xy points for the property_name
    name_of_series = []
    tini = []
    tend = []
    deltat = []
    npoints = []
    for node in root.iter('SERIES_2D'):
        name_of_series.append(node.attrib.get('Name'))
        list_points = []
        for item in node.iter('POINT_2D'):
            list_points.append(item.attrib.get("XY"))
        npoints.append(len(list_points))
        tini.append(float(list_points[0].split(",")[0]))
        tend.append(float(list_points[-1].split(",")[0]))
        deltat.append((tend[-1]-tini[-1])/npoints[-1])

    time_unit = 'ps'
    for node in root.iter('AXIS_X'):
        name_col1 = node.attrib.get('Title')
        time_unit = name_col1.split("(")[-1][0:-1]

    # Write results
    print("------ Check file {} ------".format(filename_xcd))
    print("\tNumber of series = {}".format(len(name_of_series)))
    for i in range(len(name_of_series)):
        print("\t Serie {}: {}".format(i+1, name_of_series[i]))
        print("\t\t\tNumber of points = {0:d}, "
              "Initial time = {1:.3f} {4:s}, "
              "Finish time = {2:.3f} {4:s}, "
              "Delta time = {3:.3f} {4:s}".format(npoints[i], tini[i], tend[i], deltat[i], time_unit))


# =============================================================================
def check_std_file(filename_std):

    tree = ElementTree.parse(filename_std)
    root = tree.getroot()

    name_of_series = []
    for node in root.iter('field'):
        d = node.attrib.get('description')
        if d is not None:
            name_of_series.append(d)

    for node in root.iter('value'):
        d = node.attrib.get("type")
        if d == "I4":
            last_frame = node.text

    i = 1
    print("------ Check file {} ------".format(filename_std))
    print("\tNumber of series = {}".format(len(name_of_series)))
    print("\tNumber of rows = {}".format(last_frame))
    for item in name_of_series:
        print("\t\tColumn {0:03d}: {1}".format(i, item))
        i += 1
