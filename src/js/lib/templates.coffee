HandleBars = require 'hbsfy/runtime'
moment = require 'moment'

templates =
  messageBox: require "../templates/messagebox.hbs"
  loader: require "../templates/loader.hbs"
  statsBox: require "../templates/statsbox.hbs"
  resultsSummary: require "../templates/results-summary.hbs"
  resultsDetailed: require "../templates/results-detailed.hbs"

HandleBars.registerHelper "generateButton", (s) ->
  if s.length > 0
    html = '<a class="ui red circular label">' + s.length + ' issues</a></div>'
  else
    html = '<a class="ui green circular label">OK</a></div>'
  return new HandleBars.SafeString html

HandleBars.registerHelper "iconize", (type) ->
  if type is "negative"
    icon = '<i class="warning sign icon"></i> '
  else
    icon = ''
  return new HandleBars.SafeString icon

HandleBars.registerHelper "formatDate", (epoch) ->
  day = moment.unix(epoch)
  return day.calendar()

HandleBars.registerHelper "truncate", (string) ->
  maxlen = 32
  if string.length > maxlen
    return string[0..maxlen] + "..."
  else
    return string

HandleBars.registerHelper "truncateSummary", (string) ->
  maxlen = 75
  if string.length > maxlen
    return string[0..maxlen] + "..."
  else
    return string

module.exports = templates
