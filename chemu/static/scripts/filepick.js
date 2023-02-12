var chooseInputFilePicker;
var osOptionRadio;
var chooseOSFilePicker;

function validateForm() {
    if (chooseInputFilePicker.value == "") {
        alert("Please choose an input file");
        return false;
    }
    if (osOptionRadio.value == "user" && chooseOSFilePicker.value == "") {
        alert("Please choose an OS file");
        return false;
    }
    return true;
}

function onChooseOSDeselected() {
    chooseOSFilePicker.disabled = true;
}

function onChooseOSSelected() {
    chooseOSFilePicker.disabled = false;
}

function onLoad() {
    chooseOSFilePicker = $('#os-file-picker')[0];
    chooseInputFilePicker = $('#input-file-picker')[0];
    osOptionRadio = document.forms["files"]["os-choice"];
    console.log(document.cookie);
}

$(document).ready(onLoad);

let cookie = document.cookie;
if (cookie) {
    $('html').attr('class', cookie);
}