//Adds the add icon to every category
document.addEventListener('DOMContentLoaded', function() {
  var addobject = document.getElementById("add-icon");
  var lists = document.querySelectorAll(".tiles");
  for (var list of lists) {
    $(addobject).clone().appendTo(list);
  }
  //Remove original icon
  document.getElementById("add-icon").remove();
}, false);
