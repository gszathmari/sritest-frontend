# Activate 'About' menu in top menu bar
$(document).ready ->
  if document.URL.indexOf("about") > 0
    $("#menu-about").addClass("active")
