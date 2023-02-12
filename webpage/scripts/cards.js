class Cards {
  constructor() {
    this.fullsize = false;
  }
  build() {
    for (const card of $$(".card") ) {
      const content = card.innerHTML, //saves the content temporarly
        div = document.createElement("div"),
        translationid = card.getAttribute("data-translation-id");
      card.innerHTML = ""; //Removes existing content
      card.removeAttribute("data-translation-id");
      div.classList.add("card-content");
      div.innerHTML = content; //adds content back
      div.setAttribute("data-translation-id", translationid);
      card.appendChild(div);
    };
  }
  setSmallSize() {
    this.fullsize = false;
    for (const card of $$(".card")) {
      card.style.maxWidth = `${$("main").width() - $$("nav").offsetWidth}px`;
    }
  }
  setFullSize() {
    this.fullsize = true;
    for (const card of $$(".card")) {
      card.style.maxWidth = `${$("main").width() + $$("nav").offsetWidth}px`;
    }
  }
  reset() {
    if (this.fullsize) { this.setFullSize(); }
    else { this.setSmallSize(); }
  }
}
