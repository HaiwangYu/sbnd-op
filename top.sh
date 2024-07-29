#/bin/env bash

#while sleep 1; do  ps -C $1 -o pcpu= -o pmem= -o nlwp=; done;
#while sleep 1; do top -b -n 1 | awk '/wire-cell/ {print $9,$10}'; done;

while sleep 0.1; do top -u yuhw -b -n 1 | awk -v pattern="$1" '$0 ~ pattern {print $9,$10}' | head -1; done;
#while sleep 0.25; do top -b -n 1 | awk -v pattern="$1" '$0 ~ pattern {print $9,$10}' ; done;
