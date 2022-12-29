class Updater {
    constructor () {
        window.addEventListener('resize', this.update);
    }
    update() {
        icons.setIconWidths();
        cards.reset();
        sidebar.reset();
        $("#menu").width($("#placeholderformenu").height());
        $("#menu").height($("#placeholderformenu").height());
        $("#sidebar").width($("#placeholderformenu").height());
    }
}