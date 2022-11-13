//Builds the cards through adding a card-content div to every card
class IconBuilder {
  constructor () {
    this.curreqcat = undefined; //CURrentlyREQuestedCATegory
    this.xhttp = new XMLHttpRequest();
    this.xhttp.onreadystatechange = function() {
        if (this.xhttp.readyState == 4 && this.xhttp.status == 200) {
           // Typical action to be performed when the document is ready:
           const data = JSON.parse(this.xhttp.responseText);
           this.iconListFromData(data);
        }
    }.bind(this);
  }
  iconListFromData(data) {
    data.push(
      {
        "title": "icons.add.title",
        "author": "MiepHD",
        "info": "icons.add.info",
        "src": "res/add.png"
      }
    );
    const div = document.querySelector(`[data-category-id=${this.curreqcat}]`);
    for (const icon of data) {
      const image = document.createElement("img");
      if (icon.title!=undefined) {
        image.setAttribute("data-title", icon.title);
      }
      if (icon.author!=undefined) {
        image.setAttribute("data-author", icon.author);
      }
      if (icon.info!=undefined) {
        image.setAttribute("data-info", icon.info);
      }
      if (icon.src!=undefined) {
        image.setAttribute("src", icon.src);
      }
      div.appendChild(image);
    }
    icons.addIntersectionObserver(div);
    icons.setIconWidths();
  }
  iconList(category) {
    this.requestIconList(category);
  }
  requestIconList(category) {
    this.curreqcat = category;
    this.xhttp.open("GET", `iconsdata/${category}.json`, true);
    this.xhttp.send();
  }
}
