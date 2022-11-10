//Builds the cards through adding a card-content div to every card
class Builder {
  cards() {
    for (var card of document.querySelectorAll(".card") ) {
      var content = card.innerHTML; //saves the content temporarly
      card.innerHTML = ""; //Removes existing content
      var div = document.createElement("div");
      div.classList.add("card-content");
      div.innerHTML = content; //adds content back
      card.appendChild(div);
    };
  }
}
