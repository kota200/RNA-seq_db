diff=${1:?}
uniq ${diff} | sed "s/,/_/g" | sed "s/\t/,/g" | sed "s/ /_/g" > diff_tmp

#output file prefix
out=${2:?}
#Reference genome file, fasta
ref=${3:?}
#Annotation file, gff3
gff=${4:?}


for i in `cat diff_tmp`
do srr=`echo ${i} | awk -F"," '{print $1}'` 
lib=`echo ${i} | awk -F"," '{print $5}'`
name=`echo ${i} | awk -F"," '{print $4}'`
samn=`echo ${i} | awk -F"," '{print $2}'`
bio=`echo ${i} | awk -F"," '{print $3}'`

if [ "${name}" = "" ]; then
name="NA"
fi

python findSAMN_info.py ${samn}
cult=`grep "<SampleData>" SAMN_info_tmp| sed 's/.*display_name="cultivar"&gt;//g' | sed "s/&lt;.*//g" | sed "s/,/_/g"`
if [ "${cult}" = "<SampleData>" ]; then
cult=""
fi

geno=`grep "<SampleData>" SAMN_info_tmp| sed 's/.*display_name="genotype"&gt;//g' | sed "s/&lt;.*//g" | sed "s/,/_/g"`
if [ "${geno}" = "<SampleData>" ]; then
geno=""
fi


tissue=`grep "<SampleData>" SAMN_info_tmp | sed 's/.*display_name="tissue"&gt;//g' | sed "s/&lt.*//g" | sed "s/,/_/g"`
if [ "${tissue}" = "<SampleData>" ]; then
tissue=""
fi

dev_sta=`grep "<SampleData>" SAMN_info_tmp | sed 's/.*display_name="development stage"&gt;//g' | sed "s/&lt;.*//g" | sed "s/,/_/g"`
if [ "${dev_sta}" = "<SampleData>" ]; then
dev_sta=`grep "<SampleData>" SAMN_info_tmp | sed 's/.*display_name="age"&gt;//g' | sed "s/&lt;.*//g" | sed "s/,/_/g"`
if [ "${dev_sta}" = "<SampleData>" ]; then
dev_sta=""
fi
fi

#hisat2-build
hisat2-build ${ref} ref.idx

#Paired-end
if [ "${lib}" = "PAIRED" ]; then
fasterq-dump --split-files -p ${srr} -e 12
fastp -i ${srr}_1.fastq -I ${srr}_2.fastq -o ${name}_R1.fastq -O ${name}_R2.fastq
hisat2 -x ref.idx -1 ${name}_R1.fastq -2 ${name}_R2.fastq -p 16 -S ${name}.sam
samtools sort -O BAM ${name}.sam -o ${name}.bam -@ 16
samtools index ${name}.bam; rm ${name}.sam
rm ${srr}_1.fastq
rm ${srr}_2.fastq
featureCounts -M -p -T 20 -t mRNA -g ID -a ${gff} -o ${name}_counts.txt ${name}.bam

#Single-end
elif [ "${lib}" = "SINGLE" ]; then
  fasterq-dump -p ${srr} -e 12
  fastp -i ${srr}.fastq -o ${name}_R.fastq 
  hisat2 -x ref.idx -U ${name}_R.fastq -S ${name}.sam -p 16
  samtools sort -O BAM ${name}.sam -o ${name}.bam -@ 16
  samtools index ${name}.bam; rm ${name}.sam
  rm ${srr}.fastq
  featureCounts -M -T 20 -t mRNA -g ID -a ${gff} -o ${name}_counts.txt ${name}.bam
else
  break
fi

cut -f1,6 ${name}_counts.txt | grep -v "#" > gene_length.tsv; cut -f7 ${name}_counts.txt | grep -v "#" > ${name}_counts_tmp; cut -f1 ${name}_counts.txt | grep -v "#" > name_tmp
paste name_tmp ${name}_counts_tmp > ${name}_counts_tmp.txt
python Count_to_TPM.py ${name}_counts_tmp.txt gene_length.tsv
cut -f2 ${name}_counts_tmp.txt_with_TPM | sed "s/\.bamTPM//g"  > ${name}_counts_tmp_final

sed -i "s|${name}|${name};${bio};${srr};${samn};cultivar: ${cult};genotype: ${geno};development_stage: ${dev_sta};tissue: ${tissue}|g" ${name}_counts_tmp_final

if [ ! -f ${out}_TPM_matrix.csv ]; then
    touch ${out}_TPM_matrix.csv
    echo "File ${out}_TPM_matrix.csv doesn't exit. Making a new one..."
else
    echo "Updating the file ${out}_TPM_matrix.csv"
fi

paste ${out}_TPM_matrix.csv ${name}_counts_tmp_final | sed "s/\t/,/g" > TPM_matrix_new.csv
mv TPM_matrix_new.csv ${out}_TPM_matrix.csv
rm *fastq
rm *bam
rm *counts.txt
rm ${name}_counts_tmp_final
rm ${name}_counts_tmp
done

