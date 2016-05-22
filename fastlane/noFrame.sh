#!/bin/sh

shopt -s extglob

cd screenshots
cd en-US

find ./ ! -name "*_framed.png" -a ! -name "*.strings" -exec rm -f {} \;
