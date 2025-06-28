#!/bin/bash
organism_name=${1:?}
output_prefix=${2:?}
ref=${3:?}
gff=${4:?}

echo "Start fetching..."
./API_to_mapping_script.sh ${organism_name}

echo "Start mapping..."
./mapping_script.sh ${output_prefix} ${ref} ${gff}
