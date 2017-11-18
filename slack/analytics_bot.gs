var token = "XXXXXXX";//Slackで生成されたTokenを貼り付ける

function doPost(e) {
  if (token != e.parameter.token) {
    return 
  }
  var text = e.parameter.text;
    
  var textForSlack = getAnalyticsData(text);
  var res = {"response_type": "in_channel", "text": textForSlack};
  return ContentService.createTextOutput(JSON.stringify(res)).setMimeType(ContentService.MimeType.JSON);
}

function getAnalyticsData (text) {
  var slack_text = "";
  var today = new Date();
  var timezone = Session.getTimeZone();
  var endDate = Utilities.formatDate(today, timezone, 'yyyy-MM-dd');

  var tableId = "ga:" + "XXXXXXX"; //Google AnalyticsのプロファイルIDを貼りつけ

  if (text == "昨日"){
    var startDate = Utilities.formatDate(new Date(today.getYear(), today.getMonth(),today.getDate() -1), timezone, 'yyyy-MM-dd');
  }
  else if (text == "今月"){
    var startDate = Utilities.formatDate(new Date(today.getYear(), today.getMonth(),1), timezone, 'yyyy-MM-dd');
  }
  else {
    return;
  }
  
  var metric = "ga:sessions,ga:users,ga:pageviews";/*,ga:pageviews*/
  var options = {
    "dimensions":"ga:channelGrouping"
  };

  var report = Analytics.Data.Ga.get(tableId, startDate,endDate, metric, options).rows;
  
  var session = 0;
  var uu = 0;
  var pageViews = 0;
  
  for (i = 0;i < report.length; i = i +1){
    slack_text += report[i][0] + "のセッション数は" + report[i][1] + "で，UU数は" + report[i][2] +"で，PV数は"+ report[i][3] +"\n";
    session = session + parseInt(report[i][1]);
    uu = uu + parseInt(report[i][2]);
    pageViews = pageViews + parseInt(report[i][3]);
  }
  
  slack_text = "全体：セッション数は" +session + "で，UU数は" + uu +"で，PV数は"+ pageViews +"でした。\n" + slack_text;
  return slack_text
}
