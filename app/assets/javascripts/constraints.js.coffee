# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->  
  $("#constraint_type").bind "ajax:success", (evt, data, status, xhr) ->
    # Clear and disable second subjob
    select_second_subjob = $("#constraint_subjob_two_id")
    select_second_subjob.empty()
    select_second_subjob.attr "disabled", "disabled"
    
    select = $("#constraint_subjob_one_id")
    if data isnt null
      select.removeAttr "disabled"
      select.find('option').remove()
      $("<option/>").val(null).text("").appendTo select
      $.each data, (key, value) ->
        $("<option/>").val(value["id"]).text(value["name"]).appendTo select
    else
      select.empty()
      select.attr "disabled", "disabled"
  
  $("#first_subjob").bind "ajax:success", (evt, data, status, xhr) ->
    select = $("#constraint_subjob_two_id")
    
    if data isnt null
      select.removeAttr "disabled"
      select.find('option').remove()
      $("<option/>").val(null).text("").appendTo select
      $.each data, (key, value) ->
        $("<option/>").val(value["id"]).text(value["name"]).appendTo select
    else
      select.empty()
      select.attr "disabled", "disabled"
