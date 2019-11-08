#!/bin/bash
salloc -p hype -N 4 -J JOB -t 72:00:00

./nas.batch