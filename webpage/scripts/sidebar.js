class Sidebar {
	constructor() {
		this.shown = false;
	}
	load() {
		this.sidebar = $$("nav");
	}
	toggle() {
		if (this.shown) { this.hide(); }
		else { this.show(); }
	}
	reset() {
		if (!this.shown) { this.hide(); }
		else { this.show(); }
	}
	show() {
		this.sidebar.setAttribute("state", "shown");
		$$("#menu").setAttribute("aria-expanded", "true");

		//Resize cards
		if (!this.shown) cards.setSmallSize();
		this.shown = true;
		if (this.sidebar.scrollHeight > this.sidebar.clientHeight) {
			this.sidebar.style.setProperty("grid-template-rows", "16% 84%");
			$$("#primary-navigation").style.setProperty("grid-template-rows", "6.66% repeat(5, 18.66%)");
		} else if ($$("#normal-size").offsetWidth * 6.4 < this.sidebar.clientHeight) {
			this.sidebar.style.removeProperty("grid-template-rows");
			$$("#primary-navigation").style.removeProperty("grid-template-rows");
		}
	}
	hide() {
		this.sidebar.setAttribute("state", "hiding");
		this.sidebar.addEventListener("animationend", () => {
			this.sidebar.setAttribute("state", "hidden");
		}, {once: true});
		$$("#menu").setAttribute("aria-expanded", "false");
		if (this.shown) cards.setFullSize();
		this.shown = false;
	}
}
