# RNA-seq_db

This is a program to make an RNA-seq database on a specific organism.
This program requires Python3 (https://www.python.org/), HISAT2 (https://daehwankimlab.github.io/hisat2/), SAMtools (https://www.htslib.org/) and featureCounts (https://subread.sourceforge.net/featureCounts.html).

Usage
````
./RNA-seq_db.sh [organism name] [output file prefix] [reference genome fasta format] [annotation file gff3 format]
````
You can get the TPM matrix for all samples and genes. 
The output file is {output file prefix}_TPM_matrix.csv.

If you have any questions, please contact me: kk-120[at sign]g.ecc.u-tokyo.ac.jp
