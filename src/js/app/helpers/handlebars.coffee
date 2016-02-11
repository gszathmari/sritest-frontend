HandleBars = require 'hbsfy/runtime'
moment = require 'moment'

# Generate small OK / NOK icons on the top of the detailed report
HandleBars.registerHelper "generateButton", (s) ->
  if s.length > 0
    html = '<a class="ui red circular label">' + s.length + ' issues</a></div>'
  else
    html = '<a class="ui green circular label">OK</a></div>'
  return new HandleBars.SafeString html

# Convert Unix time to human readable format in report summary
HandleBars.registerHelper "formatDate", (epoch) ->
  day = moment.unix(epoch)
  return day.calendar()

# Shorten URL in report summary
HandleBars.registerHelper "truncateSummary", (string) ->
  maxlen = 70
  if string.length > maxlen
    return string[0..maxlen] + "..."
  else
    return string

# Add user friendly HTTP status code messages
HandleBars.registerHelper "friendlyStatusCode", (statusCode) ->
  friendlyStatusCode = switch
    when statusCode is "200" then "200 OK"
    when statusCode is "301" then "301 Moved Permanently (Redirect)"
    when statusCode is "302" then "302 Found (Redirect)"
    when statusCode is "404" then "404 Not Found"
    when statusCode is "500" then "500 Internal Server Error"
    else statusCode
  return friendlyStatusCode

# Generate stats in summary: 'X unsafe / Y safe tags'
HandleBars.registerHelper "generateSummaryTagCount", (tags) ->
  unsafe = tags.all.unsafe.length
  safe = tags.all.safe.length + tags.all.sameorigin.length
  rate = 100 - ((unsafe / (safe + unsafe)) * 100)
  rateFixed = switch
    when isNaN(rate) then "not applicable"
    else "#{rate.toFixed(1)}%"
  html = "Rate: #{rateFixed}"
  return new HandleBars.SafeString html

# Generate number of safe tags out of SRI protected and same-origin
HandleBars.registerHelper "countSafeTags", (tags) ->
  count = tags.safe.length + tags.sameorigin.length
  return count

HandleBars.registerHelper "generateGradePopupContent", (tags) ->
  unsafe = tags.all.unsafe.length
  safe = tags.all.safe.length + tags.all.sameorigin.length
  count = safe + unsafe
  rate = 100 - ((unsafe / (safe + unsafe)) * 100)
  rateFixed = switch
    when isNaN(rate) then "not applicable as we detected URL redirection"
    else "#{rate.toFixed(1)}%"
  grade = switch
      when rate >= 93 then "A"
      when rate >= 83 then "B"
      when rate >= 73 then "C"
      when rate >= 63 then "D"
      when isNaN(rate) is true then "R"
      else "F"
  html = """
    <h3 class="ui header">Grading</h3>
    <div class="ui list">
      <div class="item"><strong>A</strong> : 93% &mdash; 100%</div>
      <div class="item"><strong>B</strong> : 83% &mdash; 93%</div>
      <div class="item"><strong>C</strong> : 73% &mdash; 83%</div>
      <div class="item"><strong>D</strong> : 63% &mdash; 73%</div>
      <div class="item"><strong>F</strong> : 0% &mdash; 63%</div>
    </div>
    <p>Your grade is based on the (1) number of unsafe assets and the (2) total number of assets<p>
    <p>We found #{unsafe} unsafe assets out of the total of #{count} assets</p>
    <p>The rate of these two numbers is #{rateFixed}, which provides your grade: '#{grade}'</p>
  """
  return html

# Generate number of unsafe tags
HandleBars.registerHelper "countUnsafeTags", (tags) ->
  count = tags.unsafe.length
  return count

module.exports = HandleBars
