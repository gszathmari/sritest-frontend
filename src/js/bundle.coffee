domready = require 'domready'

app = require './lib/app.coffee'

# Only run when document.ready
domready ->
  # Activate UI elements
  app.ui()
  # Run main code
  app.run()
