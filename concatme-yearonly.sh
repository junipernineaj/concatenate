#!/bin/bash


##
##Concat files
##

##Variables and Environment

OIFS="$IFS"
IFS=$'\n'
LOGDATETIMESTAMP=`date "+%Y%m%d-%H%M%S"`
FILELOCATION="/Volumes/ExtremeSSD/Transform"
DESTINATIONLOCATION="/Users/aj9/Development/concat/CONCATENATION-BY-YEAR"

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


AddFilePathTag () {

logging "Start of AddFilePathTag function"

UNDONECOMPANY=`echo "$COMPANYSUBCOMPANY" | sed 's/_/\//g'`
FILEPATHTAG=`echo "<filepath>$COUNTRY/$UNDONECOMPANY/$YEARMONTH/$ORIGINALFILENAME</filepath>"`

logging "File Path Tag is: $FILEPATHTAG"

echo "$FILEPATHTAG" >> "${FILEPATH}/${FILENAME}"

logging "End of AddFilePathTag function"

}


AddData () {

logging "Start of AddData function"

for ORIGINALFILENAME in `ls "$COMPANYFOLDERLONG" | grep -o "^[A-Z]*_[A-Z]*_[A-Z]*_[A-Z]*_${YEARMONTH}.*"`
do
SEDCLOSINGDATASETTAG=`echo "<\/$DATASET>"`
CLOSINGDATASETTAG=`echo "</$DATASET>"`
logging "Closing DataSet Tag is: $CLOSINGDATASETTAG"
cat "$COMPANYFOLDERLONG/$ORIGINALFILENAME" | grep -v "xml version" | sed s/$SEDCLOSINGDATASETTAG//g >> "${FILEPATH}/${FILENAME}"

AddFilePathTag

echo "$CLOSINGDATASETTAG" >> "${FILEPATH}/${FILENAME}"

done


logging "End of AddData function"

}


AddHeaderRows () {

logging "Start of AddHeaderRows function"

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" >> "${FILEPATH}/${FILENAME}"
echo "<root>" >> "${FILEPATH}/${FILENAME}"

logging "End of AddHeaderRows function"

}

AddTrailerRow () {

logging "Start of AddTrailerRow function"

echo "</root>" >> "${FILEPATH}/${FILENAME}"

logging "End of AddTrailerRow function"

}


CreateFiles () {

logging "Start of CreateFiles function"

logging "Running: mkdir -p ${FILEPATH}"
mkdir -p "${FILEPATH}"
logging "Running: touch ${FILEPATH}/${FILENAME}"
touch "${FILEPATH}/${FILENAME}"

AddHeaderRows
AddData
AddTrailerRow

logging "End of CreateFiles function"

}


BuildFileNameAndPath () {

logging "Start of BuildFileName function"

COUNTER=`expr 0 + 1`

FILEPATH="${DESTINATIONLOCATION}/${DATASET}/${COUNTRYFOLDER}/${PARTITIONCOMPANYFOLDER}"
FILENAME="${SUBCOMPANY}_${YEARMONTH}_${COUNTER}.xml"
debugging "Filepath will be: ${FILEPATH}"
debugging "Filename will be: ${FILENAME}"

CreateFiles

logging "End of BuildFileName function"

}


DetermineUniqueYearMonth () {

logging "Start of DetermineUniqueYearMonth function"

debugging "Company Folder Long is: $COMPANYFOLDERLONG"
debugging "Sub Company(s) is: $SUBCOMPANY"

for YEARMONTH in `ls "$COMPANYFOLDERLONG" | awk -F- '{print $1"-"$2}' | grep -o .......$ | sort -u`
do
debugging "Year-Month: $YEARMONTH"

#FUDGE

YEAR=`echo $YEARMONTH | awk -F"-" '{print $1}'`
debugging "Year: $YEAR"
YEARMONTH=$YEAR
debugging "Year-Month: $YEARMONTH"


BuildFileNameAndPath

done

logging "End of DetermineUniqueYearMonth function"

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

DetermineUniqueYearMonth


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
