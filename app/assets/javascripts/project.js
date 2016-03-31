
function reloadImage(id, url, minutes) {
    setInterval(function () {
        var myImageElement = document.getElementById(id);
        myImageElement.src = url + '?rand=' + Math.random();
    }, minutes * 60000);
}