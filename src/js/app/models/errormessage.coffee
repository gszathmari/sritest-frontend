Backbone = require 'backbone'

class Error extends Backbone.Model
  defaults:
    header: "Error"
    type: "negative"
    message: "Unknown error, please try again"

module.exports = Error
