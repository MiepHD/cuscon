class IconLoader {
  constructor() {
    this.build = new IconBuilder();
    this.xhttp = new XMLHttpRequest();
    this.xhttp.onreadystatechange = function() {
        if (this.xhttp.readyState == 4 && this.xhttp.status == 200) {
           const data = JSON.parse(this.xhttp.responseText);
           this.constructFromData(data);
        }
    }.bind(this);
  }
  constructFromData(data) {
    const iconlist = $("#iconlist");
    for (const category of data) {
      const id = category.id;
      let div = document.createElement("h3");
      div.setAttribute("data-translation-id", `category.${id}`);
      div.setAttribute("data-category-id", id);
      div.innerHTML = category.title;
      iconlist.append(div);
      this.build.iconList(id);
    }
    translate.renew();
  }
  load() {
    this.requestCategories();
  }
  requestCategories() {
    this.xhttp.open("GET", `iconsdata/categories.json`, true);
    this.xhttp.send();
  }
}
