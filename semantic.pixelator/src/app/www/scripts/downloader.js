let downloadImage = function(options) {
  document.getElementById("download-message").innerHTML = `<div class="ui mini active inline loader slow double"></div> Generating ${options.name} file...`
  domtoimage.toBlob(document.getElementById(options.id))
      .then(function (blob) {
          window.saveAs(blob, `${options.name}.png`);
          document.getElementById("download-message").innerHTML = `Done!`
          setTimeout(() => {
            document.getElementById("download-message").innerHTML = ""
          }, 1000)
      });
}
Shiny.addCustomMessageHandler('downloadImage', downloadImage)

$( document ).ready(function() {
  $('#downloadImage').click(function (event) {
    document.getElementById("download-message").innerHTML = `<div class="ui mini active inline loader slow double"></div> Gathering resources...`
  });
});
