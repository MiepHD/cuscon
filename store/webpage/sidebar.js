shown = false;
function toggleSidebar() {
	if (shown) {
		hideSidebar();
	} else {
		showSidebar();
	}
}
function showSidebar() {
	if (!shown) {
		width = document.getElementById("sidebar").offsetWidth;
		left = document.querySelector("body").offsetWidth - width;
		sidebar = document.getElementById("sidebar");
		sidebar.style.left = `${left}px`;
		sidebar.style.paddingTop = `${width}px`;
		document.getElementById("menu").style.transform = "rotate(90deg)";
		shown = true;
	}
}
function hideSidebar() {
	if (shown) {
		document.getElementById("sidebar").style.left = "100%";
		document.getElementById("menu").style.transform = "rotate(0deg)";
		shown = false;
	}
}
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById("menu").addEventListener("click", toggleSidebar);
}, false);