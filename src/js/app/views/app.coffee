$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$ = $
request = require 'request'
validator = require 'validator'
Transition = require 'semantic-ui-transition'
Checkbox = require 'semantic-ui-checkbox'
Dropdown = require 'semantic-ui-dropdown'

Router = require '../routers/router.coffee'
normalizeURL = require '../helpers/normalizeurl.coffee'
config = require '../helpers/config.coffee'
ErrorMessageView = require '../views/errormessage.coffee'

$.fn.checkbox = Checkbox
$.fn.transition = Transition
$.fn.dropdown = Dropdown

class AppView extends Backbone.View
  el: $ 'body'

  initialize: ->
    # Activate checkbox under URL input box
    $('.ui.checkbox').checkbox()
    # Activate dropdown menu in top menu bar
    $('.ui.dropdown').dropdown()
    # Remove main dimmer when the page is fully loaded
    $('#main-dimmer').removeClass("active")
    # Store URL input form
    @form = $("#submit-task-form")
    # Start Backbone router
    Backbone.history.start()
    # Clear error message box
    @errorMessage = new ErrorMessageView

  events: ->
    "click #submit-task-form :button" : "submitURL"

  # Submit URL to API for generating a report
  submitURL: (e) ->
    e.preventDefault()
    # Get URL from the input text field and normalize
    targetURL = normalizeURL @form.find("#remote-url").val()
    # Get value of 'hide results from stats' checkbox
    hideResults = @form.find("#hide-results").is(":checked")
    # Validate submitted URL
    unless validator.isURL targetURL, config.options.validator
      m = "The URL format is invalid. Please check the URL and try again."
      @errorMessage.model.set {message: m}
      @errorMessage.render()
    else
      # Clear any leftover errors
      @errorMessage.clear()
      # Options for 'request' library
      postOptions =
        url: config.api.url
        # POST data
        form:
          url: targetURL
          hide: hideResults
      request.post postOptions, (err, response, body) ->
        # Request is successful
        if not err and response.statusCode is 200
          # Parse API response
          result = JSON.parse body
          # Navigate Backbone router to display report
          Router.navigate "report/" + result.id, {trigger: true}
        else
          m = "We could not scan the remote website. Please check your URL
            and try again."
          @errorMessage.model.set {message: m}
          @errorMessage.render()

module.exports = AppView
