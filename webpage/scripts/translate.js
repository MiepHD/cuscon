language = "en"
function translate() {
  language = "de";
  texts = document.querySelectorAll("[data-de]");
  for (text of texts) {
    if (!text.classList.contains("translated")) {
			text.classList.add("translated");
			text.setAttribute("data-en", text.textContent);
      text.textContent = text.getAttribute("data-de");
    }
  }
}
function translateBack() {
  language = "en";
  texts = document.querySelectorAll(".translated");
  for (text of texts) {
    if (text.classList.contains("translated")) {
      text.classList.remove("translated");
      text.textContent = text.getAttribute("data-en");
			text.removeAttribute("data-en");
    }
  }
}
function toggleTranslate() {
  toggle = this;
  toggle.style.transform = "scale(0.9, 0.9)";
  setTimeout(function () {toggle.style.transform = "scale(1, 1)";}, 200);
  if (language=="en") {
    translate();
  } else {
    translateBack();
  }
}
document.addEventListener('DOMContentLoaded', function() {
  document.getElementById("language-toggle").addEventListener("click", toggleTranslate);
}, false);
