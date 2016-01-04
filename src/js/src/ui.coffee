$(document).ready ->
  $('.ui.checkbox').checkbox()
  $('.ui.dropdown').dropdown()

  # Mark 'About' button as active if page is About
  if document.URL.indexOf('about') > -1
    $('.menu-about').addClass('active')
