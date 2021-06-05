#!/bin/bash

# path to current ledger file
ledger_file=~/Desktop/hledger-import-script/sample-ledger-data/sample-ledger-data/ledger.journal

#path to data tree
path_to_finances=~/Desktop/hledger-import-script/sample-ledger-data/sample-ledger-data/data/


# NameOfAcct,    hledger rules file, data pre-processing script
accounts_array=(
  "sample-bank,  sample.csv.rules,                    "
)


###########################################################
#####          DO NOT EDIT BELOW THIS LINE!!          #####
###########################################################

#forget any previously defined arrays
unset acct_names
unset rules_files
unset pre_process_scripts

#declare three arrays
declare -a acct_names
declare -a rules_files
declare -a pre_process_scripts

#iterate through $accounts_array to fill these arrays
i=0
while [ $i -lt ${#accounts_array[*]} ]
do
  acct_names[$i]=$(echo ${accounts_array[i]} | awk -F, '{print $1}')
  rules_files[$i]=$(echo ${accounts_array[i]} | awk -F, '{print $2}')
  pre_process_scripts[$i]=$(echo ${accounts_array[i]} | awk -F, '{print $3}')
  ((i++))
done

