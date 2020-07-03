#!/bin/bash
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
today=$(date +"%Y-%m-%d")

###執行check主程式
sh /root/larry/0805/CheckMasterDB_0826.sh

###讀取訊息
message=$(cat /root/larry/0805/nowstatus1.log)
notice="${message}"

#將訊息發送LINE群組
TOKEN="LINE notify token"
curl https://notify-api.line.me/api/notify -H "Authorization: Bearer ${TOKEN}" -d "message=${notice}"
