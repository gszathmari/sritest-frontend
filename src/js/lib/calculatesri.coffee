request = require 'request'
sriToolbox = require 'sri-toolbox'

sriOptions =
  algorithms: ["sha256", "sha384", "sha512"]

calculateSRI = (url, fn) ->
  request url, (err, response, body) ->
    if not err and response.statusCode is 200
      integrity = sriToolbox.generate sriOptions, body
      return fn null, integrity
    else
      return fn err, null

module.exports = calculateSRI
