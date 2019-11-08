#!/bin/bash
salloc --nodelist=hype1,hype2,hype3,hype4 -J JOB -t 72:00:00

ssh hype1 '$HOME/SMPE_1920/BATCH/./nas.batch'