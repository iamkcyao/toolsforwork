source ~/.bash_profile
#!/bin/bash
accountlist="./IAMaccount.txt"
nowdate=$(date +"%Y-%m-%d") #今天上傳的檔案
nowdate2=$(date +"%Y%m") #今天上傳的檔案
ListNum=$(cat ${accountlist} |wc -l)
rm -rf ./*.log
for ((i=1; i<=${ListNum} ;i++))
do
	account_name=$(cat ${accountlist} | sed -n "${i},1p" | awk {'print $1'}) ##逐行取得帳號名稱
	service_zh_name=$(cat ${accountlist} | sed -n "${i},1p" | awk {'print $2'}) ##逐行取得服務中文名稱
	service_en_name=$(cat ${accountlist} | sed -n "${i},1p" | awk {'print $3'}) ##逐行取得服務英文名稱
	#echo "${service_zh_name} ${service_en_name}"
	
	#取得InstanceName
	InstanceNameStr=$(aws ec2 --profile ${account_name} describe-instances --filters Name=tag-value,Values="AWS-${service_en_name}-*" | grep AWS-${service_en_name} |  awk {'print $2'} | tr -d '"' |tr -d ',' )
	#將InstanceName做陣列處理
	InstanceNameArr=(${InstanceNameStr//,/ })
	#取得機器數量 迴圈長度
	HostNumber=${#InstanceNameArr[@]}
	for ((j=0; j<$HostNumber ;j++))
		do
			getName=${InstanceNameArr["$j"]}
			getType=$(aws ec2 --profile ${account_name} describe-instances --filters Name=tag-value,Values="${InstanceNameArr["$j"]}" |grep InstanceType|awk {'print $2'} | tr -d '"' |tr -d ',')
#			echo "${getName}  ${getType}"
			echo "${getName}  ${getType}" >> ./${service_en_name}-${nowdate2}.log
			#echo "${getType}" >> ./${service_en_name}-temp.log
		done
	pricelist="./price.txt"
	priceNum=$(cat ${pricelist} |wc -l)
#	echo "${service_zh_name} ${service_en_name}" >> ./output/TotalCount-${nowdate2}.log
	for ((k=1; k<=${priceNum} ;k++))
		do
			typeName=$(cat ${pricelist} | sed -n "${k},1p" | awk {'print $1'})
			typeCount=$(cat ./${service_en_name}-${nowdate2}.log | grep ${typeName} | wc -l)
			if [ ${typeCount} -gt 0 ]
				then
#					echo "${typeName} ${typeCount} 台"
					echo "${service_zh_name} ${service_en_name} ${typeName} ${typeCount}" >> ./output/TotalCount-${nowdate2}.log
			fi
		done
	echo "${service_zh_name} ${service_en_name}" >> ./output/ServerTypeCount-${nowdate2}.log
	cat ./${service_en_name}-${nowdate2}.log >> ./output/ServerTypeCount-${nowdate2}.log
	echo " " >> ./output/ServerTypeCount-${nowdate2}.log
#	echo " " >> ./output/TotalCount-${nowdate2}.log
	rm -f ./${service_en_name}-${nowdate2}.log
done

#以下開始將各遊戲使用規格及數量 輸出到Google Sheets
linecount=$(cat ./output/TotalCount-${nowdate2}.log|wc -l)

for ((i=1; i<=${linecount} ;i++))
do
        gameName=$(cat ./output/TotalCount-${nowdate2}.log | sed -n "${i},1p" | awk {'print $2'}) 
        typeName=$(cat ./output/TotalCount-${nowdate2}.log | sed -n "${i},1p" | awk {'print $3'})         typeCount=$(cat ./output/TotalCount-${nowdate2}.log | sed -n "${i},1p" | awk {'print $4'})

curl -d "method=write&gamename=${gameName}&type=${typeName}&count=${typeCount}" -X POST scripts.google.com urls


done
