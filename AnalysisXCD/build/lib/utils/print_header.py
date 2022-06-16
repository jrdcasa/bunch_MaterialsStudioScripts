# =============================================================================
def print_header(logger=None):
    msg = """
        ***********************************************************************
                   Analyze XTC files from Materials Studio (AnaXTC)
                   ------------------------------------------------

                                    Version 0.1

                                  Dr. Javier Ramos
                          Macromolecular Physics Department
                    Instituto de Estructura de la Materia (IEM-CSIC)
                                   Madrid (Spain)

                AnaXTC is an open-source python library to analyze several XTC
                files produced by Materials Studio at the same time.

                This software is distributed under the terms of the
                GNU General Public License v3.0 (GNU GPLv3). A copy of 
                the license (LICENSE.txt) is included with this distribution. 

        ***********************************************************************

        """

    print(msg) if logger is None else logger.info(msg)


# =============================================================================
def print_header_std(logger=None):
    msg = """
        ***********************************************************************
                   Analyze STD files from Materials Studio (AnaSTD)
                   ------------------------------------------------

                                    Version 0.1

                                  Dr. Javier Ramos
                          Macromolecular Physics Department
                    Instituto de Estructura de la Materia (IEM-CSIC)
                                   Madrid (Spain)

                AnaSTD is an open-source python library to analyze several STD
                files produced by Materials Studio at the same time. The STD files 
                contain a table in a XML-based format.

                This software is distributed under the terms of the
                GNU General Public License v3.0 (GNU GPLv3). A copy of 
                the license (LICENSE.txt) is included with this distribution. 

        ***********************************************************************

        """

    print(msg) if logger is None else logger.info(msg)


# =============================================================================
def print_usage(logger=None):

    msg = "python analysisxcd => Without arguments, the calcualtions are done on the " \
          "XCD files in the working directory\n"
    print(msg) if logger is None else logger.info(msg)


# =============================================================================
def print_usage_std(logger=None):

    msg = "python analysisstd => Without arguments, the calcualtions are done on the " \
          "STD files in the working directory\n"
    print(msg) if logger is None else logger.info(msg)