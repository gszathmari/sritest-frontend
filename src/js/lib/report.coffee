request = require 'request'
_ = require 'lodash'
retry = require 'retry'

config = require './config.coffee'

class Report
  constructor: (@id) ->
    @report = null

  retrieve: (retries, fn) ->
    reportObj = @
    config.options.retry['retries'] = retries
    operation = retry.operation(config.options.retry)
    operation.attempt (currentAttempt) ->
      reportObj.request (err, response) ->
        if operation.retry err
          return
        else
          return fn err, response

  request: (fn) ->
    reportObj = @
    options =
      url: config.api.url + @id
    request.get options, (err, response, body) =>
      if not err and response.statusCode is 200
        data = JSON.parse body
        @report = data.results
        return fn null, reportObj
      else
        error = new Error "Report is not available, please try again later"
        return fn error, reportObj

  get: ->
    return @report

  submitted: ->
    return @report.submitted

  id: ->
    return @id

  URL: ->
    return @report.url

  safeScripts: ->
    tags = JSON.parse @report.tags
    return tags.scripts.safe

  safeStylesheets: ->
    tags = JSON.parse @report.tags
    return tags.stylesheets.safe

  unsafeScripts: ->
    tags = JSON.parse @report.tags
    return tags.scripts.unsafe

  unsafeStylesheets: ->
    tags = JSON.parse @report.tags
    return tags.stylesheets.unsafe

  scripts: ->
    tags = JSON.parse @report.tags
    return _.union tags.scripts.safe, tags.scripts.unsafe

  stylesheets: ->
    tags = JSON.parse @report.tags
    return _.union tags.stylesheets.safe, tags.stylesheets.unsafe

  tags: ->
    tags = JSON.parse @report.tags
    return _.union tags.scripts.safe,
      tags.scripts.unsafe,
      tags.stylesheets.safe,
      tags.stylesheets.unsafe

  safeTags: ->
    tags = JSON.parse @report.tags
    return _.union tags.scripts.safe,
      tags.stylesheets.safe

  unsafeTags: ->
    tags = JSON.parse @report.tags
    return _.union tags.scripts.unsafe,
      tags.stylesheets.unsafe

  summary: ->
    data =
      url: @report.url
      submitted: @report.submitted
      statusCode: @report.statusCode
      tags:
        unsafe: @unsafeTags().length
        count: @tags().length
      scripts:
        unsafe: @unsafeScripts().length
        count: @scripts().length
      stylesheets:
        unsafe: @unsafeStylesheets().length
        count: @stylesheets().length
    score = 100 - (data.tags.unsafe / data.tags.count) * 100
    data.score = score
    data.mark = switch
      when score >= 93 then "A"
      when score >= 83 then "B"
      when score >= 73 then "C"
      when score >= 63 then "D"
      when isNaN(score) is true then "N/A"
      else "F"
    data.color = switch
      when score >= 93 then "green"
      when score >= 83 then "olive"
      when score >= 73 then "yellow"
      when score >= 63 then "orange"
      when isNaN(score) is true then "blue"
      else "red"
    return data

  detailed: ->
    data =
      scripts:
        unsafe: @unsafeScripts()
        safe: @safeScripts()
      stylesheets:
        unsafe: @unsafeStylesheets()
        safe: @safeStylesheets()
    return data

module.exports = Report
