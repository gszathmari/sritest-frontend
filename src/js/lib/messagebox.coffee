templates = require './templates.coffee'

messageBox = (message, header = "Error", type = "negative") ->
  data =
    type: type
    header: header
    message: message
  return templates.messageBox data

module.exports = messageBox
