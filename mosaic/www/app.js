// source: https://www.studytonight.com/post/capture-photo-using-webcam-in-javascript
var width = 320; // We will scale the photo width to this
var height = 0; // This will be computed based on the input stream

var streaming = false;

var video = null;
var canvas = null;
var photo = null;
var startbutton = null;
var againbutton = null;
const v_ids = consts.picture.view_ids

function startup(message) {
    video = document.getElementById(v_ids.video_output);
    canvas = document.getElementById(v_ids.video_canvas);
    photo = document.getElementById(v_ids.video_snaphot_output);
    startbutton = document.getElementById(v_ids.video_snaphot_button);
    againbutton = document.getElementById(v_ids.video_redo_button);
    $('#' + v_ids.image_message).hide()
    $('#' + v_ids.upload_image_output_container).hide()
    $('#' + v_ids.video_card).show()
    $('#' + v_ids.video_snaphot_output_container).hide()

    navigator.mediaDevices.getUserMedia({
            video: true,
            audio: false
        })
        .then(function(stream) {
            video.srcObject = stream;
            video.play();
        })
        .catch(function(err) {
            console.log("An error occurred: " + err);
        });

    video.addEventListener('canplay', function(ev) {
        if (!streaming) {
            height = video.videoHeight / (video.videoWidth / width);

            if (isNaN(height)) {
                height = width / (4 / 3);
            }

            video.setAttribute('width', width);
            video.setAttribute('height', height);
            canvas.setAttribute('width', width);
            canvas.setAttribute('height', height);
            streaming = true;
        }
    }, false);

    startbutton.addEventListener('click', function(ev) {
        takepicture();
        ev.preventDefault();
    }, false);
    
    againbutton.addEventListener('click', function(ev) {
        retry();
        ev.preventDefault();
    }, false);

    clearphoto();
}


function clearphoto() {
    var context = canvas.getContext('2d');
    context.fillStyle = "#AAA";
    context.fillRect(0, 0, canvas.width, canvas.height);

    var data = canvas.toDataURL('image/png');
    photo.setAttribute('src', data);
}

function takepicture() {
    var context = canvas.getContext('2d');
    if (width && height) {
        canvas.width = width;
        canvas.height = height;
        context.drawImage(video, 0, 0, width, height);

        var data = canvas.toDataURL('image/png');
        Shiny.setInputValue("data_url", data);
        photo.setAttribute('src', data);
        $('#' + v_ids.video_card).hide()
        $('#' + v_ids.video_snaphot_output_container).show()
        
    } else {
        clearphoto();
    }
}

function retry() {
        $('#' + v_ids.video_card).show()
        $('#' + v_ids.video_snaphot_output_container).hide()
}

function show_uploaded(message) {
  $('#' + v_ids.image_message).hide()
  $('#' + v_ids.video_card).hide()
  $('#' + v_ids.video_snaphot_output_container).hide()
  $('#' + v_ids.upload_image_output_container).show()
}

Shiny.addCustomMessageHandler("take-photo", startup);
Shiny.addCustomMessageHandler("show-upload", show_uploaded);

function toggle_class(message) {
  if (message.action == "remove") {
    $('#' + message.id).removeClass(message.eclass)
  }
  if (message.action == "add") {
    $('#' + message.id).addClass(message.eclass)
  }
}
Shiny.addCustomMessageHandler("toggle-class", toggle_class);

function clear_checkbox(message) {
  $('#' + message.id + ' .checkbox').checkbox('uncheck')
}
Shiny.addCustomMessageHandler("clear-checkbox", clear_checkbox);

function toggle_visibility(message) {
  if (message.action == "show") {
    $('#' + message.id).show()
  }
  if (message.action == "hide") {
    $('#' + message.id).hide()
  }

}
Shiny.addCustomMessageHandler("toggle-view", toggle_visibility);

function app_alert(message) {
  alert(message.value)
}
Shiny.addCustomMessageHandler("app-alert", app_alert);
