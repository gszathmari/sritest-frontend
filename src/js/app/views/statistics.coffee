$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$ = $

statisticsTemplate = require '../templates/statistics.hbs'
HandleBars = require '../helpers/handlebars.coffee'

class StatisticsView extends Backbone.View
  tagName: "div"
  id: "#main-content"
  template: statisticsTemplate

  initialize: ->
    # Store <div> where we will insert contents into
    @contents = $("#contents")
    # API returns the report
    @listenTo @collection, "sync", @render

  render: ->
    context =
      recent: @collection.getRecent()
      best: @collection.getBest()
      worst: @collection.getWorst()
    $(@id).hide().html(@template context).fadeIn()
    return @

module.exports = StatisticsView
