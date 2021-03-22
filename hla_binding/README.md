# HLA Binding

## Purpose: Test binding affinity of HBV peptides to HLA

### Source 
**HBV Reference Sequences:**

HBV reference sequences are downloaded from HBVdb
```
wget https://hbvdb.lyon.inserm.fr/data/references/hbvdbr.fas
```

Note: HBVdb recognizes 8 genotypes of HBV (A-H), and each genotype has 2 reference sequences, so in total we have 16 sequences. 

**HLA alleles:**
Class I and Class II 
```
wget http://www.cbs.dtu.dk/services/NetMHCpan/MHC_allele_names.txt
wget https://services.healthtech.dtu.dk/services/NetMHCIIpan-4.0/alleles_name.list
```

### Bash setup
(Optional) Nucleotide to Amino acid Conversion
```
conda install emboss
transeq -sequence input -outseq output 
```

(Optional) Peptide Generation
```
git clone https://github.com/lasersonlab/pepsyn.git     
python setup.py install 
pepsyn tile -l 9 -p 8 hbv_protein.fa class_i_hbv_peptide.fa       
```

MHC I Prediction Tool: netMHCpan4.1

Request access from https://services.healthtech.dtu.dk/cgi-bin/sw_request.
Follow the instructions in the email link to download the package.

Untar package: 
```
tar -zxvf netMHCpan-4.1.<unix>.tar.gz
```
Install the package following the instructions from netMHCpan-4.1.readme
Run tests listed in the netMHCpan-4.1.readme to make sure the program works correctly

Note: netMHCpan4.1 can be run locally or on the cluster. If using Agave, the setup is the same on Agave as you would do locally. 

### Binding Prediction
**Run locally:** 
Only recommended if you do not have access to the cluster and only need to test binding to a small number of alleles 
```
cat <file_with_alleles>.txt | xargs -I{} sh -c '<directory_with_program>/netMHCpan -f <protein_sequence>.fa -BA -xls -a {} -xlsfile {}.xls'
```

xargs will take each line from the <file_with_alleles>.txt and use that as input. {} is a placeholder 

**Run on cluster:**
Recommended if you need to test binding to a large number of alleles.

File 1: hla_class_i_binding.sh
```
#!/bin/bash  
LINE=$(sed "$1q;d" <file_with_alleles>.txt)                                                                          
ALLELE=$(echo "$LINE")
arr=($ALLELE)    
<directory_with_program>/netMHCpan -f <protein_sequence>.fa -BA -xls -a ${arr[0]} -xlsfile <output_directory>/${arr[0]}.xls 
```

File 2: jobarray.sh
```
#!/bin/bash
#SBATCH --job-name=test_binding
#SBATCH --array=1-total_number   #number of total jobs to spawn, set to total number of lines in the hla class i allele file, there is an upper limit, can request HPC to increase limit temporarily 
#SBATCH --time=0-00:30 #upper bound time limit for job to finish, set to 30min 
#SBATCH --output <results_directory>binding.%j.out        
#SBATCH --error <error_directory>/binding.%j.err                                                        
#SBATCH --mail-type=ALL # Send email when job starts, stops, and fails                                             
#SBATCH --mail-user=<ASURITE@asu.edu>                                                                                                                                                                                                           

module purge
srun -n 1 hla_class_i_binding.sh $SLURM_ARRAY_TASK_ID                                                                                                                                                                                      
```

To submit jobs on Agave
```
sbatch jobarry.sh
```

### Process Output files
Rename all output files in the directory that contain colon in the name: 
```
rename 's|:|-|g' *
```
