class Tooltip {
  add() {
    for (const link of document.querySelectorAll("a.unavailable")) {
      if (!(link.closest("span"))) { //if it has no span in it
  			const span = document.createElement("span");
        span.classList.add("unavailable-tooltip");
  			link.appendChild(span);
        span.innerHTML = translate.get("tooltip.coming-soon");
  			span.style.marginLeft = `-${span.offsetWidth / 2}px`;
      }
    }
  }
}
