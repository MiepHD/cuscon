document.addEventListener('DOMContentLoaded', function() {
  addobject = document.getElementById("add-icon");
  lists = document.querySelectorAll(".tiles");
  for (list of lists) {
    newadd = $(addobject).clone().appendTo(list);
  }
  document.getElementById("add-icon").remove();
}, false);
