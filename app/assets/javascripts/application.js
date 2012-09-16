// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require_tree .

$(function() {
  $.tablesorter.addWidget({
    // give the widget an id
    id: "sortPersist",
    // format is called when the on init and when a
    // sorting has finished
    format: function(table) {
 
      // Cookie info
      var cookieName = 'MY_SORT_COOKIE';
      var cookie = $.cookie(cookieName);
      var options = {path: '/'};
 
      var data = {};
      var sortList = table.config.sortList;
      var tableId = $(table).attr('id');
      var cookieExists = (typeof(cookie) != "undefined"
          && cookie != null);
 
      // If the existing sortList isn't empty, set it into the cookie
      // and get out
      if (sortList.length > 0) {
        if (cookieExists) {
          data = JSON.parse(cookie);
        }
        data[tableId] = sortList;
        $.cookie(cookieName, JSON.stringify(data), options);
      }
 
      // Otherwise...
      else {
        if (cookieExists) { 
 
          // Get the cookie data
          var data = JSON.parse($.cookie(cookieName));
 
          // If it exists
          if (typeof(data[tableId]) != "undefined"
              && data[tableId] != null) {
 
            // Get the list
            sortList = data[tableId];
 
            // And finally, if the list is NOT empty, trigger
            // the sort with the new list
            if (sortList.length > 0) {
              $(table).trigger("sorton", [sortList]);
            }
          }
        }
      }
    }
  });
  $("table.sorted").tablesorter({widgets: ['sortPersist']});

    $('.sidenav').affix({
      offset: {
          top: 0
      , bottom: 270
      }
    })

});

$(function() {
    $(".draghandle").draggable({
		appendTo: "body",
		helper: "clone",
        revert: "valid",
        start: function() {
            $(".dragtarget").addClass("highlight");
        },
        stop: function() {
            $(".dragtarget").removeClass("highlight");
        }
    });
});

$(function() {
    $(".dragtarget").droppable({
        activeClass: "ui-state-hover",
        hoverClass: "ui-state-active",
        drop: function(event, ui) {
            var href = ui.draggable[0].parentNode.parentNode.children[0].firstChild.href;
            var project_id = parseInt(this.firstChild.href.split(/\//)[4]);

            $.ajax({
                url: href + ".json",
                type: 'PUT',
                data: {
                    "note[project_id]": project_id
                },
                complete: function(xhr, textStatus) {
                    console.log(xhr);
                    location.reload(true);
                },
                error: function(xhr, textStatus, errorThrown) {
                    console.log(xhr);
                }
            });
            
            $(".dragtarget").removeClass("highlight");
            $(this).effect("highlight", {}, 500);
        }
    });
});

$(function() {
    $(".wordcount").bind('keyup click blur focus change paste', function() {
        var control = $(this);

        if (!this["wordcount-target"]) {
            this["wordcount-target"] = $(control.attr("data-wordcount-target"));
        }
        var numwords = 0;
        if (control.val() === '') {
            numwords = 0;
        } else {
            var matches = jQuery.trim(control.val()).match(/\w+/g);
            numwords = matches.length;
        }

        this["wordcount-target"].text(numwords);
    });
});