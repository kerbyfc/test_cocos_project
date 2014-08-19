MenuScene = cc.Scene.extend

  ctor: ->
    @_super()

  onEnter: ->
    @_super()
    layer = new Space.BackgroundLayer
    layer.init()
    @addChild layer
