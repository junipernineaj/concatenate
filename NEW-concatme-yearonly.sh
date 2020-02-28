#!/bin/bash


##
##Concat files
##

##Variables and Environment

OIFS="$IFS"
IFS=$'\n'
LOGDATETIMESTAMP=`date "+%Y%m%d-%H%M%S"`
#FILELOCATION="/Volumes/ExtremeSSD/Transform"
FILELOCATION="/Users/aj9/Development/concat"
DESTINATIONLOCATION="/Users/aj9/Development/concat/CONCATENATION-BY-YEAR"
COUNTER=`expr 0 + 1`

DATASET=$1
COUNTRY=$2

LOGFILE=./logs/$LOGDATETIMESTAMP-concat-$DATASET.txt

if [ ! $3 == "Off" ]
then
DEBUG=On
else
DEBUG=Off
fi


logging () {

DATETIMESTAMP=`date "+%Y%m%d-%H%M%S"`
MESSAGE=$1
echo $DATETIMESTAMP - "$MESSAGE" >> $LOGFILE
}

debugging () {

DATETIMESTAMP=`date "+%Y%m%d-%H%M%S"`
MESSAGE=$1

if [ $DEBUG == "On" ]
then
        echo $DATETIMESTAMP - "$MESSAGE" | tee -a $LOGFILE
fi
}


CopyMeFunction () {

logging "Start of CopyMe function"


logging "End of CopyMe function"

}



CountRowsInFile () {

logging "Start of CountRowsInFile function"

ROWCOUNT=`wc -l "${FILEPATH}/${FILENAME}" | awk '{print $1}' | sed s/" "//g`

debugging "There are $ROWCOUNT rows in $FILENAME"

logging "End of CountRowsInFile function"

}


AddFilePathTag () {

logging "Start of AddFilePathTag function"

UNDONECOMPANY=`echo "$COMPANYSUBCOMPANY" | sed 's/_/\//g'`
FILEPATHTAG=`echo "<filepath>$COUNTRY/$UNDONECOMPANY/$YEARMONTH/$ORIGINALFILENAME</filepath>"`

logging "File Path Tag is: $FILEPATHTAG"

echo "$FILEPATHTAG" >> "${FILEPATH}/${FILENAME}"

logging "End of AddFilePathTag function"

}


ConcatenateData () {

logging "Start of ConcatenateData function"

for ORIGINALFILENAME in `find -s "$COMPANYFOLDERLONG" -name "LS*xml" -print0 | xargs -0 basename` 
do

debugging "Original File name: $ORIGINALFILENAME"

DetermineYearMonth
DefineFilename
CountRowsInFile

if [ $ROWCOUNT -eq 0 ]
then
AddHeaderRows
fi


if [ $ROWCOUNT -lt 999999 ]
then
SEDCLOSINGDATASETTAG=`echo "<\/$DATASET>"`
CLOSINGDATASETTAG=`echo "</$DATASET>"`
logging "Closing DataSet Tag is: $CLOSINGDATASETTAG"
cat "$COMPANYFOLDERLONG/$ORIGINALFILENAME" | grep -v "xml version" | sed s/$SEDCLOSINGDATASETTAG//g >> "${FILEPATH}/${FILENAME}"

AddFilePathTag

echo "$CLOSINGDATASETTAG" >> "${FILEPATH}/${FILENAME}"

else
AddTrailerRow
COUNTER=`expr $COUNTER + 1`
fi

done


logging "End of ConcatenateData function"

}


AddHeaderRows () {

debugging "Start of AddHeaderRows function"

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" >> "${FILEPATH}/${FILENAME}"
echo "<root>" >> "${FILEPATH}/${FILENAME}"

debugging "End of AddHeaderRows function"

}

AddTrailerRow () {

logging "Start of AddTrailerRow function"

echo "</root>" >> "${FILEPATH}/${FILENAME}"

logging "End of AddTrailerRow function"

}


DefineFilename () {

logging "Start of DefineFilename function"


if [ ! $SUBCOMPANY ]
then
FILENAME="${YEAR}_${COUNTER}.xml"
else
FILENAME="${SUBCOMPANY}_${YEAR}_${COUNTER}.xml"

	if [ $FILENAME == "^_H*.xml" ]
	then
	FILENAME="${YEAR}_${COUNTER}.xml"
	fi
fi

debugging "Filename will be: ${FILENAME}"

if [ ! -f "${FILEPATH}/${FILENAME}" ]
then
debugging "Running: touch ${FILEPATH}/${FILENAME}"
touch "${FILEPATH}/${FILENAME}"

##Logic in here to reset counter to one if it ends up starting higher .
#COUNTER=`expr 0 + 1`

fi

logging "End of DefineFilename function"

}


BuildFileNameAndPath () {

logging "Start of BuildFileName function"

FILEPATH="${DESTINATIONLOCATION}/${DATASET}/${COUNTRYFOLDER}/${PARTITIONCOMPANYFOLDER}"

debugging "Running: mkdir -p ${FILEPATH}"
mkdir -p "${FILEPATH}"

ConcatenateData

logging "End of BuildFileName function"

}


DetermineYearMonth () {

logging "Start of DetermineYearMonth function"

debugging "Company Folder Long is: $COMPANYFOLDERLONG"
debugging "Sub Company(s) is: $SUBCOMPANY"

YEARMONTH=`echo "$ORIGINALFILENAME" | awk -F- '{print $1"-"$2}' | grep -o .......$`

YEAR=`echo $YEARMONTH | awk -F"-" '{print $1}'`
debugging "Year: $YEAR"
debugging "Year-Month: $YEARMONTH"

logging "End of DetermineYearMonth function"

}


SplitCompanies () {

logging "Start of SplitCompanies function"

debugging "Splitting: $COMPANYSUBCOMPANY"

COMPANY=`echo "$COMPANYSUBCOMPANY" | awk -F_ '{print $1}'`
SUBCOMPANY=`echo "$COMPANYSUBCOMPANY" | sed s/"$COMPANY"//g | sed s/^_//g`
PARTITIONCOMPANYFOLDER=`echo partition_company="$COMPANY"`
debugging "Company is: $COMPANY"
debugging "Sub Company(s) is: $SUBCOMPANY"
debugging "Partition Company(s) is: $PARTITIONCOMPANYFOLDER"

BuildFileNameAndPath

logging "End of SplitCompanies function"

}

CompanyIdentifier () {

logging "Start of CompanyIdentifier function"

for COMPANYFOLDERLONG in `ls -d "$COUNTRYFOLDERLONG"/*`
do

COMPANYSUBCOMPANY=`echo "$COMPANYFOLDERLONG" | awk -F"partition_company=" '{print $2}'`
COMPANYSUBCOMPANYFOLDER=`basename "$COMPANYFOLDERLONG"`
debugging "Company Folder Long is: $COMPANYFOLDERLONG"
debugging "CompanySubCompany Folder is: $COMPANYSUBCOMPANYFOLDER"
debugging "Company SubCompany is: $COMPANYSUBCOMPANY"

SplitCompanies

done


logging "End of CompanyIdentifier function"

}

CountryIdentifier () {

logging "Start of CountryIdentifier function"

#for COUNTRYFOLDERLONG in `ls -d "$DATASET"/* | head -1`
for COUNTRYFOLDERLONG in `ls -d "$FILELOCATION/$DATASET"/*`
do

COUNTRY=`echo "$COUNTRYFOLDERLONG" | awk -F"partition_country=" '{print $2}'`
COUNTRYFOLDER=`basename "$COUNTRYFOLDERLONG"`
debugging "...."
debugging "Country is: $COUNTRY"
debugging "Fullpath Country Folder is: $COUNTRYFOLDERLONG"
debugging "Country Folder is: $COUNTRYFOLDER"

CompanyIdentifier

done

logging "End of CountryIdentifier function"
}


main () {


CountryIdentifier
}

main
