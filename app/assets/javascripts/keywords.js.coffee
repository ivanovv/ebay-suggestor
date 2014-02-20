# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ($) ->
  $keyword = $ '#keyword_value'

  $keyword.keydown =>
    val = $keyword.val()
    $(".counter .user-input").text(val.length)
    $(".counter .user-input").toggleClass("red", val.length > 79)

  $keyword.keyup =>
    val = $.trim($keyword.val())
    if val != ''
      $keyword.parent().removeClass 'has-error'


  $('form#new_keyword').submit =>
    if $.trim($keyword.val()) == ''
      $keyword.parent().addClass 'has-error'
      false
