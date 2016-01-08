Backbone = require 'backbone'
_ = require 'lodash'

config = require '../helpers/config.coffee'
StatsItem = require '../models/statsitem.coffee'

class Statistics extends Backbone.Collection
  model: StatsItem
  url: config.api.stats

  parse: (statsCollection) ->
    # Remove items where the number of tags is 0
    result = _.filter statsCollection, (statsItem) ->
      return statsItem.stats.safe + statsItem.stats.unsafe > 0
    return result

  getWorst: ->
    sortedCollection = _.sortBy @models, (statsItem) ->
      return statsItem.attributes.stats.score
    result = _.pluck sortedCollection, 'attributes'
    return result[0..7]

  getBest: ->
    sortedCollection = _.sortBy @models, (statsItem) ->
      return statsItem.attributes.stats.score
    result = _.pluck sortedCollection, 'attributes'
    return result.reverse()[0..7]

  getRecent: ->
    result = _.pluck @models, 'attributes'
    return result[0..7]

module.exports = Statistics
