#!/bin/bash

# Run fortran's statis extracting code followed by the
# python formatting one.

STATIS_extract.x
STATIS_extract_formatter.py

exit 0
