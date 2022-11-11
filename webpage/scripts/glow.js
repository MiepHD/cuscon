class Glow{
  updatePosition(e) {
    const { currentTarget: target } = e;
    const rect = target.getBoundingClientRect(),
      x = e.clientX - rect.left,
      y = e.clientY - rect.top;

    target.style.setProperty("--mouse-x", `${x}px`);
    target.style.setProperty("--mouse-y", `${y}px`);
  }
  addMouseMoveListener() {
    for (const card of document.querySelectorAll(".card")) {
  		card.onmousemove = e => glow.updatePosition(e);
  	}
  }
}
