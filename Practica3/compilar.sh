#!/bin/bash

if [ -z "$3" ];
then
	./Metric-FF/ff -p EjemplosSesion1/ -o $1.pddl -f $2.pddl
else
./Metric-FF/ff -p $3 -o $1.pddl -f $2.pddl
fi
