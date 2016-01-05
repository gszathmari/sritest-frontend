request = require 'request'
validator = require 'validator'

config = require './config.coffee'
templates = require './templates.coffee'
messageBox = require './messagebox.coffee'
normalizeURL = require './normalizeurl.coffee'
pullOldReport = require './pulloldreport.coffee'
pullNewReport = require './pullnewreport.coffee'
displayStats = require './displaystats.coffee'

exports.ui = ->
  # Enable URL submit button
  $("#submit-task-form").find(":button").removeClass("disabled")

  # Activate Semantic UI elements
  $('.ui.checkbox').checkbox()
  $('.ui.dropdown').dropdown()

  # Mark 'About' button as active if page is About
  if document.URL.indexOf('about') > -1
    $('.menu-about').addClass('active')

  # Handle 'back' and 'forward' buttons
  window.onhashchange = ->
    # User navigated to main page
    if window.location.hash.substring(1) is ""
      # Hide report in case displayed
      $("#results-box").hide()
      # Display stats box
      $("#stats-box").show()

exports.run = ->
  # Target URL submitter form
  form = $("#submit-task-form")
  # Get hash from URL bar
  reportID = window.location.hash.substring(1)

  # If hash is submitted in URL bar, the user came back with a report
  if validator.isUUID reportID, 4
    # Show results box with loaders while retrieving data
    $("#results-box").show()
    $("#results-box-summary").html(templates.loader)
    $("#results-box-detailed").html(templates.loader)
    # Get report from API
    pullOldReport(reportID)
  else
    # Display report stats if website is visited without report ID in URL
    displayStats()

  # Handle URLs submited in the URL input box
  form.find(":button").click (e) ->
    # Prevent navigating from page
    e.preventDefault()
    # Save button to add and remove 'loader' to it
    button = $(this)
    # This is where URL is entered by the user
    inputField = $("#remote-url-field")
    # Get URL from the input text field
    targetURL = form.find("#remote-url").val()
    # Get value of 'hide results from stats' checkbox
    hideResults = form.find("#hide-results").is(":checked")
    # Validate user submitted URL on the client side
    unless validator.isURL targetURL, config.options.validator
      # Highlight URL input field
      inputField.addClass("error")
      # Generate error message box
      message = "You have entered an invalid value. Please check format and
        try again."
      errorMessage = messageBox message, "Invalid URL format"
      # Display error message box
      $("#message-box").html(errorMessage).children("div").slideDown().click ->
        $(this).closest(".message").slideUp()
        inputField.removeClass("error")
    # User submitted URL is valid, submit to API for processing
    else
      # Disable submit button to prevent double-submissions
      button.addClass("disabled loading")
      # Remove error highlighting from URL input field
      inputField.removeClass("error")
      # Remove error message box
      $("#message-box").children("div").slideUp()
      # Hide statistics to make room for report
      $("#stats-box").hide()
      # Show results box with loaders
      $("#results-box").show()
      $("#results-box-summary").html(templates.loader)
      $("#results-box-detailed").html(templates.loader)

      # Construct options for request library
      options =
        url: config.api.url
        # Add POST data
        form:
          url: normalizeURL targetURL
          hide: hideResults
      # Submit POST request to API
      request.post options, (err, response, body) ->
        # Re-enable submit button
        button.removeClass("disabled loading")
        # Evaluate answer back from the API
        if not err and response.statusCode is 200
          # Parse API response
          info = JSON.parse body
          # Store report ID in this variable
          reportID = info.id
          # Set URL hash with report ID
          window.location.hash = reportID
          # Pull and display report with ID
          pullNewReport(reportID)
        # Error when submitting task to remote API
        else
          message = "Oh noes :( Our service is down. Please hold on and submit
            your URL later."
          errorMessage = messageBox message
          # Hide results box and show error
          $("#results-box").hide()
          $("#message-box").html(errorMessage).children("div").slideDown().click ->
            $(this).closest(".message").slideUp()
            inputField.removeClass("error")
