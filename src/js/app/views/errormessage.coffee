$ = require 'jquery'
Backbone = require 'backbone'
HandleBars = require 'hbsfy/runtime'
Backbone.$ = $

ErrorMessage = require '../models/errormessage.coffee'
messageBoxTemplate = require '../templates/messagebox.hbs'

class ErrorMessageView extends Backbone.View
  tagName: "div"
  id: "#message-box"
  template: messageBoxTemplate
  model: new ErrorMessage

  render: ->
    $(@id).html(@template @model.attributes)
    # Hide error message if user clicks on 'X'
    $(@id).children("div").slideDown().click ->
      $(this).closest(".message").slideUp()
      $("#remote-url-field").removeClass("error")
    # Highlight URL bar if error message contains the word "URL"
    if @model.attributes.message.indexOf("URL") > 0
      $("#remote-url-field").addClass("error")

  # Remove all errors from the page
  clear: ->
    $(@id).empty()
    $("#remote-url-field").removeClass("error")

module.exports = ErrorMessageView

# Assigns small icon to the error message
HandleBars.registerHelper "iconize", (type) ->
  if type is "negative"
    icon = '<i class="warning sign icon"></i> '
  else
    icon = ''
  return new HandleBars.SafeString icon
