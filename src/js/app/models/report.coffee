Backbone = require 'backbone'
_ = require 'lodash'
validator = require 'validator'
retry = require 'retry'
request = require 'request'

config = require '../helpers/config.coffee'

class Report extends Backbone.Model
  urlRoot: config.api.url

  sync: (method, model, options) ->
    switch method
      # Retrieving a single report
      when "read"
        # Construct report URL on the API
        options.url = model.urlRoot + model.get("id")
        # Trigger the 'request' event
        model.trigger "request"
        # Call the 'request' library with 'retry'
        faultTolerantRetrieve = (url, fn) ->
          # Create 'retry' object
          operation = retry.operation(config.options.retry)
          # Launch 'retry' library
          operation.attempt (currentAttempt) ->
            # Launch HTTP request for getting the report
            request.get options.url, (err, response, body) ->
              # Handle errors like 404, which does not generate 'err'
              if not err and response.statusCode isnt 200
                err = new Error "Report not found, please try again later"
              # Submit error to 'retry' library and return
              if operation.retry err
                return
              else
                # If request is successful, return with the callback
                return fn err, body
        # We call the 'retry' library here
        faultTolerantRetrieve options.url, (err, body) =>
          # Parse API response and update model if requests are successful
          unless err
            model.set @parseResponse body
            options.success()
          # Return error if we cannot retrieve the report with multiple attempts
          else
            options.error()
      # We do not implement other RESTful methods
      else throw new Error "Method not implemented"

  parseResponse: (body) ->
    response = JSON.parse body
    report = response.results
    report.tags = JSON.parse report.tags
    # Union script and CSS tags into new object
    report.tags.all =
      safe: _.union report.tags.scripts.safe,
        report.tags.stylesheets.safe
      unsafe: _.union report.tags.scripts.unsafe,
        report.tags.stylesheets.unsafe
      sameorigin: _.union report.tags.scripts.sameorigin,
        report.tags.stylesheets.sameorigin
    # Generate statistics for detailed report
    report.tags.total =
      scripts: report.tags.scripts.safe.length +
        report.tags.scripts.unsafe.length +
        report.tags.scripts.sameorigin.length
      stylesheets: report.tags.stylesheets.safe.length +
        report.tags.stylesheets.unsafe.length +
        report.tags.stylesheets.sameorigin.length
    # Calculate percentage of same / unsafe tags
    report.score = 100 - (report.tags.all.unsafe.length /
      (report.tags.all.unsafe.length + report.tags.all.safe.length + report.tags.all.sameorigin.length)) * 100
    # Calculate grade based on score
    report.mark = switch
      when report.statusCode is "301" then "R"
      when report.statusCode is "302" then "R"
      when report.score >= 93 then "A"
      when report.score >= 83 then "B"
      when report.score >= 73 then "C"
      when report.score >= 63 then "D"
      when isNaN(report.score) is true then "NA"
      else "F"
    # Assign color based on the score
    report.color = switch
      when report.statusCode is "301" then "grey"
      when report.statusCode is "302" then "grey"
      when report.score >= 93 then "green"
      when report.score >= 83 then "olive"
      when report.score >= 73 then "yellow"
      when report.score >= 63 then "orange"
      when isNaN(report.score) is true then "blue"
      else "red"
    return report

  validate: (attrs, options) ->
    unless validator.isUUID attrs.id, 4
      return "Invalid report ID format"

module.exports = Report
