source ~/.bash_profile
#!/bin/bash
dblist="/root/larry/0805/FileSizeCheck/db.list"
nowdate=$(date +"%Y-%m-%d") #今天上傳的檔案
nowdate2=$(date +"%Y_%m_%d") #今天備份的檔案
yesterday=$(date -d yesterday +"%Y-%m-%d")
yesterday2=$(date -d yesterday +"%Y_%m_%d")

date=$(date '+%Y-%m-%d %H:%M:%S')

ListNum=$(cat ${dblist} |wc -l)

echo "${nowdate}" >> /root/larry/0805/FileSizeCheck/Daily/${nowdate}.html
echo "-------------------------------------------------------" >> /root/larry/0805/FileSizeCheck/Daily/${nowdate}.html
printf "%-20s %-10s %-20s %-20s %-20s\n" DatabaseName Size Today Yesterday SizeCompare >> /root/larry/0805/FileSizeCheck/Daily/${nowdate}.html
for ((i=1; i<=${ListNum} ;i++))
do
	folderpath=$(cat /root/larry/0805/FileSizeCheck/db.list | sed -n "${i},1p" | awk {'print $2'}) ##逐行取得DB NAS路徑
	foldername=$(cat ${dblist} | sed -n "${i},1p" | awk {'print $1'}) ##逐行取得DB名稱
	TodayNasFileExist=$(ssh jim@192.168.120.252 "ls -l ${folderpath} | grep ${nowdate2}" |wc -l ) #查詢檔案數來檢查NAS檔案是否存在，檔案數大於1即為存在
	TodayNasFileSize=$(ssh jim@192.168.120.252 "ls -l ${folderpath} | grep ${nowdate2}" |awk {'print $5'}) ##取得NAS檔案大小
	TodayNasFileSize2=$(ssh jim@192.168.120.252 "ls -lh ${folderpath}  | grep ${nowdate2}" |awk {'print $5'}) ##取得NAS檔案大小
	LastDayNasFileSize=$(ssh jim@192.168.120.252 "ls -l ${folderpath}  | grep ${yesterday2}" |awk {'print $5'}) ##取得前日NAS檔案大小
	
	
if [ ${TodayNasFileExist} -gt 0 ]
then
	if [ ${TodayNasFileSize} -gt ${LastDayNasFileSize} ]
	then
		TodayNasFileSizetemp=$(ssh jim@192.168.120.252 "ls -l ${folderpath}  | grep ${nowdate2}" |awk {'print $5'}) ##取得NAS檔案大小
		sleep 3
		TodayNasFileSizetemp2=$(ssh jim@192.168.120.252 "ls -l ${folderpath}  | grep ${nowdate2}" |awk {'print $5'}) ##取得NAS檔案大小
			if [ ${TodayNasFileSizetemp2} -gt ${TodayNasFileSizetemp} ]
			then
			printf "%-20s %-10s %-20s %-20s %-10s\n" ${foldername} ${TodayNasFileSize2} ${TodayNasFileSizetemp2} ${LastDayNasFileSize} "正在上傳至NAS..." >> /root/larry/0805/FileSizeCheck/Daily/${nowdate}.html
			else
				compare=`expr ${TodayNasFileSize} - ${LastDayNasFileSize} `
			        math2mb=`expr ${compare} / 1024 / 1024 `
				if [ ${math2mb} -gt 1200 ]
				then
					math2gb=`expr ${math2mb} / 1024 `
					printf "%-20s %-10s %-20s %-20s %-10s %4.1f %-4s\n" ${foldername} ${TodayNasFileSize2} ${TodayNasFileSize} ${LastDayNasFileSize} "今日較昨日大" ${math2gb} GB >> /root/larry/0805/FileSizeCheck/Daily/${nowdate}.html
				else
					printf "%-20s %-10s %-20s %-20s %-10s %4.1f %-4s\n" ${foldername} ${TodayNasFileSize2} ${TodayNasFileSize} ${LastDayNasFileSize} "今日較昨日大" ${math2mb} MB >> /root/larry/0805/FileSizeCheck/Daily/${nowdate}.html
				fi
			fi
	elif [ ${TodayNasFileSize} -lt ${LastDayNasFileSize} ]
	then
		TodayNasFileSizetemp=$(ssh jim@192.168.120.252 "ls -l ${folderpath}  | grep ${nowdate2}" |awk {'print $5'}) ##取得NAS檔案大小
                sleep 3
                TodayNasFileSizetemp2=$(ssh jim@192.168.120.252 "ls -l ${folderpath}  | grep ${nowdate2}" |awk {'print $5'}) ##取得NAS檔案大小
                if [ ${TodayNasFileSizetemp2} -gt ${TodayNasFileSizetemp} ]
                then
                        printf "%-20s %-10s %-20s %-20s %-10s\n" ${foldername} ${TodayNasFileSize2} ${TodayNasFileSize} ${LastDayNasFileSize} "正在上傳至NAS..." >> /root/larry/0805/FileSizeCheck/Daily/${nowdate}.html
                else
			compare=`expr ${LastDayNasFileSize} - ${TodayNasFileSize} `
	                math2mb=`expr ${compare} / 1024 / 1024 `
			if [ ${math2mb} -gt 1200 ]
                	then
                        	math2gb=`expr ${math2mb} / 1024 `
	                        printf "%-20s %-10s %-20s %-20s %-10s %4.1f %-4s\n" ${foldername} ${TodayNasFileSize2} ${TodayNasFileSize} ${LastDayNasFileSize} "今日較昨日小" ${math2gb} GB >> /root/larry/0805/FileSizeCheck/Daily/${nowdate}.html
        	        else
				printf "%-20s %-10s %-20s %-20s %-10s %4.1f %-4s\n" ${foldername} ${TodayNasFileSize2} ${TodayNasFileSize} ${LastDayNasFileSize} "今日較昨日小" ${math2mb} MB >> /root/larry/0805/FileSizeCheck/Daily/${nowdate}.html
	                fi
		fi
	elif [ ${TodayNasFileSize} -eq ${LastDayNasFileSize} ]
	then
		printf "%-20s %-10s %-20s %-20s %-10s\n" ${foldername} ${TodayNasFileSize2} ${TodayNasFileSize} ${LastDayNasFileSize} 與前日無差異 >> /root/larry/0805/FileSizeCheck/Daily/${nowdate}.html
	fi
else
printf "%-20s %-20s\n" ${foldername} NotFoundInNAS 
fi

done
echo "-------------------------------------------------------" 

message="/root/larry/0805/FileSizeCheck/Daily/${nowdate}.html"
mailx -r 9SBK-FilesSizeCheck@9splay.com -s "9SBK-FilesSizeCheck ${nowdate}" it9s@9splay.com   < ${message}
