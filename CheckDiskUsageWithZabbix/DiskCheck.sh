source ~/.bash_profile
#!/bin/bash
serverlist="./Server.list"
ListNum=$(cat ${serverlist} |wc -l)

for ((i=1; i<=${ListNum} ;i++))
do
    service_name=$(cat ${serverlist} | sed -n "${i},1p" | awk {'print $1'}) ##逐行取得伺服器名稱
	service_ip=$(cat ${serverlist} | sed -n "${i},1p" | awk {'print $2'}) ##逐行取得伺服器IP

    root_folder=$(zabbix_get -s ${service_ip} -k vfs.fs.size[/,pfree])
    data_folder=$(zabbix_get -s ${service_ip} -k vfs.fs.size[/data,pfree])

    echo "${service_name} Free disk space on / ${root_folder}"
    echo "${service_name} Free disk space on /data ${data_folder}"

done
