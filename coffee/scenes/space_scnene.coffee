Space.Scene = Scene.extend

  initialize: ->
    @bg = new Space.BackgroundLayer().init
      mapSize: MAP_SIZE # hardcore

  onEnter: ->
    @_super()
    @addChild @bg

  onMouseDown: (event, target) ->
    cc.log "MOUSE IN SCENE"
    cc.log event
    cc.log target
