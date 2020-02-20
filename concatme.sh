#!/bin/bash


##
##Concat files
##

##Variables and Environment

OIFS="$IFS"
IFS=$'\n'
LOGDATETIMESTAMP=`date "+%Y%m%d-%H%M%S"`
FILELOCATION="/Users/aj9/Development/concat"
DESTINATIONLOCATION="/Users/aj9/Development/concat/CONCATENATION"

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


BuildFileName () {

logging "Start of BuildFileName function"

DetermineUniqueYearMonth

logging "End of BuildFileName function"

}


DetermineUniqueYearMonth () {

logging "Start of DetermineUniqueYearMonth function"

debugging "Company Folder Long is: $COMPANYFOLDERLONG"
debugging "Sub Company(s) is: $SUBCOMPANY"

for YEARMONTH in `ls "$COMPANYFOLDERLONG" | awk -F- '{print $1"-"$2}' | grep -o .......$ | sort -u`
do
debugging "Year-Month: $YEARMONTH"
done

logging "End of DetermineUniqueYearMonth function"

}


SplitCompanies () {

logging "Start of SplitCompanies function"

debugging "Splitting: $COMPANYSUBCOMPANY"

COMPANY=`echo "$COMPANYSUBCOMPANY" | awk -F_ '{print $1}'`
SUBCOMPANY=`echo "$COMPANYSUBCOMPANY" | sed s/"$COMPANY"//g | sed s/^_//g`
PARTITIONCOMPANY=`echo partition_company="$COMPANY"`
debugging "Company is: $COMPANY"
debugging "Sub Company(s) is: $SUBCOMPANY"

BuildFileName


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

for COUNTRYFOLDERLONG in `ls -d "$DATASET"/*`
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
