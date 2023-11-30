#!/bin/bash
# Redirecting output to different locations.

exec 2> testerror

echo "This is start of the script."
echo "now redirecting all output to another location."

exec 1> testout

echo "This output should go to the testout file."
echo "but this should go to testerror file" >&2