currenticon = undefined;
transformtime = 500;
function setContent(icon) {
	//Variables for info
	var infoelement = document.getElementById("infobox-info");
	var info = icon.getAttribute("data-info");

	//Variables for author
	var authorelement = document.getElementById("infobox-author");
	var author = icon.getAttribute("data-author");

	//Variables for title
	//Title should be filled but don't has to be
	var titleelement = document.getElementById("infobox-title");
	var title = icon.getAttribute("data-title");

	//Sets title
	titleelement.innerHTML = title;
	titleelement.setAttribute("data-translation-id", title);

	//Sets info
	if (info==undefined) {
		infoelement.style.display = "none";
	} else {
		infoelement.innerHTML = info;
		infoelement.setAttribute("data-translation-id", info);
		infoelement.style.display = "block";
	}

	//Sets author (Only one supported)
	if (author==undefined) {
		authorelement.style.display = "none";
		//let title fill full width
		titleelement.classList.add("no-author");
	} else {
		titleelement.classList.remove("no-author");
		authorelement.innerHTML = author;
		authorelement.href = `https://github.com/${author}`;
		authorelement.style.display = "block";
	}
}
function showInfo() {
	icon = this;
	infobox = document.getElementById("infobox");
	//Hide box on old place
	infobox.style.maxHeight = "0px";
	setTimeout(function () { //Wait 'til scaling is finished
		//Completely hides infobox when clicked again on the same icon
		newicon = icon.getAttribute("position");
		if (currenticon==newicon) {
			infobox.style.display = "none";
			currenticon = undefined;
			return;
		}
		currenticon = newicon;
		setContent(icon);
		requestLanguageFile(language);
		//Add tooltip for newly added HTML
		addTooltip();
		//Move to right location and "show" the box. Note: maxHeight still 0
		infobox.style.setProperty("--length", document.getElementById("iconlist").getAttribute("length"));
		infobox.style.setProperty("--row", icon.getAttribute("row"));
		icon.parentElement.appendChild(infobox);
		infobox.style.display = "initial";
		//Actually show element
		setTimeout(function () { //Not sure why we have to wait here but when removed it instantly appears
			infobox.style.maxHeight = `${window.screen.availHeight}px`;
		}, transformtime);
	}, transformtime);
}
