organism_name=${1}

python API_PM_transcriptome.py ${organism_name}

grep -e "Runs" -e "ExpXml" tmp  | sed -z 's/\n<Item Name="Runs" Type="String">//g' | grep -e ${organism_name} > tmp_2
sed "s/.*Run acc=//g" tmp_2 | cut -f2 -d '"' > SRR_list_tmp
sed "s/.*;Biosample&gt;//g" tmp_2 | cut -f1 -d "&" > biosample_list_tmp
sed "s/.*;Bioproject&gt;//g" tmp_2 | cut -f1 -d "&" >PRJNA_list_tmp
sed 's/.*Experiment acc=//g' tmp_2 | cut -f8 -d'"' > sample_name_list_tmp
sed "s/.*&lt;LIBRARY_LAYOUT&gt; &lt;//g" tmp_2 | cut -f1 -d " " | cut -f1 -d "/" > Library_type_list_tmp

paste SRR_list_tmp biosample_list_tmp PRJNA_list_tmp sample_name_list_tmp Library_type_list_tmp | sort > tmp_list
rm *_tmp
cut -f1 tmp_list | sort | uniq > SRR_list_tmp
head -n1 PM_TPM_matrix.csv | cut -f2- -d "," | sed "s/;/\n/g" | grep SRR | sort | uniq > SRR_list

if cmp -s ~/PM_DB/SRR_list SRR_list_tmp; then echo "Files are identical."; mv SRR_list_tmp SRR_list; else echo "Files are different"; diff SRR_list SRR_list_tmp > SRR_diff_list;  grep SRR SRR_diff_list | cut -f2 -d " " > SRR_diff_mod; mv SRR_diff_mod SRR_diff_list; for i in `cat SRR_diff_list`; do grep -w ${i} tmp_list >> diff_list; done; ~/PM_DB/mapping_script.sh diff_list; mv SRR_list_tmp SRR_list; fi

rm *tmp*
rm diff_list
rm SRR_diff_list
