//Adds the add icon to every category
document.addEventListener('DOMContentLoaded', function() {
  addobject = document.getElementById("add-icon");
  lists = document.querySelectorAll(".tiles");
  for (list of lists) {
    newadd = $(addobject).clone().appendTo(list);
  }
  //Remove original icon
  document.getElementById("add-icon").remove();
}, false);
