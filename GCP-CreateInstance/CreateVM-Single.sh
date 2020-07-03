# 指定帳戶
serviceAccount="GCP service account"
# 指定ProjectName
projectName="gcp project name"
serverName="new instance name"
regionName="asia-east1"
vpcName="vpcname"
subnetsName="subnetname"

# 設定disk來源 及新建Disk大小
rootImage="root image name"
rootSize="30"
dataSize="500"

# 設定Instance規格
cpuSize="4"
ramSize="16384" 
#  4G = 4096
#  8G = 8192
# 16G = 16384
# 32G = 32768
#  ?G = ?*1024

# 建立VPC
#gcloud compute --project=gcp-9splay-warww networks create xxxx-vpc --subnet-mode=custom
# 建立subnets
#gcloud compute --project=gcp-9splay-warww networks subnets create xxxx-game-vpc --network=xxxx-vpc --region=asia-east1 --range=192.168.130.0/24
# 建立 External IP
gcloud compute addresses --project=${projectName} create ${serverName}-public --region=${regionName}
# 建立 Internal IP
gcloud compute addresses --project=${projectName} create ${serverName}-private --region=${regionName} --subnet ${subnetsName}

getExternalIP=$(gcloud compute addresses --project=${projectName} list --filter="name=${serverName}-public"|awk {'print $2'}|sed -n "2,1p")
getInternalIP=$(gcloud compute addresses --project=${projectName} list --filter="name=${serverName}-private"|awk {'print $2'}|sed -n "2,1p")

gcloud beta compute --project=${projectName} instances create ${serverName} --zone=${regionName}-b --machine-type=custom-4-16384 --subnet=${subnetsName} --private-network-ip=${getInternalIP} --address=${getExternalIP} --service-account=${serviceAccount} --image=${rootImage} --image-project=${projectName} --boot-disk-size=${rootSize}GB --boot-disk-type=pd-standard --boot-disk-device-name=${serverName}-root --create-disk=mode=rw,auto-delete=yes,size=${dataSize},type=projects/${projectName}/zones/us-central1-a/diskTypes/pd-standard,name=${serverName}-data,device-name=${serverName}-data --reservation-affinity=any
