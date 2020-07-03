source ~/.bash_profile
#!/bin/bash
today=$(date +"%Y-%m-%d")
iam="ACCOUNTNAME"
backuppath="/root/route53-backup"

mkdir -p ${backuppath}/${today}

ZonesNameStr=$(cli53 list --profile ${iam} |sed -n "2,5p" | awk {'print $4'})
ZonesName=(${ZonesNameStr//,/ })
ZonesCount=${#ZonesName[@]}

#echo "${ZonesCount}"

for ((i=0; i<$ZonesCount ;i++))
do
	echo "${ZonesName["$i"]} , DNS Record 備份中..."
	cli53 export ${ZonesName["$i"]} --full --profile ${iam} > "${ZonesName["$i"]}.txt"
done

mv ${backuppath}/*.txt ${backuppath}/${today}/
