language = "en";
function toggleTranslate() {
  toggle = this;
  toggle.style.transform = "scale(0.9, 0.9)";
  setTimeout(function () {toggle.style.transform = "scale(1, 1)";}, 200);
  if (language=="en") {
    requestLanguageFile("de");
    language = "de";
  } else {
    requestLanguageFile("en");
    language = "en";
  }
}
document.addEventListener('DOMContentLoaded', function() {
  document.getElementById("language-toggle").addEventListener("click", toggleTranslate);
}, false);

function translate(data) {
  texts = document.querySelectorAll("[data-translation-id]");
  for (text of texts) {
    id = text.getAttribute("data-translation-id");
    if (data[id]!=undefined) {
      text.innerHTML = data[id];
    }
  }
}
function requestLanguageFile(lang) {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
         // Typical action to be performed when the document is ready:
         var data = JSON.parse(this.responseText);
         translate(data);
      }
  };
  xhttp.open("GET", `translations/${lang}.json`, true);
  xhttp.send();
}
