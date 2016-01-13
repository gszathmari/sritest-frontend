$ = require 'jquery'
Backbone = require 'backbone'
HandleBars = require 'hbsfy/runtime'
moment = require 'moment'
$.fn.popup = require 'semantic-ui-popup'
Backbone.$ = $

ErrorMessageView = require '../views/errormessage.coffee'
reportTemplate = require '../templates/report.hbs'

class ReportView extends Backbone.View
  tagName: "div"
  id: "#main-content"
  template: reportTemplate

  initialize: ->
    # Store <div> where we will insert contents into
    @contents = $("#contents")
    # Validation error on the client side
    @listenTo @model, "invalid", @displayError
    # Error retrieving the report from the API
    @listenTo @model, "error", @displayErrorAPI
    # Show / hide loaders
    @listenTo @model, "request", @displayLoader
    @listenTo @model, "error", @removeLoader
    @listenTo @model, "sync", @removeLoader
    # API returns the report
    @listenTo @model, "sync", @render

  # Add loader to submit button
  displayLoader: ->
    $("#submit-task-form button").addClass("loading disabled")

  # Remove loader to submit button
  removeLoader: ->
    $("#submit-task-form button").removeClass("loading disabled")

  render: ->
    # Generate HTML for report
    $(@id).hide().html(@template @model.attributes).show()
    # Change page title
    document.title = "SRI Report on #{@model.get("url")}"
    # Scroll down to results
    $("body").animate({scrollTop: $("#results-box").offset().top - 100 }, 'slow')
    # Activate tooltips
    $("#grade-large").popup({position: 'right center', target: '.ui.header.grade'})
    $("#grade-small").popup({position: 'right center'})
    return @

  displayError: (error) ->
    errorMessage = new ErrorMessageView
    m = "The report with this report ID is not found. Please check your ID or
      submit a website scan again."
    errorMessage.model.set {message: m}
    errorMessage.render()
    return @

  displayErrorAPI: (error) ->
    errorMessage = new ErrorMessageView
    m = "Uh-oh :( There is a problem with our service. Please try again later."
    errorMessage.model.set {message: m}
    errorMessage.render()
    return @

module.exports = ReportView
