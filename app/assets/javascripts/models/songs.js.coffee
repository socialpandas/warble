class Warble.Song extends Backbone.Model

class Warble.SongList extends Backbone.Collection
  model: Warble.Song
  url: '/songs'

class Warble.SearchList extends Backbone.Collection
  model: Warble.Song
  url: ->
    if @query?
      "/songs?query=#{encodeURIComponent(@query)}"
    else
      "/songs"
