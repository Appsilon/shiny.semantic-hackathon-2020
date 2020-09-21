let RGBToHex = function(rgb) {
  rgb = rgb.split("(")[1].split(")")[0].split(", ").map(value => Math.round(value))

  let r = (+rgb[0]).toString(16),
      g = (+rgb[1]).toString(16),
      b = (+rgb[2]).toString(16);

  if (r.length == 1)
    r = "0" + r;
  if (g.length == 1)
    g = "0" + g;
  if (b.length == 1)
    b = "0" + b;

  return "#" + r + g + b;
}

let updatePaletteText = function(options) {
  let colors = options.values.split(";")
    .splice(0, 5)
    .map(entry => RGBToHex(entry.split(": ")[1]))

  Object.values(document.getElementsByClassName("palette-cell"))
    .map(cell => {
      cell.querySelector(".value").innerHTML = colors[cell.dataset.index -1]
    })
}
Shiny.addCustomMessageHandler('updatePaletteText', updatePaletteText)
