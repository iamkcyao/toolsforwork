var ss = SpreadsheetApp.getActiveSpreadsheet(),
sheet1 = ss.getSheetByName("EC2Type"); // "EC2Type" 改成你的工作表名稱

function doPost(e) {
var para = e.parameter, // 存放 post 所有傳送的參數
method = para.method;

if (method == "write") {
write_data(para);
}
if (method == "read") {
// 這裡放讀取資料的語法 下一篇說明
}

}

function write_data(para) {
var gamename = para.gamename,
type = para.type,
count = para.count;
//sheet1.appendRow([name, sex, remark]); // 插入一列新的資料
  sheet1.appendRow([gamename, type, count]); // 欄位名稱需和工作表上一樣
}
