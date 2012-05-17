(function () {
    var t = document.title;
    var l = window.location;
    var f = 'peter.keen@bugsplat.info';
    window.open("https://bugsplat-notes.herokuapp.com/notes/new?note[title]="+t+"&note[body]=%23bookmark%0A%0A"+l+"&note[from_address]="+f);
})();

