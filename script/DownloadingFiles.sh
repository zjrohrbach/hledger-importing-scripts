#import configuration variables
base_file_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
config_file="$base_file_path/config.sh"
source $config_file

if [ -z $L_DL_MONTH ]							#Set month to last month unless it has already been set
then
	monthtoset=$(date -v-1m +"%m")
	export L_DL_MONTH=$monthtoset
fi

if [ -z $L_DL_ACCT ]							#Set account to first possibility unless it has already been set
then
	export L_DL_ACCT=${acct_names[0]}
fi

echo "We are working in the month ($L_DL_MONTH) and the account ($L_DL_ACCT)"	#print our working month and account

if [ -z $1 ]								#Check to make sure there is an argument
then
	echo "NO ARGUMENT GIVEN"
	echo "Possible arguments:
		cm  change month
		ca  change account
		ck  check files for month
		go  go to monthly directory and enter vim for all csv's
		filename to import"
	return
fi

if [ $1 = 'cm' ]							#Change month function
then
	echo "Enter the month you would like to change to"
	read -p ">  " promptvar
	export L_DL_MONTH=$(printf "%02d" $promptvar) #convert to leading zero format
	echo "Month set to ($L_DL_MONTH)."
	return
fi

if [ $1 = 'ca' ]							#Change account function
then
	echo "Which account would you like to change to?"
	let n=0
	for i in ${acct_names[@]} #list all posible accounts
	do 
		printf "%s\t" "$n=$i"
		let n++
	done
	echo ""
	read -p ">  " promptvar
	export L_DL_ACCT=${acct_names[$promptvar]}
	echo "Account set to ($L_DL_ACCT)"
	return
fi

if [ $1 = 'ck' ]							#check files for month option
then
	echo "Files for month ($L_DL_MONTH)"
	printf "%16s %15s %15s" "" "csv" "pdf" #heading
	printf "\n" ""
	printf "%16s %15s %15s" "------" "-----" "-----"
	printf "\n" ""
	i=0
	while [ $i -lt ${#acct_names[*]} ]  #foreach account, check both for the csv and the pdf
	do
		printf "%16s" "${acct_names[i]}"
		for j in 'c' 's'
		do
			if [ $j = 'c' ]
			then
				ext='csv'
			elif [ $j = 's' ]
			then
				ext='pdf'
			fi
			checkfilename="$j-${acct_names[i]}-$L_DL_MONTH.$ext"
			checkforfile=$path_to_finances$L_DL_MONTH/$checkfilename
			if [ -f $checkforfile ]
			then
				printf "%16s" "YES"
			else
				if [ $ext = pdf ] #expect all pdf statements
				then
					printf "%16s" "NO"
				elif [ "${rules_files[i]}" == " " ] #if there's no rules file, don't expect a csv
				then
					printf "%16s" "---"
				
				else
					printf "%16s" "NO"
				fi
			fi
		done
		printf "\n" ""
		((i++))
	done
	return
fi

if [ $1 = 'go' ]							#go to directory and then open vim
then
	cd $path_to_finances$L_DL_MONTH/
	vim *.csv
	return
fi


filename=$(basename $1)							#pull out filename and extension
extension=${filename##*.}

if [ $extension = "pdf" ] || [ $extension = "PDF" ]			#handle account statements
then
	newfilename="s-$L_DL_ACCT-$L_DL_MONTH.pdf"
	echo "This is an account statement"
	filetype='statement' #the only thing that matters for the variable $filetype is whether it is csv
elif [ $extension = "csv" ] || [ $extension = "CSV" ]			#handle csv's
then
	newfilename="c-$L_DL_ACCT-$L_DL_MONTH.csv"
	echo "This is a csv from a bank"
	filetype='csv'
else
	echo "Forbidden file type.  Must be .csv or .pdf"
	return
fi

savepath=$path_to_finances$L_DL_MONTH/$newfilename

if [ -f "$savepath" ] 							#check to make sure there isn't already a file at this location
then
	echo "The file below already exists.  Enter y to overwrite.  Otherwise, enter any other character."
	echo "File: $savepath"
	read -p ">  " promptvar
	if [ $promptvar != 'y' ]
	then
		echo "Process aborted."
		return
	fi
	filetype='rewrite' #we don't want to add to the to-import.txt file unless it is a new csv.  Changing to 'rewrite' prevents a csv from being entered twice
fi

evaluatethis="mv $1 $savepath"
eval $evaluatethis 


if [ -f "$savepath" ]							#check to make the there is a file at the new location 
then
	echo "The file has been moved to the following location:"
	echo $savepath
else
	echo "There appears to be an error in moving the file.  Please try again."
	return
fi

if [ $filetype = 'csv' ]						#append a line to the to-import file for new csv's
then
	to_import_file=$path_to_finances$L_DL_MONTH/to-import.txt

	if [ ! -f $to_import_file ] #if the file doesn't exist yet, create it
	then
		touch $to_import_file
	fi
	echo "$newfilename '$L_DL_ACCT'" >> $to_import_file
fi
