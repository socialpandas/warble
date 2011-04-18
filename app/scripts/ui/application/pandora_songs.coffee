class PandoraSongsView extends Backbone.View
  template: -> window.templates['pandora_songs']

  events:
    'click #add_songs':  'addSongs'
    'click #get_more':   'getMore'
    'click #select_all': 'selectAll'

  initialize: ->
    _.bindAll this, 'render', 'addSongs', 'getMore', 'selectAll'
    @el = $('#add .content')

  render: ->
    $(@el).html @template()
      name: @model.get 'name'
      songs: @model.songs.toJSON()
    this.delegateEvents()   # TODO: all pre-initted views can't share #add is the issue here

  addSongs: (event) ->
    window.workspace.showSpinnerForView(this)
    song_ids = this.$('input:checkbox:checked').map(-> $(this).attr('data-id')).get()
    $.post '/jukebox/songs',
      'song_id[]': song_ids
    @model.songs.fetch   # get more songs, TODO: this is whack, bind the collection properly
      success: =>
        this.render()
        window.workspace.hideSpinnerForView(this)
      error: ->
        window.location.hash = '!/pandora/stations'
    event.preventDefault()

  getMore: (event) ->
    event.preventDefault()

  selectAll: (event) ->
    this.$('input:checkbox').attr('checked', true)
    event.preventDefault()
