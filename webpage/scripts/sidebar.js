class Sidebar {
	constructor() {
		this.shown = false;
	}
	load() {
		this.sidebar = $$("#sidebar");
	}
	toggle() {
		if (this.shown) {
			this.hide();
		} else {
			this.show();
		}
	}
	reset() {
		if (!this.shown) {
			this.hide();
		} else {
			this.show();
		}
	}
	show() {
		const width = this.sidebar.offsetWidth;

		//Move sidebar
		const left = document.querySelector("body").offsetWidth - width;
		this.sidebar.style.left = `${left}px`;

		//Rotate Icon
		document.getElementById("menu").style.transform = "rotate(90deg)";

		//Resize cards
		if (!this.shown) {
			cards.setSmallSize();
		}
		this.shown = true;
		if (this.sidebar.scrollHeight > this.sidebar.clientHeight) {
			this.sidebar.style.setProperty("grid-template-rows", "16% 4% repeat(5, 16%)");
		}
	}
	hide() {
		this.sidebar.style.left = "100%";
		document.getElementById("menu").style.transform = "rotate(0deg)";
		if (this.shown) {
			cards.setFullSize();
		}
		this.shown = false;
	}
}
