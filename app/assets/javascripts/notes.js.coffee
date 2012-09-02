# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $("#version_select").change ->
    path_parts = window.location.pathname.split("/")
    window.location = "/notes/" + path_parts[2] + "/versions/" + $("#version_select").val()