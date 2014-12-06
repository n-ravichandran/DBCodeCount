#!/bin/bash

CONFIG_FILE="config.txt"

SEND_MAIL_TO=`cat $CONFIG_FILE | grep SEND_MAIL_TO | cut -d"=" -f2 | tr -d ' ' 2>/dev/null`

ORACLE_HOME=`cat $CONFIG_FILE | grep ORACLE_HOME | cut -d"=" -f2 | tr -d ' ' 2>/dev/null` ; export ORACLE_HOME

DB_USER_ID=`cat $CONFIG_FILE | grep DB_USER_ID | cut -d"=" -f2 | tr -d ' ' 2>/dev/null`

DB_PASSWORD=`cat $CONFIG_FILE | grep DB_PASSWORD | cut -d"=" -f2 | tr -d ' ' 2>/dev/null`

DB_SID=`cat $CONFIG_FILE | grep DB_SID | cut -d"=" -f2 | tr -d ' ' 2>/dev/null` ; export DB_SID

DB_HOST=`cat $CONFIG_FILE | grep DB_HOST| cut -d"=" -f2 | tr -d ' ' 2>/dev/null`

DB_PORT=`cat $CONFIG_FILE | grep DB_PORT | cut -d"=" -f2 | tr -d ' ' 2>/dev/null`

file_cont=`cat Errorcode.txt`
IFS=', ' read -a ec_arr <<< $file_cont
arr_len=${#ec_arr[@]}

#starting_time=`TZ=GMT+3 date +%d-%b-%Y" "%H:%M:%S`
#echo $starting_time
#curr_time=`TZ=GMT-1 date +%d-%b-%Y" "%H:%M:%S`
#echo $curr_time

for ((time=0; time<=8; time++));
do
t1=$time
t2=`expr $time + 1`

from="08-OCT-2014 0${t1}:00:01"
to="08-OCT-2014 0${t2}:00:00"
for ((i=0; i<arr_len; i++));
do
count=0
echo ${ec_arr[i]}
thres_val=30
count=$( sqlplus  -s $DB_USER_ID/$DB_PASSWORD@MWAUDITINGDB << EOF
       set pagesize 0 feedback off verify off heading off echo off;
	select count(SOACODE) from MW_AUDITING_MASTER where SOACODE= '${ec_arr[i]}' and  eventTimeCompleted BETWEEN to_date('$from','DD-MON-YYYY HH24:MI:SS') and to_date('$to','DD-MON-YYYY HH24:MI:SS');
       exit;
Query
)
echo ${ec_arr[i]} - $count  >> newCount.txt
if [ $count -gt $thres_val ]
then

echo "Error Code ${ec_arr[i]} has reached its Threshold! Please Check..." | mailx -s "Error Count Alert" $SEND_MAIL_TO
echo "Mail has been sent!"
fi

done
echo >> newCount.txt
done
