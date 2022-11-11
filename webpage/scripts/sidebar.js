class Sidebar {
	constructor() {
		this.shown = false;
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
		const width = document.getElementById("sidebar").offsetWidth;
		const left = document.querySelector("body").offsetWidth - width;
		const sidebar = document.getElementById("sidebar");
		sidebar.style.left = `${left}px`;
		sidebar.style.paddingTop = `${width * 1.1}px`;
		document.getElementById("menu").style.transform = "rotate(90deg)";
		this.shown = true;
	}
	hide() {
		document.getElementById("sidebar").style.left = "100%";
		document.getElementById("menu").style.transform = "rotate(0deg)";
		this.shown = false;
	}
}
