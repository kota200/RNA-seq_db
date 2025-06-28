#$1 is the organism name; $2 is the output prefix; $3 is the reference genome file; $4 is the annotation file in the gff3 format.
organism_name=${1:?}
out=${2:?}
ref=${3:?}
gff=${4:?}

echo "This is a program to make an RNA-seq database using NCBI SRA databse (https://www.ncbi.nlm.nih.gov/sra)."
echo ""
echo ""
echo "Getting information from NCBI SRA..."
echo ""

python API_RNA-seq.py ${organism_name} &> log

grep -e "Runs" -e "ExpXml" tmp  | sed -z 's/\n<Item Name="Runs" Type="String">//g' | grep -e ${organism_name} > tmp_2
sed "s/.*Run acc=//g" tmp_2 | cut -f2 -d '"' > SRR_list_tmp
sed "s/.*;Biosample&gt;//g" tmp_2 | cut -f1 -d "&" > biosample_list_tmp
sed "s/.*;Bioproject&gt;//g" tmp_2 | cut -f1 -d "&" >PRJNA_list_tmp
sed 's/.*Experiment acc=//g' tmp_2 | cut -f8 -d'"' > sample_name_list_tmp
sed "s/.*&lt;LIBRARY_LAYOUT&gt; &lt;//g" tmp_2 | cut -f1 -d " " | cut -f1 -d "/" > Library_type_list_tmp

paste SRR_list_tmp biosample_list_tmp PRJNA_list_tmp sample_name_list_tmp Library_type_list_tmp | sort > tmp_list
rm *_tmp
cut -f1 tmp_list | sort | uniq > SRR_list_tmp

echo "Now downloading the raw data files and mapping them to the reference genome. This may take several weeks..."
if [ ! -f ${out}_TPM_matrix.csv ]; then
    touch ${out}_TPM_matrix.csv
    echo "File ${out}_TPM_matrix.csv doesn't exit. Making a new one..."
    mapping_script.sh tmp_list ${out} ${ref} ${gff} &> mapping_log
else
    echo "Updating the file ${out}_TPM_matrix.csv"
    head -n1 ${out}_TPM_matrix.csv | cut -f2- -d "," | sed "s/;/\n/g" | grep SRR | sort | uniq > SRR_list
    if cmp -s SRR_list SRR_list_tmp
      then echo "Files are up to date. Nothing to do."; mv SRR_list_tmp SRR_list
      else echo "Files are different"; diff SRR_list SRR_list_tmp > SRR_diff_list;  grep SRR SRR_diff_list | cut -f2 -d " " > SRR_diff_mod; mv SRR_diff_mod SRR_diff_list
        for i in `cat SRR_diff_list`; do grep -w ${i} tmp_list >> diff_list; done
        mapping_script.sh diff_list ${out} ${ref} ${gff}; mv SRR_list_tmp SRR_list &> mapping_log
    fi
fi


rm *tmp*
rm diff_list
rm SRR_diff_list
