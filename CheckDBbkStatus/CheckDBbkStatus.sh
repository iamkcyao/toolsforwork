source ~/.bash_profile
#!/bin/bash
nowdate=$(date +"%Y-%m-%d") #今天上傳的檔案
nowdate2=$(date +"%Y_%m_%d") #今天備份的檔案
folderpath="/root/larry/0805"
s3path="****"

###刪除舊檔案
rm -f $folderpath/ok1.log
rm -f $folderpath/notyet1.log
rm -f $folderpath/nowstatus1.log
rm -f $folderpath/nowupload1.log
rm -f $folderpath/nasnotfound1.log

FolderNameStr=$(aws s3 ls ${s3path}/ --profile niceplay-db-rsync | awk {'print $2'} |tr -d '/') ##取得資料夾名稱
FolderName=(${FolderNameStr//,/ }) ##塞入陣列
FolderCount=${#FolderName[@]}  ##取得陣列長度(資料夾的數量)

UploadOK=0    #已完成標記
NotUploadOK=0 #待完成標記
NasNotFound=0 #還沒上傳至NAS標記

for ((i=0; i<$FolderCount ;i++))
do
	NasFileSize=$(ssh jim@192.168.120.252 "ls -l /9SBK/MASTERDB/${FolderName["$i"]} | grep ${nowdate2}" |awk {'print $5'}) ##取得NAS檔案大小
	NasFileCount=$(ssh jim@192.168.120.252 "ls -l /9SBK/MASTERDB/${FolderName["$i"]} | grep ${nowdate2} |wc -l") ##計算NAS檔案數量
S3FileSize=$(aws s3 ls ${s3path}/${FolderName["$i"]}/ --profile niceplay-db-rsync | grep ${nowdate} | grep ${nowdate2} |awk {'print $3'}) ##取得S3檔案大小
S3FileSize2=$(aws s3 ls ${s3path}/${FolderName["$i"]}/ --recursive --human-readable --summarize --profile niceplay-db-rsync | grep ${nowdate} | grep ${nowdate2} |awk {'print $3,$4'}) ##取得S3檔案大小(易讀)
S3FileCount=$(aws s3 ls ${s3path}/${FolderName["$i"]}/ --profile niceplay-db-rsync | grep ${nowdate} | grep ${nowdate2} |wc -l) ##計算S3檔案數量
if [ ${S3FileCount} -gt 0 ]
then
	if [ ${S3FileSize} -eq ${NasFileSize} ]
	then
		UploadOK=$(($UploadOK+1))
		echo " ${FolderName["$i"]} , 檔案大小 ${S3FileSize2} " >> $folderpath/ok1.log
	elif [ ${S3FileSize} -lt ${NasFileSize} ]
	then
		result=`echo "scale=2; ${S3FileSize}/${NasFileSize}*100" | bc`	
		echo " ${FolderName["$i"]} 備份檔正在上傳中 , 已完成 ${result}% " >> $folderpath/nowupload1.log
		#echo " 目前檔案大小 ${S3FileSize} 完整檔案大小 ${NasFileSize}"
		NotUploadOK=$(($NotUploadOK+1))	
	fi
elif [ ${S3FileCount} -eq 0 ]
then
	NotUploadOK=$(($NotUploadOK+1))
	
	if [ ${NasFileCount} -eq 0 ]
	then
		NasNotFound=$(($NasNotFound+1))
		echo " ${FolderName["$i"]} 尚未上傳至 NAS , 請確認排程 " >> $folderpath/nasnotfound1.log
	else
		echo " ${FolderName["$i"]}" >> $folderpath/notyet1.log
	#echo " ${FolderName["$i"]} 檔案尚未上傳 , 請稍後…" >> $folderpath/notyet1.log
	fi
fi

done
##Report 部分
echo "${nowdate} MasterDB 備份狀態" >> $folderpath/nowstatus1.log
echo "-----------------------------------------------" >> $folderpath/nowstatus1.log
nowupload=`ll $folderpath/ |grep nowupload|wc -l`
if [ ${nowupload} -eq 1 ]
then
	echo "上傳中" >> $folderpath/nowstatus1.log
	cat $folderpath/nowupload1.log >> $folderpath/nowstatus1.log
	echo "-----------------------------------------------" >> $folderpath/nowstatus1.log
else
	continue
fi

notyet1=`ll $folderpath/ |grep notyet1|wc -l`
if [ ${notyet1} -eq 1 ]
then
        echo "待完成" >> $folderpath/nowstatus1.log
        cat $folderpath/notyet1.log >> $folderpath/nowstatus1.log
        echo "-----------------------------------------------" >> $folderpath/nowstatus1.log
else
        continue
fi

if [ ${NasNotFound} -eq 1 ]
then
        echo "待上傳至NAS" >> $folderpath/nowstatus1.log
        cat $folderpath/nasnotfound1.log >> $folderpath/nowstatus1.log
        echo "-----------------------------------------------" >> $folderpath/nowstatus1.log
else
        continue
fi

#echo "-----------------------------------------------" >> $folderpath/nowstatus1.log
#echo "待上傳" >> $folderpath/nowstatus1.log
#cat $folderpath/notyet1.log >> $folderpath/nowstatus1.log
#echo "-----------------------------------------------" >> $folderpath/nowstatus1.log
echo "已完成" >> $folderpath/nowstatus1.log
cat $folderpath/ok1.log >> $folderpath/nowstatus1.log
echo "-----------------------------------------------" >> $folderpath/nowstatus1.log
echo "全部檔案數 ${FolderCount} 個 , 已完成 ${UploadOK} 個 , 待完成 ${NotUploadOK} 個 " >> $folderpath/nowstatus1.log
