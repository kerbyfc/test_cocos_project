MenuScene = cc.Scene.extend

  ctor: ->
    @_super()

  onEnter: ->
    @_super()
    layer = new MenuLayer
    layer.init()
    @addChild layer
