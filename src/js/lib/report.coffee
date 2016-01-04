request = require 'request'
_ = require 'lodash'
retry = require 'retry'

config = require './config.coffee'

class Report
  constructor: (@id) ->
    @report = null
    @tags = null

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
        @tags = @parseTags data.results
        return fn null, reportObj
      else
        error = new Error "Report is not available, please try again later"
        return fn error, reportObj

  parseTags: (report) ->
    tags = JSON.parse report.tags
    return tags

  get: ->
    return @report

  submitted: ->
    return @report.submitted

  id: ->
    return @id

  URL: ->
    return @report.url

  safeScripts: ->
    return @tags.scripts.safe

  safeStylesheets: ->
    return @tags.stylesheets.safe

  sameOriginScripts: ->
    return @tags.scripts.sameorigin

  sameOriginStylesheets: ->
    return @tags.stylesheets.sameorigin

  unsafeScripts: ->
    return @tags.scripts.unsafe

  unsafeStylesheets: ->
    return @tags.stylesheets.unsafe

  scripts: ->
    return _.union @tags.scripts.safe,
      @tags.scripts.unsafe,
      @tags.scripts.sameorigin

  stylesheets: ->
    return _.union @tags.stylesheets.safe,
      @tags.stylesheets.unsafe,
      @tags.stylesheets.sameorigin

  safeTags: ->
    return _.union @tags.scripts.safe,
      @tags.stylesheets.safe

  unsafeTags: ->
    return _.union @tags.scripts.unsafe,
      @tags.stylesheets.unsafe

  getAllTags: ->
    return _.union @tags.scripts.safe,
      @tags.scripts.unsafe,
      @tags.scripts.sameorigin,
      @tags.stylesheets.safe,
      @tags.stylesheets.unsafe,
      @tags.stylesheets.sameorigin

  summary: ->
    data =
      url: @report.url
      submitted: @report.submitted
      tags:
        unsafe: @unsafeTags().length
        count: @getAllTags().length
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
      when isNaN(score) is true then "NA"
      else "F"
    data.color = switch
      when score >= 93 then "green"
      when score >= 83 then "olive"
      when score >= 73 then "yellow"
      when score >= 63 then "orange"
      when isNaN(score) is true then "blue"
      else "red"
    data.statusCode = switch
      when @report.statusCode is "200" then "200 OK"
      when @report.statusCode is "301" then "301 Moved Permanently"
      when @report.statusCode is "302" then "302 Found"
      when @report.statusCode is "404" then "404 Not Found"
      when @report.statusCode is "500" then "500 Internal Server Error"
      else @report.statusCode
    return data

  detailed: ->
    data =
      scripts:
        unsafe: @unsafeScripts()
        safe: @safeScripts()
        sameorigin: @sameOriginScripts()
      stylesheets:
        unsafe: @unsafeStylesheets()
        safe: @safeStylesheets()
        sameorigin: @sameOriginStylesheets()
    data.scripts.tags = _.union data.scripts.unsafe,
      data.scripts.safe, data.scripts.sameorigin
    data.stylesheets.tags = _.union data.stylesheets.unsafe,
      data.stylesheets.safe, data.stylesheets.sameorigin
    return data

module.exports = Report
