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
		folder_usage=$(zabbix_get -s ${service_ip} -k vfs.fs.size[${folder_name},pfree])
		echo "${service_name} Free_disk_space_on ${folder_name} ${folder_usage}" >> ./output${check_time}.log
	done
done

cat ./output${check_time}.log |grep -e "/data" -e "/ " -e "/t3" -e "/t4" -e "/t9" -e "mysql" > result1.txt
uniq ./result1.txt > Result-${check_time}.log

linecount=$(cat .Result-${check_time}.log|wc -l)

for ((i=1; i<=${linecount} ;i++))
do
        servername=$(cat .Result-${check_time}.log | sed -n "${i},1p" | awk {'print $1'}) 
        foldername=$(cat .Result-${check_time}.log | sed -n "${i},1p" | awk {'print $3'})         
        pfree=$(cat .Result-${check_time}.log | sed -n "${i},1p" | awk {'print $4'})

curl -d "method=write&servername=${servername}&foldername=${foldername}&pfree=${pfree}" -X POST https://script.google.com/macros/s/AKfycbxckBtqNn0D-JEb5skLFQYzV08h70g_z67-2apgOWE9WfIt2X4/exec

done
