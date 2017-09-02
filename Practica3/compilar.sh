#!/bin/bash

if [ -z "$3" ];
then
	./Metric-FF/ff -p Entrega1/ -o $1.pddl -f $2.pddl -O -g 1 -h 1
else
./Metric-FF/ff -p $3 -o $1.pddl -f $2.pddl -O -g 1 -h 1
fi
