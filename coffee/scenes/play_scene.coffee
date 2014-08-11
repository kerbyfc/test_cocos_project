PlayScene = cc.Scene.extend

  onEnter: ->
    @_super()
    @addChild new BackgroundLayer
    @addChild new AnimationLayer
    @addChild new HUDLayer
