Report = require './report.coffee'
templates = require './templates.coffee'
messageBox = require './messagebox.coffee'

pullReport = (reportID, retries = 3) ->
  # Create report object
  report = new Report reportID

  # Get report from API
  report.retrieve retries, (err, report) ->
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
      # Display summary of report
      resultsSummary = templates.resultsSummary report.summary()
      $("#results-box-summary").html(resultsSummary)
      # Display detailed results
      resultsDetailed = templates.resultsDetailed report.detailed()
      $("#results-box-detailed").html(resultsDetailed)
      # Change page title
      document.title = "SRI Report on #{report.URL()}"

module.exports = pullReport
