shown = false;
function toggleSidebar() {
	if (shown) {
		hideSidebar();
	} else {
		showSidebar();
	}
}
function resetSidebar() {
	if (!shown) {
		hideSidebar();
	} else {
		showSidebar();
	}
}
function showSidebar() {
	width = document.getElementById("sidebar").offsetWidth;
	left = document.querySelector("body").offsetWidth - width;
	sidebar = document.getElementById("sidebar");
	sidebar.style.left = `${left}px`;
	sidebar.style.paddingTop = `${width * 1.1}px`;
	document.getElementById("menu").style.transform = "rotate(90deg)";
	shown = true;
}
function hideSidebar() {
	document.getElementById("sidebar").style.left = "100%";
	document.getElementById("menu").style.transform = "rotate(0deg)";
	shown = false;
}
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById("menu").addEventListener("click", toggleSidebar);
		window.addEventListener('resize', function() {
			resetSidebar()
		});
}, false);
