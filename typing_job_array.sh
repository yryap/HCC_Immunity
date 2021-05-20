#!/bin/bash

#SBATCH --job-name=hla_typing
#SBATCH --array=1-790  #number of total jobs to spawn, set to total number of lines in the all_bam_files.txt
#SBATCH --time=0-00:15 #upper bound time limit for job to finish, set to 15min
#SBATCH -o /home/yyap2/virus_cancer/tools/temp/typing_slurm.%j.out
#SBATCH -e /home/yyap2/virus_cancer/tools/temp/typing_slurm.%j.err
#SBATCH --mail-type=ALL # Send email when job starts, stops, and fails
#SBATCH --mail-user=yyap2@asu.edu

module purge

srun -n 1 array_hla_typing.sh $SLURM_ARRAY_TASK_ID

# script will spawn 790 separate instance of the hla_typing.sh
# all jobs are independently able to run and order of completion of each sub-job is not important
