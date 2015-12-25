config =
  # Backend API URL
  api:
    url: "http://api.sritest.io/api/v1/tests/"
    stats: "http://api.sritest.io/api/v1/stats/"
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

module.exports = config
