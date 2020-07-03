#備份相關資訊
iamaccount="ACCOUNTNAME"
product_folder="FOLDERNAME"
result_folder="OUTPUTFOLDER"
#定義今天日期格式
today=$(date +"%Y-%m-%d")
yesterday=$(date -d yesterday +"%Y-%m-%d")

find ${result_folder}/${product_folder}/ -type f -name "*.log" -atime +5 -exec rm -rf {} \;

#<<COMMENT
#取得S3資料夾名稱塞入陣列
FolderNameStr=$(aws s3 ls ${product_folder} --profile=${iamaccount} | awk {'print $2'} |tr -d '/')
FolderName=(${FolderNameStr//,/ })
FolderCount=${#FolderName[@]}  ##取得陣列長度
for ((i=0; i<$FolderCount ;i++))
do
FileCount=$(aws s3 ls ${product_folder}/${FolderName["$i"]}/ --recursive --human-readable --summarize --profile=${iamaccount} | grep $today | wc -l) ####計算今日新增的檔案數量

if [ ${FileCount} -gt 0 ]  ####若新增有1個檔案以上
then
    echo "${FolderName["$i"]} 今日新增 ${FileCount} 個檔案" >> ${result_folder}/${product_folder}/${product_folder}-${today}.log
fi

done
#COMMENT
####與前日數據比較####
TodayFile="${result_folder}/${product_folder}/${product_folder}-${today}.log"
LastDayFile="${result_folder}/${product_folder}/${product_folder}-${yesterday}.log"
####將今日伺服器名稱匯入字串陣列####
TColStr=$(cat ${TodayFile}|awk {'print $1'})
TContentArr=(${TColStr//,/ })
TColCount=${#TContentArr[@]}
####將前日伺服器名稱匯入字串陣列####
#YColStr=$(cat ${LastDayFile}|awk {'print $1'})
#YContentArr=($YColStr//,/ })
#YColCount=${#YContentArr[@]}
k=1
####以今日的伺服器名稱資料跑迴圈####
for ((i=1; i<${TColCount};i++))
do
getTItem=$(cat ${TodayFile} |sed -n "${i},1p"|awk {'print $1'}) ####取得今日伺服器名稱
getTNum=$(cat ${TodayFile} |sed -n "${i},1p"|awk {'print $3'}) ####取得今日新增檔案的數量
FindYItemCount=$(cat ${LastDayFile}|grep -w "${getTItem}"|wc -l) ####計算前日伺服器名稱出現次數
FindYItemNum=$(cat ${LastDayFile}|grep -w "${getTItem}"|awk {'print $3'}) ####取得前日伺服器新增檔案的數量

if [ ${FindYItemCount} -eq 1 ]  ####若前日伺服器名稱出現次數1次
then
	if [ ${FindYItemNum} -gt ${getTNum} ]  ####比較若昨日檔案數大於今日檔案數
	then
		ReduceNum=`expr ${FindYItemNum} - ${getTNum}`   
		echo "${getTItem} 相較昨日減少 ${ReduceNum} 個檔案。" >> ${result_folder}/${product_folder}/${product_folder}-compare-${today}.log
		
	elif [ ${FindYItemNum} -lt ${getTNum} ]  ####比較若昨日檔案數小於今日檔案數
	then
		IncreaseNum=`expr ${getTNum} - ${FindYItemNum}`
		echo "${getTItem} 相較昨日增加 ${IncreaseNum} 個檔案。" >> ${result_folder}/${product_folder}/${product_folder}-compare-${today}.log
	elif [ ${FindYItemNum} -eq ${getTNum} ]  ####比較若昨日檔案數等於今日檔案數
	then
		k=$(($k+1))
		if [ ${k} -eq ${TColCount} ]
		then
		echo "所有伺服器新增檔案數與前日相同。" >> ${result_folder}/${product_folder}/${product_folder}-compare-${today}.log
		fi
	fi
elif [ ${FindYItemCount} -eq 0 ]  ####若今日有伺服器名稱，前日無  則視為新增伺服器
then
	echo "本日新增 ${getTItem} , 新增 ${getTNum} 個檔案。" >> ${result_folder}/${product_folder}/${product_folder}-compare-${today}.log
	#echo "本日新增 ${getTItem} , 新增 ${getTNum} 個檔案。"
fi
done

#### 找出前日有，次日無的項目
for ((j=1; j<${TColCount};j++))
do
getYItem=$(cat ${LastDayFile} |sed -n "${j},1p"|awk {'print $1'})  ####取得前日伺服器名稱
getYNum=$(cat ${LastDayFile} |sed -n "${j},1p"|awk {'print $3'}) ####取得前日新增檔案的數量
FindTItemCount=$(cat ${TodayFile}|grep -w "${getYItem}"|wc -l) ####計算今日伺服器名稱出現次數
FindTItemNum=$(cat ${TodayFile}|grep -w "${getYItem}"|awk {'print $3'}) ####取得今日伺服器新增檔案的數量
if [ ${FindTItemCount} -eq 0 ]  ####若前有伺服器名稱，今日無  則視為減少伺服器
then
	echo "本日移除 ${getYItem} 伺服器，可能已經關閉或故障，請與原廠或ＰＭ確認。" >> ${result_folder}/${product_folder}/${product_folder}-compare-${today}.log
        #echo "本日移除 ${getYItem} 伺服器，可能已經關閉或故障，請與原廠或ＰＭ確認。"
fi
done
