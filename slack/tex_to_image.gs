function doGet(e) {
  var text = e.parameter.text;
  
  basic_url = "https://chart.googleapis.com/chart?cht=tx&chl="
  texts_encode = encodeURIComponent(text);
    
  tex_image_url = basic_url + texts_encode
  
  var res = {"response_type": "in_channel", "text": tex_image_url};
  return ContentService.createTextOutput(JSON.stringify(res)).setMimeType(ContentService.MimeType.JSON);
}
