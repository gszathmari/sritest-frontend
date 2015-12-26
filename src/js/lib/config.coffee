# Endpoint addresses
api =
  url: "//api.sritest.io/api/v1/tests/"
  stats: "//api.sritest.io/api/v1/stats/"

config =
  # Backend API URL
  api: {}
  options:
    # URL validator options
    validator:
      protocols: ['http','https']
    # Retry library options
    retry:
      retries: 0
      factor: 2
      minTimeout: 1 * 1000
      maxTimeout: 120 * 1000
      randomize: true

# Select endpoint protocol
if window.location.protocol is "https:"
  config.api.url = "https:" + api.url
  config.api.stats = "https:" + api.stats
else
  config.api.url = "http:" + api.url
  config.api.stats = "http:" + api.stats

module.exports = config
