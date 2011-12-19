#= require templates/current_song

class Warble.CurrentSongView extends Backbone.View
  initialize: ->
    @el = $('#playing')
    @model.bind 'change', @render, this

  template: window.JST['templates/current_song']

  render: ->
    $(@el).html this.template @model.toJSON()

    # user name tooltips on profile images
    @$('.submitter img[title]').tooltip  # TODO: dry up with SongView
      effect:   'fade'
      position: 'bottom right'
      offset:   [5, -34]

    # update browser title with artist and song
    song = @model.current_song()
    if song
      document.title = "#{song.artist}: #{song.title} \u2022 Warble"
    else
      document.title = 'Warble'

    this
