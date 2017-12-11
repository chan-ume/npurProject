var datasets = {};
var f1 = function(e) { 
  e.preventDefault(); //ドラッグを許可するための定型文
};
var f2 = function(e) {
    e.preventDefault();//ドラッグを許可するための定型文
    
    var file = e.dataTransfer.files[0];
    var reader = new FileReader();//ファイルを読み込むためのオブジェクト

    reader.name = file.name;//onload処理で名前を取り出すために追加...bad know-howらしい 
    reader.onload = function() {
        Shiny.onInputChange("imgfile", reader.result);
    };
    reader.readAsDataURL(file);//この読み込みが終わってから上のonload処理が始まる
};
