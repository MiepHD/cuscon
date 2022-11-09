document.addEventListener('DOMContentLoaded', function() {
  for (card of document.querySelectorAll(".card") ) {
    content = card.innerHTML;
    card.innerHTML = "";
    div = document.createElement("div");
    div.classList.add("card-content");
    div.innerHTML = content;
    card.appendChild(div);
  };
}, false);
