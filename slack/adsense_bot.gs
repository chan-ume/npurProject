var token = "XXXXXXXXXXXXXXX";//Slackで生成されたTokenを貼り付ける

function doPost(e) {
  if (token != e.parameter.token) {
    return 
  }
  var text = e.parameter.text;
    
  var textForSlack = getAdsenseData(text);
  var res = {"response_type": "in_channel", "text": textForSlack};
  return ContentService.createTextOutput(JSON.stringify(res)).setMimeType(ContentService.MimeType.JSON);
}

function getAdsenseData (text) {
  var slack_text = "";
  var today = new Date();
  var timezone = Session.getTimeZone();
  var endDate = Utilities.formatDate(today, timezone, 'yyyy-MM-dd');

  if (text == "昨日"){
    var startDate = Utilities.formatDate(new Date(today.getYear(), today.getMonth(),today.getDate() -1), timezone, 'yyyy-MM-dd');
  }
  else if (text == "今月"){
    var startDate = Utilities.formatDate(new Date(today.getYear(), today.getMonth(),1), timezone, 'yyyy-MM-dd');
  }
  else {
    return;
  }

  var report = AdSense.Reports.generate(startDate, endDate, {
    metric: ['PAGE_VIEWS', 'AD_REQUESTS', 'CLICKS',
             'AD_REQUESTS_CTR', 'COST_PER_CLICK', 'AD_REQUESTS_RPM',
             'EARNINGS'],
  }).rows;
  
  if (report) {
    slack_text += "ページビュー数：" + report[0][0] + "\n広告リクエスト回数：" + report[0][1] + "\nクリック数：" + report[0][2] +"\nCTR："+ report[0][3];
    slack_text += "\nCPC：" + report[0][4] + "\nRPM：" + report[0][5] + "\n見積もり収益：" + report[0][6] + "\nという結果です。"
    return slack_text;
  }
  else {
    return;
  }
}
