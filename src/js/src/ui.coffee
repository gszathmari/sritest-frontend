$(document).ready ->
  $('.ui.checkbox').checkbox()
  $('.ui.dropdown').dropdown()

  # Mark 'About' button as active if page is About
  if document.URL.includes 'about'
    $('.menu-about').addClass('active')
