//Scirpts for the add icon
class AddIcons {
  //Adds the add icon to every category
  add() {
    var addobject = document.getElementById("add-icon");
    for (var list of document.querySelectorAll(".tiles")) {
      $(addobject).clone().appendTo(list);
    }
    //Remove original icon
    document.getElementById("add-icon").remove();
  }
}
