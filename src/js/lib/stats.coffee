request = require 'request'
retry = require 'retry'
_ = require 'underscore'

config = require './config.coffee'

class Stats
  constructor: ->
    @stats = null
    @maxResults = 5

  retrieve: (retries, fn) ->
    statsObj = @
    config.options.retry['retries'] = retries
    operation = retry.operation(config.options.retry)
    operation.attempt (currentAttempt) ->
      statsObj.request (err, response) ->
        if operation.retry err
          return
        else
          return fn err, response

  request: (fn) ->
    statsObj = @
    options =
      url: config.api.stats
    request.get options, (err, response, body) =>
      if not err and response.statusCode is 200
        @stats = @parseStats body
        return fn null, statsObj
      else
        error = new Error "Statistics is not available, please try again later"
        return fn error, statsObj

  parseStats: (body) ->
    data = JSON.parse body
    results = _.map data, (item) ->
      result =
        url: item.url
        stats:
          safe: item.stats.safe
          unsafe: item.stats.unsafe
          count: item.stats.safe + item.stats.unsafe
      result.score = 100 - (result.stats.unsafe / result.stats.count) * 100
      result.mark = switch
        when result.score >= 93 then "A"
        when result.score >= 83 then "B"
        when result.score >= 73 then "C"
        when result.score >= 63 then "D"
        when isNaN(result.score) is true then "N/A"
        else "F"
      result.color = switch
        when result.score >= 93 then "green"
        when result.score >= 83 then "olive"
        when result.score >= 73 then "yellow"
        when result.score >= 63 then "orange"
        when isNaN(result.score) is true then "blue"
        else "red"
      return result
    return results

  get: ->
    stats =
      recent: @getRecent()[0..@maxResults]
      best: @getBest()[0..@maxResults]
      worst: @getWorst()[0..@maxResults]
    return stats

  getRecent: ->
    return @stats

  getBest: ->
    stats = _.filter @stats, (item) ->
      return isNaN(item.score) isnt true
    results = _.sortBy stats, (item) ->
      return item.score
    return results.reverse()

  getWorst: ->
    stats = _.filter @stats, (item) ->
      return isNaN(item.score) isnt true
    results = _.sortBy stats, (item) ->
      return item.score
    return results.reverse()

module.exports = Stats
