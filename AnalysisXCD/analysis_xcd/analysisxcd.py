import glob
import argparse
from collections import defaultdict
from analysis_xcd.extract import parse_xcd_file, check_xcd_file
import utils
import datetime
import os

DATE = "20-Aug-2021"
VERSION = "0.1"
AUTHOR = "Javier Ramos"
GITHUB = "https://github.com/jrdcasa"


# =============================================================================
def parse_arguments():

    """
    Parse arguments of the CLI
    """

    # Create the parser
    cli_parser = argparse.ArgumentParser(description='Help to analysisxcd program.')
    group1 = cli_parser.add_mutually_exclusive_group()
    group1.add_argument("--usage", "-u", help="Print help and exit", action='store_true', default=False)
    group1.add_argument("--version", "-v", help="Version of the program", action='store_true', default=False)
    group2 = cli_parser.add_mutually_exclusive_group()
    group2.add_argument("--check", "-c", help="Give information of the XTD file", action='store',
                        default=False, metavar='<XTD file name>')
    group3 = cli_parser.add_mutually_exclusive_group()
    group3.add_argument("--tini", "-i", help="Initial time for the averages", action='store',
                        default=False, metavar='Initial time')
    group4 = cli_parser.add_mutually_exclusive_group()
    group4.add_argument("--tend", "-e", help="End time for the averages", action='store',
                        default=False, metavar='End time')
    group4 = cli_parser.add_mutually_exclusive_group()
    group4.add_argument("--stride", "-s", help="Interval between frames for the averages (default 1)", action='store',
                        default=False, metavar='Interval time')
    group5 = cli_parser.add_mutually_exclusive_group()
    group5.add_argument("--path", "-p", help="Path for the files to analyze (default ./)", action='store',
                        default=False, metavar='Path')
    group6 = cli_parser.add_mutually_exclusive_group()
    group6.add_argument("--template", "-t", help="Template or pattern for the files to analyze (default *.xtc)", action='store',
                        default=False, metavar='Path')

    args = cli_parser.parse_args()

    if args.usage:
        utils.print_header()
        utils.print_usage()
        exit()

    if args.version:
        print('analysisxcd version: {} ({})'.format(VERSION, DATE))
        exit()

    if args.check:
        check_xcd_file(args.check)
        exit()

    return args


# =============================================================================
if __name__ == "__main__":

    # Parse Arguments
    arg = parse_arguments()

    # Create a logger to make reports.
    logger = utils.init_logger("Output", fileoutput="Output.log", append=False, inscreen=True)
    utils.print_header(logger)
    now = datetime.datetime.now().strftime("%d-%m-%Y %H:%M:%S")
    logger.info("\t\t*** Started: \t {} ***\n".format(now))

    tini = None
    tend = None
    tstride = None
    if arg.tini:
        tini = float(arg.tini)
    if arg.tend:
        tend = float(arg.tend)
    if arg.stride:
        tstride = int(arg.stride)
    avg_time_parameters = [tini, tend, tstride]

    if arg.path:
        input_path = arg.path
    else:
        input_path = os.getcwd()

    if arg.template:
        pattern = arg.template
    else:
        pattern = "*.xcd"

    m = "\t\tInput files in {}/\n".format(input_path)
    print(m) if logger is None else logger.info(m)

    # List of xcd files.
    lf = sorted(glob.glob(os.path.join(input_path, pattern)))

    if len(lf) == 0:
        m = "\t\tThere is not files to be processed\n"
        print(m) if logger is None else logger.info(m)

    # The data structure will a dictionary in which the key is the name of the file and the values
    # a list of points [X, Y]. Example:
    #   e_pot['01-NVT_Frame_001 Energies.xcd'] = [[X0, Y0], [X1, Y1], [X2, Y2] ..., [Xn-1, Y[n-1]]
    e_pot = defaultdict(list)
    e_nb = defaultdict(list)
    temp = defaultdict(list)

    parse_xcd_file(lf, "Energies", label_property="Potential energy", avg_time_properties=avg_time_parameters)
    parse_xcd_file(lf, "Energies", label_property="Non-bond energy", avg_time_properties=avg_time_parameters)
    parse_xcd_file(lf, "Temperature", avg_time_properties=avg_time_parameters)
    parse_xcd_file(lf, "Density", avg_time_properties=avg_time_parameters)

    now = datetime.datetime.now().strftime("%d-%m-%Y %H:%M:%S")
    logger.info("\t\t*** Finished: \t {} ***\n".format(now))
