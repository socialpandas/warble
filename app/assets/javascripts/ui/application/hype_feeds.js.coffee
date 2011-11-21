#= require templates/hype_feeds

class Warble.HypeFeedsView extends Backbone.View
  template: -> window.JST['templates/hype_feeds']

  events:
    'click #username_search' : 'usernameSearch'
    'keypress input'         : 'handleEnter'

  initialize: ->
    _.bindAll this, 'render', 'usernameSearch', 'handleEnter'
    @el = $('#add')

  render: ->
    $(@el).html @template()
    this.delegateEvents() # TODO: fix
    this

  usernameSearch: (event) ->
    username = this.$('#username_query').val()
    window.workspace.navigate '/hype/#{username}/1', true
    event.preventDefault()

  handleEnter: (event) ->