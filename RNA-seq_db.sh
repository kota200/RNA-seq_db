#!/bin/bash
organism_name=${1:?}
ref=${2:?}
gff=${3:?}
output_prefix=${4:?}

echo "Start fetching..."
./API_to_mapping_script.sh ${organism_name}

echo "Start mapping..."
./mapping_script.sh  ${ref} ${gff} ${output_prefix}
