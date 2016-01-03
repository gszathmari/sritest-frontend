Stats = require './stats.coffee'
templates = require './templates.coffee'

displayStats = ->
  # Get stats
  stats = new Stats
  stats.retrieve 3, (err, stats) ->
    statsBox = templates.statsBox stats.get()
    $("#stats-box").html(statsBox).fadeIn()

module.exports = displayStats
