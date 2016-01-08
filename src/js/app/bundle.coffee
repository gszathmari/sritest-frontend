domready = require 'domready'
$ = require 'jquery'

AppView = require './views/app.coffee'


# Only run when document.ready
domready ->
  #console.log "App is starting"
  new AppView()
