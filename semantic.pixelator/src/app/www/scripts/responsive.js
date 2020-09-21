$( window ).resize(function() {
  transformGrid();
});

$( document ).ready(function() {
  transformGrid();
});

let transformGrid = function() {
  if ($(window).width() < 1001) {
    $("#gridCells")
      .css({
        "transform": "scale(" + $(window).width() / 800 + ", " + $(window).width() / 800 + ")"
      });

  }
}
