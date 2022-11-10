class Translator {
  constructor() {
    this.lang = "en";
    this.datas = {};
  }
  //Needs a language code; currently "en" or "de"
  to(lang) {
    this.lang = lang;
    if (this.datas[lang]==undefined) {
      this.requestLanguageFile(lang);
    } else {
      this.fromData(this.datas[lang]);
    }
  }
  toggle() {
    let toggle = document.getElementById("language-toggle")
    toggle.style.transform = "scale(0.9, 0.9)";
    setTimeout(function () {toggle.style.transform = "scale(1, 1)";}, 200);
    if (this.lang=="en") {
      this.to("de");
    } else {
      this.to("en");
    }
  }
  fromData(data) {
    this.datas[this.lang] = data;
    let texts = document.querySelectorAll("[data-translation-id]");
    for (let text of texts) {
      let id = text.getAttribute("data-translation-id");
      if (data[id]!=undefined) {
        text.innerHTML = data[id];
      }
    }
  }
  renew() {
    this.to(this.lang);
  }
  requestLanguageFile(lang) {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
           // Typical action to be performed when the document is ready:
           var data = JSON.parse(this.responseText);
           translate.fromData(data);
        }
    };
    xhttp.open("GET", `translations/${lang}.json`, true);
    xhttp.send();
  }
}
