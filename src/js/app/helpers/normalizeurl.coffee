url = require 'url'

# Add missing http:// protocol to URLs
normalizeURL = (targetURL) ->
  targetURLObj = url.parse targetURL
  unless targetURLObj.protocol
    targetURL = 'http://' + targetURL
  return targetURL

module.exports = normalizeURL
