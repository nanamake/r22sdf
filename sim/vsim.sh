#!/bin/sh -x

vsim TB \
    -c \
    -do vsim.do \
    -l vsim.log \
    +nowarnTSCALE
