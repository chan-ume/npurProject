// @ts-nocheck
var TOAL_COUNT_SHEET_NEME = "視聴回数"
var EACH_DAY_COUNT_SHEET_NEME = "日ごとの視聴回数"
var HEADER_ROW = 1
var VIDEO_NAME_COLUMN = 1
var VIDEO_ID_COLUMN = 2

function updateSheets(){
  var today = new Date();

  updateTotalSheet(today);
  updateEachDaySheet(today);

  postSlack();
}

function updateTotalSheet(today){
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(TOAL_COUNT_SHEET_NEME);
  setDateToSheet(sheet, sheet.getLastColumn(), today);  

  for (var i = HEADER_ROW + 1; i <= sheet.getLastRow(); i = i + 1){
    var videoId = sheet.getRange(i, VIDEO_ID_COLUMN).getValue();
    var viewCountInfo = getViewCount(videoId);    
    sheet.getRange(i, sheet.getLastColumn()).setValue(viewCountInfo);
  }
}

function updateEachDaySheet(today){
  var sheetForCauculate = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(TOAL_COUNT_SHEET_NEME);
  var sheetForEachDay = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(EACH_DAY_COUNT_SHEET_NEME);

  sheetForEachDay.getRange(1, 1, sheetForCauculate.getLastRow(), 2).setValues(sheetForCauculate.getRange(1, 1, sheetForCauculate.getLastRow(), 2).getValues());
  
  setDateLastDay(sheetForEachDay, today);  
  var sheetForCauculateLastCol = sheetForCauculate.getLastColumn();
  var sheetForEachDayLastCol = sheetForEachDay.getLastColumn();

  for (var i = HEADER_ROW + 1; i <= sheetForEachDay.getLastRow(); i = i + 1){
    var tmp = sheetForCauculate.getRange(i, sheetForCauculateLastCol - 1).getValue();
    if (isNaN(tmp) || tmp == ""){
      console.log(tmp);
      continue;
    }
    sheetForEachDay.getRange(i, sheetForEachDayLastCol).setValue(
      sheetForCauculate.getRange(i, sheetForCauculateLastCol).getValue() - tmp);
  }
}

function setDateToSheet(sheet, today){
  sheet.getRange(HEADER_ROW, sheet.getLastColumn() + 1).setValue(today);
}

function setDateLastDay(sheet, today){
  today.setDate(today.getDate() - 1);
  sheet.getRange(HEADER_ROW, sheet.getLastColumn() + 1).setValue(today);
}

function getViewCount(video) {
  var videoId = video;
  var videoInfo = {
        id: videoId,
      };

  var response = YouTube.Videos.list('statistics',videoInfo);  
  var statisticsInfo = response.items[0].statistics;
  
  return statisticsInfo.viewCount;
}
  
/**
 * Slackポストする*
 */
function postSlack() {
  var slack_text = makeSlackMessage();
  if　(slack_text == "") {
    return
  }

  var payload = {
    "text" : slack_text + "\n",
    "channel" : "#test",
    "username" : "GASBot",
    "icon_emoji" : ":tada:"
  }

  var options = {
    "method" : "POST",
    "payload" : JSON.stringify(payload)
  }
  var url = "https://hooks.slack.com/XXXXXXXXXXXXXXXXXXXX"   // Incoming Webhooks用URL
  var response = UrlFetchApp.fetch(url, options);
  var content = response.getContentText("UTF-8");
}

function makeSlackMessage(){
  var slack_text = "";

  var sheetForCauculate = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(TOAL_COUNT_SHEET_NEME);
  var sheetForEachDay = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(EACH_DAY_COUNT_SHEET_NEME);

  for (var i = HEADER_ROW + 1; i <= sheetForEachDay.getLastRow(); i = i + 1){
    var videoName = sheetForEachDay.getRange(i, VIDEO_NAME_COLUMN).getValue();
    var yesterdayViewCount = sheetForEachDay.getRange(i, sheetForEachDay.getLastColumn()).getValue();
    var totalViewCount = sheetForCauculate.getRange(i, sheetForCauculate.getLastColumn()).getValue();
    
    slack_text += "『" + videoName + "』の昨日視聴回数は " + yesterdayViewCount + " でした（トータルは " + totalViewCount + "）\n";
  }

  Logger.log(slack_text);
  return slack_text;
}
