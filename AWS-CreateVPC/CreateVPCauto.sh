#======================================================================================
# 管理帳號參考
# Account	GameName	AWS Profile
# 

IAMACCOUNT="ACCOUNTNAME"  #管理帳號

VPC_CIDR="172.16.222.0/24"       #內網IP設置
GAME_NAME="22222"		 #VPC名稱

# 可使用區域參考 
#  	Asia Pacific (Tokyo)	Asia Pacific (Seoul)	US East (Ohio)
# 	ap-northeast-1		ap-northeast-2		us-east-2
# 	├ap-northeast-1a	├ap-northeast-2a	├us-east-2a
#	├ap-northeast-1c	├ap-northeast-2b	├us-east-2b
# 	└ap-northeast-1d	└ap-northeast-2c	└us-east-2c

AWS_REGION="ap-northeast-1"	 #區域設定
SUBNET1="172.16.222.0/25"	 #子網路1網段設置
SUBNET1_zone="ap-northeast-1a"   #子網路1區域設定
SUBNET2="172.16.222.128/25"	 #子網路2網段設置
SUBNET2_zone="ap-northeast-1c"   #子網路2區域設定

#==========================Create VPC==================================================
echo "VPC Creating..."
VPC_ID=$(aws ec2 create-vpc --cidr-block ${VPC_CIDR} --query 'Vpc.{VpcId:VpcId}' --output text --region ${AWS_REGION} --profile=${IAMACCOUNT})

echo "  Successful!! VPC ID '$VPC_ID' CREATED in '$AWS_REGION' region."
aws ec2 create-tags --resources $VPC_ID --tags "Key=Name,Value=VPC_${GAME_NAME}_GS" --region $AWS_REGION --profile=${IAMACCOUNT}
#=========================Create SUBNET1===============================================
echo "Creating First Subnet..."
SUBNET1_PUBLIC_ID=$(aws ec2 create-subnet --cidr-block ${SUBNET1} --vpc-id ${VPC_ID} --availability-zone ${SUBNET1_zone} --query 'Subnet.{SubnetId:SubnetId}' --output text --region $AWS_REGION --profile=${IAMACCOUNT})
echo "  Subnet ID ${SUBNET1_PUBLIC_ID} CREATED in ${SUBNET1_zone} Availability Zone."

echo "Naming First Subnet..."
aws ec2 create-tags --resources $SUBNET1_PUBLIC_ID --tags "Key=Name,Value=${GAME_NAME}-GS-SUBNET1" --region $AWS_REGION --profile=${IAMACCOUNT}
echo "  First Subnet ID ${SUBNET1_PUBLIC_ID} NAMED as ${GAME_NAME}-GS-SUBNET1."

echo "Creating Second Subnet..."
SUBNET2_PUBLIC_ID=$(aws ec2 create-subnet --cidr-block ${SUBNET2} --vpc-id ${VPC_ID} --availability-zone ${SUBNET2_zone} --query 'Subnet.{SubnetId:SubnetId}' --output text --region $AWS_REGION --profile=${IAMACCOUNT})
echo "  Subnet ID ${SUBNET2_PUBLIC_ID} CREATED in ${SUBNET2_zone} Availability Zone."

echo "Naming Second Subnet..."
aws ec2 create-tags --resources $SUBNET2_PUBLIC_ID --tags "Key=Name,Value=${GAME_NAME}-GS-SUBNET2" --region $AWS_REGION --profile=${IAMACCOUNT}
echo "  Second Subnet ID ${SUBNET2_PUBLIC_ID} NAMED as ${GAME_NAME}-GS-SUBNET2."
#============================Create Internet gateway==========================================================
# Create Internet gateway

echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' --output text --region ${AWS_REGION} --profile=${IAMACCOUNT})

echo "Internet Gateway Naming..."
aws ec2 create-tags --resources ${IGW_ID} --tags "Key=Name,Value=IGW-${GAME_NAME}-Gateway" --region $AWS_REGION --profile=${IAMACCOUNT}
echo "  Internet Gateway ID ${IGW_ID} CREATED and  NAMED as IGW-${GAME_NAME}-Gateway"

echo "Attach Internet gateway to your VPC..."
aws ec2 attach-internet-gateway --vpc-id ${VPC_ID} --internet-gateway-id $IGW_ID --region ${AWS_REGION} --profile=${IAMACCOUNT}
echo "  Internet Gateway ID ${IGW_ID} ATTACHED to VPC ID ${VPC_ID}"
#============================Create Route Table==========================================================
#echo "Creating Route Table..."
#ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id ${VPC_ID} --query 'RouteTable.{RouteTableId:RouteTableId}' --output text --region ${AWS_REGION} --profile=${IAMACCOUNT})

ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --profile=${IAMACCOUNT} |grep RouteTableId | sed -n "1,1p" |awk {'print $2'} |tr -d '"')

echo "Route Table Naming..."
aws ec2 create-tags --resources ${ROUTE_TABLE_ID} --tags "Key=Name,Value=Route Table-GS-${GAME_NAME}" --region $AWS_REGION --profile=${IAMACCOUNT}

echo "  Route Table ID '$ROUTE_TABLE_ID' CREATED and NAMED as Route Table-GS-${GAME_NAME}"

# Create route to Internet Gateway
aws ec2 create-route --route-table-id ${ROUTE_TABLE_ID} --destination-cidr-block 0.0.0.0/0 --gateway-id ${IGW_ID} --region ${AWS_REGION} --profile=${IAMACCOUNT}
echo "  Route to '0.0.0.0/0' via Internet Gateway ID ${IGW_ID} ADDED to Route Table ID ${ROUTE_TABLE_ID}"

# Associate Subnet with Route Table
aws ec2 associate-route-table --subnet-id $SUBNET1_PUBLIC_ID --route-table-id $ROUTE_TABLE_ID --region $AWS_REGION --profile=${IAMACCOUNT}
echo "  Public Subnet ID ${SUBNET1_PUBLIC_ID} ASSOCIATED with Route Table ID ${ROUTE_TABLE_ID}"
aws ec2 associate-route-table --subnet-id $SUBNET2_PUBLIC_ID --route-table-id $ROUTE_TABLE_ID --region $AWS_REGION --profile=${IAMACCOUNT}
echo "  Public Subnet ID ${SUBNET2_PUBLIC_ID} ASSOCIATED with Route Table ID ${ROUTE_TABLE_ID}"

echo " "
echo " "
echo "┌────┐"
echo "│Done│"
echo "└────┘"
