function addTooltip() {
  links = document.querySelectorAll("a.unavailable");
  for (link of links) {
    if (link.children[0]==undefined) { //if it has no span in it
			span = document.createElement("span");
      span.classList.add("unavailable-tooltip");
			if (language=="de") {
				span.textContent = "Kommt später";
			} else {
				span.textContent = "Coming soon";
			}
			link.appendChild(span);
			span.style.marginLeft = `-${span.offsetWidth / 2}px`;
    }
  }
}
document.addEventListener('DOMContentLoaded', function() {
  addTooltip();
}, false);
