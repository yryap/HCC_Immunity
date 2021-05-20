#!/bin/bash

LINE=$(sed "$1q;d" all_bam_files.txt)
REMOVEDCOMMA=$(echo "$LINE")
arr=($REMOVEDCOMMA)

for i in HLA-A HLA-B HLA-C HLA-DPA1 HLA-DPB1 HLA-DQA1 HLA-DQB1 HLA-DRB1; do /home/yyap2/virus_cancer/tools/hla_scan_r_v2.1.4 -b ${arr[0]} -v 37 -d /home/yyap2/virus_cancer/tools/db/HLA-ALL.IMGT -g $i; done > /home/yyap2/virus_cancer/tools/hla_output/$(basename ${arr[0]} .bam).txt

# Adapted from ASU RC SBATCH scripts
