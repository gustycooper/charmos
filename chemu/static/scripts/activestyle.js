var inputDiv;
var lwin;
var dwin;
var mwin;
var stylesheet;

var windows = [];

/**
 * Function called when the page fully loads
 */
 function onLoad2() {
    inputDiv = document.getElementById("input-container");
    inputDiv.classList.add('border-highlight');
    input = document.getElementById('user-input');
    input.addEventListener('focus',  (event) => { inputDiv.classList.add('border-highlight') });
    input.addEventListener('blur', (event) => { inputDiv.classList.remove('border-highlight') });
    
    dwin = $('#dump-window')[0];
    lwin = $('#l-window')[0];
    mwin = $('#message-window')[0];
    windows.push(dwin);
    windows.push(lwin);
    windows.push(mwin);
    makeDraggable(dwin);
    makeDraggable(lwin);
    makeDraggable(mwin);

    stylesheet = $('#theme')[0];
    $('.theme-option').click(function() {
        let themeClass = $(this).data('theme-class');
        document.cookie = themeClass;
        $('html').attr('class', themeClass);
    });

    $('#reset-button').click(function() {
        window.open("/reinitialize","_self");
    });
}

function makeForeground(ele) {
    let previousZ = ele.style.zIndex;
    for (let i = 0; i < windows.length; i++) {
        let zi = windows[i].style.zIndex;
        if (zi > previousZ) {
            windows[i].style.zIndex = zi - 1;
        }
    }
    ele.style.zIndex = windows.length;
}

// Set up onLoad to be called once the DOM for the page is fully loaded
document.addEventListener("DOMContentLoaded", onLoad2);

function makeDraggable(element) {
    var currentX, currentY, previousX, previousY;
    function doDrag(e) {
        e = e || window.event;
        e.preventDefault();
        currentX = previousX - e.clientX;
        currentY = previousY - e.clientY;
        previousX = e.clientX;
        previousY = e.clientY;
        element.style.left = (element.offsetLeft - currentX) + 'px';
        element.style.top = (element.offsetTop - currentY) + 'px';
    }
    function endDrag(e) {
        document.onmousemove = null;
        document.onmouseup = null;
    }
    function dragMouseDown(e) {
        e = e || window.event;
        e.preventDefault();
        makeForeground(element);
        previousX = e.clientX;
        previousY = e.clientY;
        document.onmousemove = doDrag;
        document.onmouseup = endDrag;
    }
    element.onmousedown = dragMouseDown;
}

let cookie = document.cookie;
if (cookie) {
    $('html').attr('class', cookie);
}