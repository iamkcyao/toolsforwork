source ~/.bash_profile
#!/bin/bash
serverlist="./Server.list"
check_time=$(date +"%Y%m%d")
ListNum=$(cat ${serverlist} |wc -l)

for ((i=1; i<=${ListNum} ;i++))
do
	service_name=$(cat ${serverlist} | sed -n "${i},1p" | awk {'print $1'}) ##逐行取得伺服器名稱
	service_ip=$(cat ${serverlist} | sed -n "${i},1p" | awk {'print $2'}) ##逐行取得伺服器IP

	zabbix_get -s ${service_ip} -k vfs.fs.discovery |jq .|grep FSNAME |awk {'print $2'}|tr -d '"',',' > ./folderlist.tmp
	folder_list_file="./folderlist.tmp"
	folder_list_num=$(cat ${folder_list_file} |wc -l)
	
	for ((j=1; j<=${folder_list_num} ;j++))
	do
		folder_name=$(cat ${folder_list_file} | sed -n "${j},1p" | awk {'print $1'})
            
        if [ ${folder_name} -eq "/ " ] 
        then
            folder_usage=$(zabbix_get -s ${service_ip} -k vfs.fs.size[${folder_name},pfree])
		echo "${service_name} Free disk space on ${folder_name} ${folder_usage}" >> ./output${check_time}.log

        elif [ ${folder_name} -eq "/data" ] 
        then
        elif [ ${folder_name} -eq "/t9" || "/t3" || "/t4" ] 
        then
            fi
        fi

		folder_usage=$(zabbix_get -s ${service_ip} -k vfs.fs.size[${folder_name},pfree])
		echo "${service_name} Free disk space on ${folder_name} ${folder_usage}" >> ./output${check_time}.log
	done
done

cat ./output${check_time}.log |grep -e "/data" -e "/ " -e "/t3" -e "/t4" -e "/t9" -e "mysql" > result1.txt
uniq ./result1.txt > finished.log

linecount=$(cat ./output/TotalCount-${nowdate2}.log|wc -l)

for ((i=1; i<=${linecount} ;i++))
do
        gameName=$(cat ./output/TotalCount-${nowdate2}.log | sed -n "${i},1p" | awk {'print $2'}) 
        typeName=$(cat ./output/TotalCount-${nowdate2}.log | sed -n "${i},1p" | awk {'print $3'})         typeCount=$(cat ./output/TotalCount-${nowdate2}.log | sed -n "${i},1p" | awk {'print $4'})

curl -d "method=write&gamename=${gameName}&type=${typeName}&count=${typeCount}" -X POST https://script.google.com/macros/s/AKfycbwgERxfALm0l8gEa7taDgUFiR6sg8o9VYiVoMKgsqmw5t3ao3k5/exec


done
