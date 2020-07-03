#==== 增加環境變數 ====#
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#==== 請將須加入CloudWatch Alarm的Instance Name填入，並用雙引號["]做間隔。 ====#
vm_name=(
"INSTANCENAME"
)
#==== 以下為各遊戲使用帳號及資訊，其他遊戲再新增即可 ====#
#iamusername="ACCOUNTNAME"
#topic1="arn:aws:sns:"
#topic2="arn:aws:sns:"



for ((i=0; i<${#vm_name[@]} ;i++))
do
InstanceIdStr=$(aws ec2 --profile ${iamusername} describe-instances --filters Name=tag-value,Values="${vm_name["$i"]}" | grep InstanceId  |  awk {'print $2'} | tr -d ',' )

#更換帳號可先使用以下測試確認Instance Namec與Instance ID是否對應
echo "${vm_name["$i"]} is ${InstanceIdStr} setting Done!"

#==== 以下開始建立Cloudwatch Alarm項目 ====#	

aws cloudwatch put-metric-alarm --alarm-name "${vm_name["$i"]}-EC2狀態檢查失敗" --alarm-description "System Status Check Failed" --metric-name StatusCheckFailed --namespace AWS/EC2 --statistic Maximum --period 60 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold  --dimensions "Name=InstanceId,Value=${InstanceIdStr}" --evaluation-periods 2 --alarm-actions ${topic1} ${topic2} --unit Count --profile ${iamusername}

aws cloudwatch put-metric-alarm --alarm-name "${vm_name["$i"]}-CPU平均使用率大於80%" --alarm-description "Alarm when CPU exceeds 80 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 80 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=${InstanceIdStr}" --evaluation-periods 1 --alarm-actions ${topic1} ${topic2} --unit Percent --profile ${iamusername}

aws cloudwatch put-metric-alarm --alarm-name "${vm_name["$i"]}-流入大於200MB" --alarm-description "Alarm when NetworkIn 200MB" --metric-name NetworkIn --namespace AWS/EC2 --statistic Average --period 300 --threshold 200000000 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=${InstanceIdStr}" --evaluation-periods 3 --alarm-actions ${topic1} ${topic2} --unit Bytes --profile ${iamusername}

done
