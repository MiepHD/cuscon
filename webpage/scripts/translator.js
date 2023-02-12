class Translator {
  constructor() {
    const preflang = navigator.language.slice(0, -3);
    this.lang = preflang == "de" ? "de" : "en";
    this.datas = {};
    this.xhttp = new XMLHttpRequest();
    this.xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
           // Typical action to be performed when the document is ready:
           const data = JSON.parse(this.responseText);
           translate.fromData(data);
        }
    }
  }
  fromData(data) {
    this.datas[this.lang] = data;
    for (const text of $$("[data-translation-id]")) {
      const id = text.getAttribute("data-translation-id");
      if (data[id]) text.innerHTML = data[id];
    }
    tooltip.add();
  }
  requestLanguageFile(lang) {
    this.xhttp.open("GET", `translations/${lang}.json`, true);
    this.xhttp.send();
  }
  get(id) {
    try { return this.datas[this.lang][id] }
    catch { return }
  }
  //Needs a language code; currently "en" or "de"
  to(lang) {
    this.lang = lang;
    if (this.datas[lang]) { this.fromData(this.datas[lang]) }
    else { this.requestLanguageFile(lang) }
  }
  renew() { this.to(this.lang) }
  toggle() {
    const toggle = $$("#language-toggle");
    toggle.style.transform = "scale(0.9, 0.9)";
    setTimeout(() => { toggle.style.transform = "scale(1, 1)" }, 200);
    if (this.lang=="en") { this.to("de") }
    else { this.to("en") }
  }
}
