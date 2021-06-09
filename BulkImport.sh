#!/bin/bash

#import configuration variables
base_file_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
config_file="$base_file_path/config.sh"
source $config_file

to_import_file="$1"
temporary_file=/tmp/temporary.jrnl

original_dir=$(pwd)
newdir=$(dirname $to_import_file)
to_import_file=$(basename $to_import_file)
cd $newdir

unset LEDGER_STRICT
touch $temporary_file

while read line
do
	eval "${path_to_wd}HLedgerImport.sh $line >> $temporary_file"
done < $to_import_file

ledger -f $temporary_file --sort date print | sed 's/\(     \$\)/          \1/'
#this sed statement aligns all amounts to match ledger-mode-align-txn
rm $temporary_file
export LEDGER_STRICT=true

cd $original_dir
