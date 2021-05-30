function oneFn() {
    $('#one').val("`main.js` loaded");
}

function threeFn() {
    $.get('/api/status', text => {
        $('#three').val(text);
    });
}

function fourFn() {
    $.getJSON('/api/status.json', json => {
        $('#four').val(JSON.stringify(json, null, '  '));
    });
}

function twoFn() {
    $.get('/api/text', text => {
        $('#two').val(text);

        threeFn();
        fourFn();
    });
}

$(function() {
    oneFn();
    twoFn();
});