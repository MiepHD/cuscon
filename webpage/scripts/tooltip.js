class Tooltip {
  add() {
    const links = document.querySelectorAll("a.unavailable");
    for (const link of links) {
      if (link.closest("span")==undefined) { //if it has no span in it
  			const span = document.createElement("span");
        span.classList.add("unavailable-tooltip");
        span.setAttribute("data-translation-id", "tooltip.coming-soon");
  			link.appendChild(span);
        translate.renew();
  			span.style.marginLeft = `-${span.offsetWidth / 2}px`;
      }
    }
  }
}
