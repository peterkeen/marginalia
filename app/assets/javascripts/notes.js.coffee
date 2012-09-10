# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $("#version_select").change ->
    path_parts = window.location.pathname.split("/")
    window.location = "/notes/" + path_parts[2] + "/versions/" + $("#version_select").val()

  $("#btn-append").tooltip({'title': "Append", 'placement': 'bottom'})

  $("#btn-edit").tooltip({'title': "Edit", 'placement': 'bottom'})

  $("#btn-share").tooltip({'title': "Share", 'placement': 'bottom'})

  $("#btn-unshare").tooltip({'title': "Unshare", 'placement': 'bottom'})

  $("#btn-info").tooltip({'title': "Info", 'placement': 'bottom'})

  $("#btn-delete").tooltip({'title': "Delete", 'placement': 'bottom'})