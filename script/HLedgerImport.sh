#!/bin/bash

#this script takes two arguments, the file to be imported and the account name
import_file="$1"
account="$2"
base_file_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

#import configuration variables
config_file="$base_file_path/config.sh"
source $config_file

function run_hledger() {
  file_to_import=$1
  file_for_rules="$base_file_path/hledger-rules/$2"
  hledger -f $file_to_import --rules-file=$file_for_rules print | sed 's/   \(\$-*\)\([0-9]\)\([0-9]\{3\}\)/  \1\2\,\3/'
  #the sed expression matches and four digit amount ($####), puts in comma separators ($#,###), and realigns
}

function pre_process() {
  csv_file=$1
  rules_file_to_pass=$2
  pre_process_script="$base_file_path/pre-process-scripts/$3"
  temporary_file=/tmp/temporary_ledger.csv

  #run the pre-process script on the file and save to temporary location
  eval_string="$pre_process_script $csv_file > $temporary_file"
  eval $eval_string

  #run hledger on the temporary file, then clean up
  run_hledger $temporary_file $rules_file_to_pass
  rm $temporary_file 
}

if [ "$import_file" = 'runledger' ]; then
  ledger -f $ledger_file
  exit
fi

if [ "$import_file" = 'help' ]; then
  echo "USAGE: $0 import_file account"
  echo "accounts:		citi, oldnatl-check, oldnatl-sav, lcb-e, lcb, capone"
  exit
fi

# iterate through $acct_names array 

i=0
while [ $i -lt ${#acct_names[*]} ]
do
  if [ "$account" = ${acct_names[$i]} ]; then
    if [ -z ${pre_process_scripts[$i]} ]; then
      #if there is no pre-process script, just run_hledger()
      run_hledger $import_file ${rules_files[$i]}
    else
      #otherwise, pre-process
      pre_process $import_file ${rules_files[$i]} ${pre_process_scripts[$i]}
    fi
    exit
  fi
  ((i++))
done
