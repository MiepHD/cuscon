allicons = [];
//Builds the cards through adding a card-content div to every card
class IconBuilder {
  constructor () {
    this.curreqcat = undefined; //CURrentlyREQuestedCATegory
    const xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = () => { if (xhttp.readyState == 4 && xhttp.status == 200) allicons = JSON.parse(xhttp.responseText); };
    xhttp.open("GET", `iconsdata/icons.json`, true);
    xhttp.send();
  }
  iconList(category, data) {
    if (!data) data = allicons;
    data.push(
      {
        "title": "icons.add.title",
        "author": "MiepHD",
        "info": "icons.add.info",
        "src": "res/add.png"
      }
    );
    let div = $(`[data-category-id=${category}]`);
    div.after("<div class='tiles' id='newtiles'></div>");
    div = $("#newtiles")[0];
    for (const icon of data) {
      const image = document.createElement("img");
      if (icon.title) {
        image.setAttribute("data-title", icon.title);
        image.setAttribute("alt", icon.title);
      }
      if (icon.author) image.setAttribute("data-author", icon.author);
      if (icon.info) image.setAttribute("data-info", icon.info);
      if (icon.src) {
        if (!icon.src.includes("/")) icon.src = `icons/${icon.src}.png`;
        image.setAttribute("src", icon.src);
      }
      div.append(image);
    }
    div.removeAttribute("id");
    icons.addIntersectionObserver(div);
    icons.setIconWidths();
    return div;
  }
}
