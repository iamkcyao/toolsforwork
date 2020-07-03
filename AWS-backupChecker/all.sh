#增加環境變數
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
folder="/root/larry/Check-S3-Backup-Status"
today=$(date +"%Y-%m-%d")
###執行AWS上各遊戲備份檔案檢查SHELL###
sh ${folder}/bzkr-s3backup.sh
###輸出遊戲名稱及日期至每日Daily檔案###
echo "Product ID：BZKR  Date：${today}" >> ${folder}/Daily/Daily-${today}.log
###將輸出的內容接在遊戲名稱後面###
cat ${folder}/bzkr-s3backup/bzkr-s3backup-${today}.log >> ${folder}/Daily/Daily-${today}.log
###輸出分隔線###
echo "——————————————————————————————" >> ${folder}/Daily/Daily-${today}.log
cat ${folder}/bzkr-s3backup/bzkr-s3backup-compare-${today}.log >> ${folder}/Daily/Daily-${today}.log
echo "——————————————————————————————" >> ${folder}/Daily/Daily-${today}.log


###將每日Daily 發出Mail通知###
message="${folder}/Daily/Daily-${today}.log"
mailx -r mailAddress -s "AWS-S3-Backup Daily ${today}" mailAddress   < ${message}
