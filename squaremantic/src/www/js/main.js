var width = 0;
var setSize = function() {
  var height = $("#letters").height();
  //var size = Math.min(width, height);
  /* if (width >= height) {
    $("#letters").width(size);
  } else {
    $("#letters").height(size);
  } */
  $("#letters").width(height);
  Shiny.onInputChange("wrapper_width", height);
}

$(document).on("shiny:connected", setSize);
$(window).resize(setSize);