**HLA Typing**

Tool: [SyntekabioTools/HLAscan](https://github.com/SyntekabioTools/HLAscan), version 2.1.4

Data source: TCGA LIHC dataset accessed through dbGaP

**Steps to run HLAscan on cluster:**
1. Follow the insructions on HLAscan Github to download the software to working directory
2. Locate the directory of TCGA LIHC BAM files and compile the names (complete with directory) of all BAM files into a document titled all_bam_files.txt
3. Create a bash shell script by adapting the commands from tool manual to include the HLA genes desired
4. Create SBATCH script with input from all_bam_files.txt
5. Create an output folder to store the HLA for each file, eg. hla_output
