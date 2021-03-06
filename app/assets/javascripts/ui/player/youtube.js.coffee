#= require swfobject

class Warble.YoutubePlayerView extends Backbone.View
  el: '#ytplayer_wrapper'

  initialize: ->
    @model.current_play.bind 'change:id', @render, this
    @model.bind 'change:volume', @volume, this

    # youtube apis make you do this global function junk
    window.handleYoutubeStateChange = (state) =>
      if state == 0  # done playing
        @finished()

    window.handleYoutubeError = =>
      @finished()

    window.onYouTubePlayerReady = =>
      @player = document.getElementById 'ytplayer'
      @player.addEventListener 'onStateChange', 'handleYoutubeStateChange'
      @player.addEventListener 'onError', 'handleYoutubeError'

    window.swfobject.embedSWF 'http://www.youtube.com/apiplayer?version=3&enablejsapi=1&playerapiid=ytplayer',
      'ytplayer', '100%', '100%', '8', null, null,
      { allowScriptAccess: 'always'},
      { id: 'ytplayer'}

  render: ->
    if !@player
      # make sure the slow-ass widget has loaded first
      window.setTimeout (=> @render()), 500
    else
      @player.pauseVideo()
      if @pending_volume?
        @player.setVolume @pending_volume
        delete @pending_volume
      if @model.current_play.get('song')?.source == 'youtube'
        @$('#ytplayer').css('visibility', 'visible')
        @player.loadVideoById @model.current_play.get('song').external_id
      else
        @$('#ytplayer').css('visibility', 'hidden')

  volume: ->
    vol = @model.get 'volume'
    if @player
      @player.setVolume vol
    else
      @pending_volume = vol

  finished: ->
    $.post '/jukebox/skip'
