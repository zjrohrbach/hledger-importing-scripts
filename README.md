About
=====

I use [Ledger](https://www.ledger-cli.org) and [HLedger](https://www.hledger.org) to track family finances.  I use these scripts to help me do these two things:

1. Organize `csv` transaction data and `pdf` statements from my financial institutions using `DownloadingFiles.sh`.
2. Import `csv` transaction data into a ledger file using `HLedgerImport.sh` and `BulkImport.sh`

All the legwork is being done by the [csv importing functionality](https://hledger.org/import-csv.html) of `hledger print`.

This project is a re-implementation of some of the scripts at <https://github.com/zjrohrbach/financialscripts> in order to make them more portable.

Configuration
=============

1. These scripts assume that you have a ledger journal and a data directory set up as below.  A sample setup is provided in the `sample-ledger-data` directory.
~~~
  data/ 
    |
    +---01 (for January data)
    |
    +---02 (for February data)
    |
    .
    .
    .
    |
    +---12 (for December data)
~~~
2. Set the paths to `$ledger_file` and `$path_to_finances` appropriately in `config.sh`
3. Fill in the `$accounts_array` in `config.sh` to include all accounts you want to organize in your `data/` directory.  
    - All accounts must have a name.
    - Any acccount that you want to be able to use with `HLedgerImport.sh` or `config.sh` needs to have an associated rules file in `script/hledger-rules`.  (For illustration purposes, I've included the sample files from the [HLedger Repository](https://github.com/simonmichael/hledger/tree/master/examples/csv), but in practice these should be customized for your use-case.)  If you have no rules file, this field can be blank, but make sure to include a comma.
    - Sometimes a bank's csv export format is too complicted for HLedger's [rules syntax](https://hledger.org/import-csv.html).  In that case, it may be necessary to write your own pre-processing bash script before `hledger print` can work properly.  You can save your script in `script/pre-process-scripts/` and reference it when you define the account name.  If no pre-processing is needed, this field can be blank, but make sure to include a comma. (At this time, I don't have an example of this for illustration.)

Use
===
Here's how I use the scripts:

1. I define the following aliases in my `.bashrc`.  Notice that `DownloadingFiles.sh` is sourced, but `BulkImport.sh` is executed.  There are reasons for this that should become clear after use
    ~~~bash
    alias dl='source /path/to/DownloadingFiles.sh'
    alias bulkim='/path/to/BulkImport.sh'
    ~~~

2. At the end of each month, I go to the website of each bank and download a csv of the month's transactions and a pdf of my statement.  As I do this, I `cd` into my `~/Downloads/` directory to run `dl` to organize these files.  Here is the usage of `dl` (that, is `source /path/to/DownloadingFiles.sh`):
    - `cm` to change the month.  By default, the month is set to the one prior to this month
    - `ca` to change account.  You can choose any of the accounts configured in `config.sh`
    - `ck` to check your downloads.  This prints a table of all your banks and indicates whether you have yet downloaded csv's and statements for each.
    - (any `.csv` or `.pdf`) filename to move that file to the appropriate folder in the directory structure shown below.  All
    pdf's get saved as `s-bank_name-00.pdf`.  All csv's get saved as `c-bank_name-00.csv`, and an entry is made into 
    `to-import.txt`, which will be used by `BulkImport.sh`.

3. Once I have done this for all banks for--say--February, I run `bulkim /path/to/data/02/to-import.txt`.
    ~~~bash
    bulkim /path/to/data/02/to-import.txt
    ~~~  
4. Sometimes I find that I should update my HLedger rules files in `script/hledger-rules` and then run step 3 again.
5. Once I'm happy with the output, I append it to the end of my ledger journal using 
    ~~~bash
    bulkim /path/to/data/02/to-import.txt >> /path/to/ledger.journal
    ~~~

Tutorial
========
To see how this works, run the following commands after cloning this repository:

~~~bash
cd hledger-import-script/example/

alias dl='source ../script/DownloadingFiles.sh'
alias bulkim='../script/BulkImport.sh'

dl ck
dl cm #when prompted, type '7' for July.
dl bankdata.csv
dl statement.pdf
dl ck

bulkim data/01/to-import.txt 

#if you like the result, run it again and append to your journal
bulkim data/01/to-import.txt >> ledger.journal
~~~

Acknowledgements
===============

**Please Note**: What is provided in `script/hledger-rules/sample.csv.rules` and `example/download/bankdata.csv` is nothing more than the example given in the [csv format page](https://hledger.org/hledger.html#csv-format) on the HLedger Project Website.  Other examples rules files are available at <https://github.com/simonmichael/hledger/tree/master/examples/csv>.

I use the sample files instead of my own because I'm not keen on sharing the financial instutions at which I personally store my money on the open web!