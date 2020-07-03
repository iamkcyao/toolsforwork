#增加環境變數
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
echo "
=================================================================================
請確認這台伺服器是否已建立IAM Username驗證。
請確認KeyPairName與伺服器名稱是否不同，若同樣有AWS-****字樣，會造成程式迴圈錯誤。
=================================================================================
"
read -p "請輸入遊戲名稱 AWS-xxxx-*,輸入xxxx名稱：" gamename
read -p "請輸入CloudWatch IAM UserName：" iamusername
read -p "請輸入第一個接收訊息的Topic ARN：" topic1
read -p "請輸入第二個接收訊息的Topic ARN：" topic2


#獲取InstanceId===========================================================================================================================================================
InstanceIdStr=$(aws ec2 --profile ${iamusername} describe-instances --filters Name=tag-value,Values="AWS-${gamename}-*" | grep InstanceId  |  awk {'print $2'} | tr -d '"' )

#ID做陣列處理
InstanceIdArr=(${InstanceIdStr//,/ })
#獲取NAME=================================================================================================================================================================
InstanceNameStr=$(aws ec2 --profile ${iamusername} describe-instances --filters Name=tag-value,Values="AWS-${gamename}-*" | grep AWS-${gamename} |  awk {'print $2'} | tr -d '"' )

#Name做陣列處理
InstanceNameArr=(${InstanceNameStr//,/ })
#設定監控 CPU大於80


#迴圈化 大量佈署監控
#取得機器數量 迴圈長度
HostNumber=${#InstanceIdArr[@]}
for ((i=0; i<$HostNumber ;i++))
do
aws cloudwatch put-metric-alarm --alarm-name "${InstanceNameArr["$i"]}-EC2狀態檢查失敗" --alarm-description "System Status Check Failed" --metric-name StatusCheckFailed --namespace AWS/EC2 --statistic Maximum --period 60 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold  --dimensions "Name=InstanceId,Value=${InstanceIdArr["$i"]}" --evaluation-periods 2 --alarm-actions ${topic1} ${topic2} --unit Count --profile ${iamusername}

aws cloudwatch put-metric-alarm --alarm-name "${InstanceNameArr["$i"]}-CPU平均使用率大於80%" --alarm-description "Alarm when CPU exceeds 80 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 80 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=${InstanceIdArr["$i"]}" --evaluation-periods 1 --alarm-actions ${topic1} ${topic2} --unit Percent --profile ${iamusername}

aws cloudwatch put-metric-alarm --alarm-name "${InstanceNameArr["$i"]}-流入大於200MB" --alarm-description "Alarm when NetworkIn 200MB" --metric-name NetworkIn --namespace AWS/EC2 --statistic Average --period 300 --threshold 200000000 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=${InstanceIdArr["$i"]}" --evaluation-periods 3 --alarm-actions ${topic1} ${topic2} --unit Bytes --profile ${iamusername}

done
