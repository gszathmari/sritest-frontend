$ = require 'jquery'
Backbone = require 'backbone'

Report = require '../models/report.coffee'
ReportView = require '../views/report.coffee'
Statistics = require '../collections/statistics.coffee'
StatisticsView = require '../views/statistics.coffee'

class AppRouter extends Backbone.Router
  routes:
    "" : "indexPage"
    "report/:id" : "displayReport"

  indexPage: ->
    statistics = new Statistics
    statistics.fetch()
    view = new StatisticsView {collection: statistics}
    # Revert title to original on root page
    document.title = "sritest.io - SRI Hash Website Scanner"

  displayReport: (id) ->
    report = new Report {id: id}
    view = new ReportView {model: report}
    if report.isValid()
      report.fetch()

module.exports = new AppRouter()
