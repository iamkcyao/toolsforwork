ServerList="/root/larry/ZabbixShell/server.list"
ListNum=$(cat ${ServerList}|wc -l)


rm -f /root/larry/ZabbixShell/importScreen.xml

ScreenName="WJKR - Status"
ResourceItem1="CPU-Idle Time"
ResourceItem2="可使用 Memory"
ResourceItem3="Network traffic on eth0"

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<zabbix_export>
    <version>3.0</version>
    <date>2020-07-21T07:54:16Z</date>
    <screens>
        <screen>
            <name>${ScreenName}</name>
            <hsize>3</hsize>
            <vsize>${ListNum}</vsize>
            <screen_items>" >> /root/larry/ZabbixShell/importScreen.xml

for ((i=1; i<=${ListNum} ;i++))
do
    getHostName=$(cat ${ServerList} |awk {'print $1'}|sed -n "${i},1p")
    ((y=$i-1))
echo "<screen_item>
                    <resourcetype>0</resourcetype>
                    <width>500</width>
                    <height>100</height>
                    <x>0</x>
                    <y>${y}</y>
                    <colspan>1</colspan>
                    <rowspan>1</rowspan>
                    <elements>0</elements>
                    <valign>0</valign>
                    <halign>0</halign>
                    <style>0</style>
                    <url/>
                    <dynamic>0</dynamic>
                    <sort_triggers>0</sort_triggers>
                    <resource>
                        <name>${ResourceItem1}</name>
                        <host>${getHostName}</host>
                    </resource>
                    <max_columns>3</max_columns>
                    <application/>
                </screen_item>
                <screen_item>
                    <resourcetype>0</resourcetype>
                    <width>500</width>
                    <height>100</height>
                    <x>1</x>
                    <y>${y}</y>
                    <colspan>1</colspan>
                    <rowspan>1</rowspan>
                    <elements>0</elements>
                    <valign>0</valign>
                    <halign>0</halign>
                    <style>0</style>
                    <url/>
                    <dynamic>0</dynamic>
                    <sort_triggers>0</sort_triggers>
                    <resource>
                        <name>${ResourceItem2}</name>
                        <host>${getHostName}</host>
                    </resource>
                    <max_columns>3</max_columns>
                    <application/>
                </screen_item>
                <screen_item>
                    <resourcetype>0</resourcetype>
                    <width>500</width>
                    <height>100</height>
                    <x>2</x>
                    <y>${y}</y>
                    <colspan>1</colspan>
                    <rowspan>1</rowspan>
                    <elements>0</elements>
                    <valign>0</valign>
                    <halign>0</halign>
                    <style>0</style>
                    <url/>
                    <dynamic>0</dynamic>
                    <sort_triggers>0</sort_triggers>
                    <resource>
                        <name>${ResourceItem3}</name>
                        <host>${getHostName}</host>
                    </resource>
                    <max_columns>3</max_columns>
                    <application/>
                </screen_item>"  >> /root/larry/ZabbixShell/importScreen.xml
done
echo "    </screen_items>
        </screen>
    </screens>
</zabbix_export>"  >> /root/larry/ZabbixShell/importScreen.xml
