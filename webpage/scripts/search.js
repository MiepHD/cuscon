class Search {
    addEventListener() {
        const iconlist = $("#iconlist");
        let div = document.createElement("h3");
        div.setAttribute("data-translation-id", "category.search");
        div.setAttribute("data-category-id", "search");
        div.innerHTML = "Search";
        iconlist.append(div);
        $$("#searchbox").addEventListener("input", function() {
            if (this.value=="") {
                this.oldSearch.remove();
                for (const card of $$(".card")) {
                    card.style.removeProperty("max-width");
                }
                $(".top").css("display", "block");
                $("[data-category-id=search]").css("display", "none");
                return;
            }
            $(".top").css("display", "none");
            $("[data-category-id=search]").css("display", "block");
            const icons = search.search(this.value);
            if (this.oldSearch) this.oldSearch.remove();
            const build = new IconBuilder();
            this.oldSearch = build.iconList("search", icons);
          });
    }
    search(query) {
        const normalizedquery = query.trim().toLowerCase().split(" ");
        const results = [];
        for (const entry of normalizedquery) {
            for (const icon of allicons) {
                for (let value of Object.values(icon)) {
                    const translation = translate.get(value);
                    if (translation) value = translation;
                    if (value.toLowerCase().includes(entry)) {
                        results.push(icon);
                        break;
                    }
                }
            }
        }
        return results;
    }
}