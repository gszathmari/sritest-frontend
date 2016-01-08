Backbone = require 'backbone'

config = require '../helpers/config.coffee'

class StatsItem extends Backbone.Model
  parse: (item) ->
    item.stats.count = item.stats.safe + item.stats.unsafe
    item.stats.score = 100 - (item.stats.unsafe / item.stats.count) * 100
    item.mark = switch
      when item.stats.score >= 93 then "A"
      when item.stats.score >= 83 then "B"
      when item.stats.score >= 73 then "C"
      when item.stats.score >= 63 then "D"
      when isNaN(item.stats.score) is true then "NA"
      else "F"
    item.color = switch
      when item.stats.score >= 93 then "green"
      when item.stats.score >= 83 then "olive"
      when item.stats.score >= 73 then "yellow"
      when item.stats.score >= 63 then "orange"
      when isNaN(item.stats.score) is true then "blue"
      else "red"
    return item

module.exports = StatsItem
