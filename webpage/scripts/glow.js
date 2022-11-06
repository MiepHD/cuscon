//Create the glow effect for all cards
document.addEventListener('DOMContentLoaded', function() {
  const handleOnMouseMove = e => {
		const { currentTarget: target } = e;
		const rect = target.getBoundingClientRect(),
			x = e.clientX - rect.left,
			y = e.clientY - rect.top;

		target.style.setProperty("--mouse-x", `${x}px`);
		target.style.setProperty("--mouse-y", `${y}px`);
	}
  //addEventListener for all cards
	for (const card of document.querySelectorAll(".card")) {
		card.onmousemove = e => handleOnMouseMove(e);
	}
}, false);
