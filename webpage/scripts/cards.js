class Cards {
  build() {
    for (const card of document.querySelectorAll(".card") ) {
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
}
