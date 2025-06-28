
#以下の処理を毎日定時に行うようにする。
#crontab -e
#00 08 20 * * cd ~/PM_DB; API_to_mapping_script.sh

python ~/PM_DB/API_PM_transcriptome.py
#SRAから得られたサンプル情報が入ったXMLファイル（tmp）を整形する
grep -e "Runs" -e "ExpXml" tmp  | sed -z 's/\n<Item Name="Runs" Type="String">//g' | grep -e "Cenchrus americanus" -e "Pennisetum" > tmp_2
sed "s/.*Run acc=//g" tmp_2 | cut -f2 -d '"' > SRR_list_tmp
sed "s/.*;Biosample&gt;//g" tmp_2 | cut -f1 -d "&" > biosample_list_tmp
sed "s/.*;Bioproject&gt;//g" tmp_2 | cut -f1 -d "&" >PRJNA_list_tmp
sed 's/.*Experiment acc=//g' tmp_2 | cut -f8 -d'"' > sample_name_list_tmp
sed "s/.*&lt;LIBRARY_LAYOUT&gt; &lt;//g" tmp_2 | cut -f1 -d " " | cut -f1 -d "/" > Library_type_list_tmp
#list_tmpに、SRR, SAMN, PRJNA, sample名, library typeが入ったタブ区切りのファイルが完成する
paste SRR_list_tmp biosample_list_tmp PRJNA_list_tmp sample_name_list_tmp Library_type_list_tmp | sort > tmp_list
rm *_tmp
cut -f1 tmp_list | sort | uniq > SRR_list_tmp
head -n1 PM_TPM_matrix.csv | cut -f2- -d "," | sed "s/;/\n/g" | grep SRR | sort | uniq > SRR_list

#既存のSRR_listと比較して、もし既存のものに該当しなければ、マッピング・カウントの処理を行う。
#既存のものと違いがない→rm *tmp*。既存のものと違いがある→違いのあるリストをlist_tmpから抽出
if cmp -s ~/PM_DB/SRR_list SRR_list_tmp; then echo "Files are identical."; mv SRR_list_tmp SRR_list; else echo "Files are different"; diff SRR_list SRR_list_tmp > SRR_diff_list;  grep SRR SRR_diff_list | cut -f2 -d " " > SRR_diff_mod; mv SRR_diff_mod SRR_diff_list; for i in `cat SRR_diff_list`; do grep -w ${i} tmp_list >> diff_list; done; ~/PM_DB/mapping_script.sh diff_list; mv SRR_list_tmp SRR_list; fi

rm *tmp*
rm diff_list
rm SRR_diff_list
