#= require templates/hype_songs

# TODO: the lack of abstraction is getting annoying. DRY up
class Warble.HypeSongsView extends Backbone.View
  template: -> window.JST['templates/hype_songs']

  events:
    'click a.result' : 'queueSong'

  initialize: ->
    _.bindAll this, 'render', 'queueSong'
    @collection.bind 'all', @render
    @el = $('#add')

  render: ->
    $(@el).html @template()
      feed:  @collection.feed
      songs: @collection.toJSON()
    window.workspace.hideSpinner()
    this.delegateEvents()  # TODO: fix

  queueSong: (event) ->
    window.workspace.showSpinner()

    song_id = $(event.currentTarget).attr('data-id')
    $.post '/jukebox/songs',
      'song_id[]': [song_id]

    window.workspace.hideSpinner()
    event.preventDefault()