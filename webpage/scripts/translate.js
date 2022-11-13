class Translator {
  constructor() {
    this.lang = "en";
    this.datas = {};
    this.xhttp = new XMLHttpRequest();
    this.xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
           // Typical action to be performed when the document is ready:
           const data = JSON.parse(this.responseText);
           translate.fromData(data);
        }
    };
  }
  get(id) {
    return this.datas[this.lang][id];
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
    const toggle = document.getElementById("language-toggle")
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
    const texts = document.querySelectorAll("[data-translation-id]");
    for (const text of texts) {
      const id = text.getAttribute("data-translation-id");
      if (data[id]!=undefined) {
        text.innerHTML = data[id];
      }
    }
    tooltip.add();
  }
  renew() {
    this.to(this.lang);
  }
  requestLanguageFile(lang) {
    this.xhttp.open("GET", `translations/${lang}.json`, true);
    this.xhttp.send();
  }
}
