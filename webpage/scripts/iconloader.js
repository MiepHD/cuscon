class IconLoader {
  constructor() {
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
      let div = document.createElement("h3");
      div.setAttribute("data-translation-id", `category.${category.filename}`);
      div.setAttribute("data-category-id", category.filename);
      div.innerHTML = category.title;
      iconlist.append(div);
      const build = new IconBuilder();
      build.iconList(category.filename);
    }
    translate.renew();
  }
  load() {
    this.requestCategories();
  }
  requestCategories() {
    this.xhttp.open("GET", `iconsdata/index.json`, true);
    this.xhttp.send();
  }
}
