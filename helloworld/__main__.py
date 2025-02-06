#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""A simple Python example project."""

import argparse
import logging
import os.path
from sys import argv

from helloworld.helloworld import get_periods, greet

#
# MAIN
#
__version__ = "2025.02.07"

parser = argparse.ArgumentParser(
    prog=os.path.basename(argv[0]),
    usage="%(prog)s [options]",
    description="a simple hello world project",
    epilog="© 2019-2025 Frank H Jung mailto:frankhjung@linux.com",
)
parser.add_argument(
    "-l",
    "--log",
    dest="logLevel",
    choices=list(logging.getLevelNamesMapping()),
    help="Set the logging level",
    default="INFO",
)
parser.add_argument("--version", action="version", version=__version__)

# process command line arguments
args = parser.parse_args()

# show command parameters
logging.basicConfig(
    format="%(asctime)s %(message)s", level=getattr(logging, args.logLevel)
)
logger = logging.getLogger()  # use root logger

# show workings
logger.debug("Program name (PROG): %s", parser.prog)
logger.debug("Log level (LOG): %s (%s)", args.logLevel, getattr(logging, args.logLevel))  # noqa: E501
logger.debug("Version (VERSION): %s", __version__)

# run static greeting
logger.info(greet())
logger.info(get_periods("2019-01-01", "2019-01-31"))
