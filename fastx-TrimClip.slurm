#!/bin/bash

#SBATCH --time=48:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=5   # number of nodes
#SBATCH --ntasks-per-node=2   # 1 processor core(s) per node X 2 threads per core
#SBATCH --mem=6400M   # maximum memory per node
#SBATCH --partition=short    # standard node(s)
#SBATCH --job-name="fastx-trim-clip.clip"
#SBATCH --mail-user=jonathan.koch@usda.gov   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output="fastx-trim-clip-%j.out" # job standard output file (%j replaced by job id)
#SBATCH --error="fastx-trim-clip-%j.out" # job standard error file (%j replaced by job id)

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

source ~/.bash_profile
module load fastx/0.0.14

# This script invokes the several fastx tools incluing trimmer, quality trimmer, and clipper. With fastx_trimmer
# the first base is removed which is the poly-N tail (-f 2). Next, with fastq_quality_trimmer we scanned the files 
# and removed bases less than Q20 (-t 20) and trims off bases less than 75 nts (-l 75), which is equal to half of the 150
# nt sequence. Finally, Illumina Universal Adaptor (-a AGATCGGAAGAG) were removed as it was detected in the FastQC report.
# FYI: increasing the number of nodes increases the speed in which the analysis proceeds.

now=$(date)

echo The script started on $now

gzip -d *fastq.gz

echo The .gz files were unizipped on $now

for i in *.fastq;
do
  	echo working with "$i" on $now 
        newfile="$(basename $i .fastq)"
	   fastx_trimmer -f 2 -i $i | fastq_quality_trimmer -Q33 -v -t 20 -l 75 |fastx_clipper -Q33 -l 75 -a AGATCGGAAGAG -n -v > ${newfile}.trimmed.clipped.fastq
done;
