#!/bin/bash
unixtime=$(date +"%s")

read -p "請輸入Origin Domain（ex, xxx-aws.9splay.com）：" OriginDomain
read -p "請輸入SSL憑證ARN（請確認與域名相符）：" ACMCertificateArn
read -p "請輸入CNAMEs（對外域名）：" CNAMEs
read -p "請輸入Cloudfront IAM UserName（需有建立權限）：" iamusername

###產生distconfig.json設定檔
echo "{
    \"CallerReference\": \"my-distribution-${unixtime}\",
    \"Aliases\": {
        \"Quantity\": 0
      },
    \"Origins\": {
        \"Quantity\": 1,
        \"Items\": [
            {
            \"OriginPath\": \"\",
            \"CustomOriginConfig\": {
                \"OriginSslProtocols\": {
                    \"Items\": [
                        \"TLSv1\",
                        \"TLSv1.1\",
                        \"TLSv1.2\"
                    ],
                    \"Quantity\": 3
                },
                \"OriginProtocolPolicy\": \"match-viewer\",
                \"OriginReadTimeout\": 30,
                \"HTTPPort\": 80,
                \"HTTPSPort\": 443,
                \"OriginKeepaliveTimeout\": 5
            },
            \"CustomHeaders\": {
                \"Quantity\": 0
            },
            \"Id\": \"Custom-${OriginDomain}\",
            \"DomainName\": \"${OriginDomain}\"
        }
            ]
        },
        \"DefaultCacheBehavior\": {
        \"TrustedSigners\": {
            \"Enabled\": false,
            \"Quantity\": 0
        },
        \"LambdaFunctionAssociations\": {
            \"Quantity\": 0
        },
        \"TargetOriginId\": \"Custom-${OriginDomain}\",
        \"ViewerProtocolPolicy\": \"allow-all\",
        \"ForwardedValues\": {
            \"Headers\": {
                \"Items\": [
                    \"*\"
                ],
                \"Quantity\": 1
            },
            \"Cookies\": {
                \"Forward\": \"all\"
            },
            \"QueryStringCacheKeys\": {
                \"Quantity\": 0
            },
            \"QueryString\": true
        },
        \"MaxTTL\": 31536000,
        \"SmoothStreaming\": false,
        \"DefaultTTL\": 86400,
        \"AllowedMethods\": {
            \"Items\": [
                \"HEAD\",
                \"DELETE\",
                \"POST\",
                \"GET\",
                \"OPTIONS\",
                \"PUT\",
                \"PATCH\"
            ],
            \"CachedMethods\": {
                \"Items\": [
                    \"HEAD\",
                    \"GET\"
                ],
                \"Quantity\": 2
            },
            \"Quantity\": 7
        },
        \"MinTTL\": 0,
        \"Compress\": false
        },
        \"IsIPV6Enabled\": false,
                    \"Comment\": \"\",
                    \"ViewerCertificate\": {
                        \"SSLSupportMethod\": \"sni-only\",
                        \"ACMCertificateArn\": \"${ACMCertificateArn}\",
                        \"MinimumProtocolVersion\": \"TLSv1\",
                        \"Certificate\": \"${ACMCertificateArn}\",
                        \"CertificateSource\": \"acm\"
                    },
                    \"CustomErrorResponses\": {
                        \"Quantity\": 0
                    },
                    \"HttpVersion\": \"http2\",
                    \"Aliases\": {
                        \"Items\": [
                            \"${CNAMEs}\"
                        ],
                        \"Quantity\": 1
                    },
    \"CacheBehaviors\": {
        \"Quantity\": 0
      },
      \"Comment\": \"\",
      \"Logging\": {
        \"Enabled\": false,
        \"IncludeCookies\": true,
        \"Bucket\": \"\",
        \"Prefix\": \"\"
      },
      \"PriceClass\": \"PriceClass_All\",
      \"Enabled\": true
  }" > distconfig.json

###執行指令建立Cloudfront
aws cloudfront create-distribution --distribution-config file://distconfig.json --profile ${iamusername}
