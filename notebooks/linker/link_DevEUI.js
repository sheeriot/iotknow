window.onload = function() {
    var elements = document.getElementsByClassName('deveui');

    for(var i = 0; i < elements.length; i++) {
        var element = elements[i];
        var text = element.textContent;
        element.innerHTML = '<a href="https://example.com/' + text + '">' + text + '</a>';
    }
}