# 指定帳戶 , 至 IAM 頁面查詢
serviceAccount="-compute@developer.gserviceaccount.com"
# 指定ProjectName
projectName="sdadadas"
# 指定VM地區
regionName="asia-northeast3"
zoneName="asia-northeast3-a"
# 指定subnets
subnetsName="dfdfdfdf"


vm_list="./server.list" #需配合此檔案做操作, 修改檔案中的內容
ListNum=$(cat ${vm_list} |wc -l)
for ((i=2; i<=${ListNum} ;i++))
do
    ServerName=$(cat ${vm_list} |awk {'print $1'}|sed -n "${i},1p")
    cpuSize=$(cat ${vm_list} |awk {'print $2'}|sed -n "${i},1p")
    ramSize=$(cat ${vm_list} |awk {'print $3'}|sed -n "${i},1p")
    rootImage=$(cat ${vm_list} |awk {'print $4'}|sed -n "${i},1p")
    rootSize=$(cat ${vm_list} |awk {'print $5'}|sed -n "${i},1p")
    dataImage=$(cat ${vm_list} |awk {'print $6'}|sed -n "${i},1p")
    dataSize=$(cat ${vm_list} |awk {'print $7'}|sed -n "${i},1p")
#   PRIVATEIP=$(cat ${vm_list} |awk {'print $8'}|sed -n "${i},1p")
    tagname=$(cat ${vm_list} |awk {'print $8'}|sed -n "${i},1p")

    # 建立 External IP
    gcloud compute addresses --project=${projectName} create ${ServerName}-public --region=${regionName}
    # 建立 Internal IP
    gcloud compute addresses --project=${projectName} create ${ServerName}-private --region=${regionName} --subnet ${subnetsName}

    getExternalIP=$(gcloud compute addresses --project=${projectName} list --filter="name=${ServerName}-public"|awk {'print $2'}|sed -n "2,1p")
    getInternalIP=$(gcloud compute addresses --project=${projectName} list --filter="name=${ServerName}-private"|awk {'print $2'}|sed -n "2,1p")

    gcloud beta compute --project=${projectName} instances create ${ServerName} --deletion-protection --zone=${zoneName} --machine-type=custom-${cpuSize}-${ramSize} --subnet=${subnetsName} --private-network-ip=${getInternalIP} --address=${getExternalIP} --service-account=${serviceAccount} --image=${rootImage} --image-project=${projectName} --boot-disk-size=${rootSize}GB --boot-disk-type=pd-standard --boot-disk-device-name=${ServerName}-root --tags=${tagname}  --create-disk=mode=rw,size=${dataSize},type=projects/${projectName}/zones/us-central1-a/diskTypes/pd-standard,name=${ServerName}-data,image=projects/${projectName}/global/images/${dataImage},device-name=${ServerName}-data --reservation-affinity=any
done
