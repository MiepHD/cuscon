class Cards {
  build() {
    for (const card of document.querySelectorAll(".card") ) {
      const content = card.innerHTML, //saves the content temporarly
        div = document.createElement("div");
      card.innerHTML = ""; //Removes existing content
      div.classList.add("card-content");
      div.innerHTML = content; //adds content back
      card.appendChild(div);
    };
  }
}
