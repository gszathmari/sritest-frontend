$(document).ready ->
  $("#submit-task-form").find(":button").click ->
    form = $("#submit-task-form")
    data =
      url: form.find("#remote-url").val()
      hide: form.find("#hide-results").is(":checked")
    analytics.track 'Submitted URL', data
