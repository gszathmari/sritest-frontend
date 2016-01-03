Report = require './report.coffee'
templates = require './templates.coffee'
messageBox = require './messagebox.coffee'

pullNewReport = (reportID, retries = 8) ->
  report = new Report reportID
  report.retrieve retries, (err, report) ->
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
      # Change page title
      document.title = "SRI Report on #{report.URL()}"
      # Scroll down to results
      $("body").animate({scrollTop: $("#results-box").offset().top - 100 }, 'slow')

module.exports = pullNewReport
