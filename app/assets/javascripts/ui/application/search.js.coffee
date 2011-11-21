#= require templates/search

# TODO: abstract some of this stuff out to a generic
#       search class that Youtube can share
class Warble.SearchView extends Backbone.View
  template: -> window.JST['templates/search']

  events:
    'click #library_search' : 'search'
    'keypress input'        : 'handleEnter'
    'click a.result'        : 'queueVideo'

  initialize: ->
    _.bindAll this, 'render', 'search', 'handleEnter', 'queueVideo'
    @collection = new Warble.SearchList
    @collection.bind 'all', @render
    @el = $('#add')

  render: ->
    $(@el).html @template()
      query:   @collection.query
      results: @collection.toJSON()
    this.$('#search_query').focus()
    this.delegateEvents()  # TODO: fix

  handleEnter: (event) ->
    if event.which == 13
      this.search event

  search: (event) ->
    @collection.query = this.$('#search_query').val()

    window.workspace.showSpinner()
    @collection.fetch
      success: -> window.workspace.hideSpinner()
      error: ->
        window.workspace.navigate '/', true
        window.workspace.hideSpinner()

    event.preventDefault()

  queueVideo: (event) ->
    window.workspace.showSpinner()

    song_id = $(event.currentTarget).attr('data-id')
    $.post '/jukebox/songs',
      'song_id[]': [song_id]

    window.workspace.hideSpinner()
    event.preventDefault()
