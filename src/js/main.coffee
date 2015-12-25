request = require 'request'
$ = require 'jquery-browserify'
validator = require 'validator'

config = require './lib/config.coffee'
Report = require './lib/report.coffee'
Stats = require './lib/stats.coffee'
templates = require './lib/templates.coffee'
messageBox = require './lib/messagebox.coffee'
normalizeURL = require './lib/normalizeurl.coffee'

# Target URL submitter form
form = $("#submit-task-form")
# Get hash from URL bar
reportID = window.location.hash.substring(1)

# If hash is submitted in URL bar, the user came back with a report
if validator.isUUID reportID, 4
  # Show results box with loaders
  $("#results-box").show()
  $("#results-box-summary").html(templates.loader)
  $("#results-box-detailed").html(templates.loader)
  report = new Report reportID
  report.retrieve 3, (err, report) ->
    # If cannot retrieve report
    if err
      $("#results-box").hide()
      message = "We could not retrieve your report. Please allow your scan
          to finish or submit the URL again."
      errorMessage = messageBox message, "Report not found"
      $("#message-box").html(errorMessage).children("div").slideDown().click ->
        $(this).closest(".message").slideUp()
        inputField.removeClass("error")
    # Report is found, generate output and display
    else
      resultsSummary = templates.resultsSummary report.summary()
      $("#results-box-summary").html(resultsSummary)
      resultsDetailed = templates.resultsDetailed report.detailed()
      $("#results-box-detailed").html(resultsDetailed)
else
  # Get stats
  stats = new Stats
  stats.retrieve 3, (err, stats) ->
    statsBox = templates.statsBox stats.get()
    $("#stats-box").html(statsBox).fadeIn()

form.find(":button").click (e) ->
  # Prevent navigating from page
  e.preventDefault()
  button = $(this)
  inputField = $("#remote-url-field")
  targetURL = form.find("#remote-url").val()
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
        report = new Report reportID
        report.retrieve 8, (err, report) ->
          # If cannot retrieve report from API
          if err
            message = "We could not scan the remote website. Please check your URL
              and try again."
            errorMessage = messageBox message
            $("#results-box").hide()
            $("#message-box").html(errorMessage).children("div").slideDown().click ->
              $(this).closest(".message").slideUp()
              inputField.removeClass("error")
          # Report is found, generate output and display
          else
            # Generate summary of report
            resultsSummary = templates.resultsSummary report.summary()
            $("#results-box-summary").html(resultsSummary)
            # Generate detailed report
            resultsDetailed = templates.resultsDetailed report.detailed()
            $("#results-box-detailed").html(resultsDetailed)
            # Scroll down to results
            $("body").animate({scrollTop: $("#results-box").offset().top - 100 }, 'slow')
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
