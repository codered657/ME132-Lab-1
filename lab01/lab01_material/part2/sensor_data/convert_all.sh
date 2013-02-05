#!/bin/bash
set -e
set -x

for a in example_*png; do
	python ./convert_to_matlab.py $a
done
	