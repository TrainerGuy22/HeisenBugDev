#ajax call to show flash messages when they are transmitted in the header
#this code assumes the following
# 1) you're using twitter-bootstrap 2.3 (although it will work if you don't)
# 2) you've got a div with the id flash_hook somewhere in your html code
show_ajax_message = (msg, type) ->
  $("#flash-message").html "<div id='flash-#{type}' class='alert-box #{type} radius'><a href='#' class='close'>&times;</a>#{msg}</div>"
  width = 250
  right = (($(document).width() - $('#top-bar').width()) / 2)
  top = $('#top-bar').height() + 15
  $("#flash-#{type}").css 'right', right
  $("#flash-#{type}").css 'top', top
  $("#flash-#{type}").css 'width', width
  $("#flash-#{type}").delay(3000).slideUp()

root = exports ? this
root.show_ajax_message = show_ajax_message

$(document).ajaxComplete (event, request) ->
  msg = request.getResponseHeader("X-Message")
  type = request.getResponseHeader("X-Message-Type")
  show_ajax_message msg, type