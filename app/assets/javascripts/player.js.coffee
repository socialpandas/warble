#= require handlebars.1.0.0.beta.3
#= require jquery
#= require jquery-ui
#= require rails/csrf
#= require underscore
#= require backbone
#= require faye-browser

#= require_self

#= require_tree ./components
#= require models/jukebox
#= require_tree ./ui/player

window.Warble = {}  # namespacing object for our classes

jQuery(document).ready ($) ->
  window.jukebox = jukebox = new Warble.Jukebox
  window.pandoraPlayer = new Warble.PandoraPlayerView model: jukebox
  window.youtubePlayer = new Warble.YoutubePlayerView model: jukebox

  jukebox.fetch()   # load current song to play

  Warble.push.initialize()
  Warble.push.bind 'jukebox:change', (data) ->
    jukebox.set data.jukebox
