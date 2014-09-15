AnimationLayer = cc.Layer.extend

  spriteSheet:null
  runningAction:null
  sprite:null

  ctor: ->
    @_super()
    @init()

  init: ->
    @_super()

    # @sprite = new Sprite "smoke_jump"
    # @sprite.animate 0.1, cc.RepeatForever.create
    # @sprite.sprite.setScale 0.2
    # @sprite.sprite.attr x: 100, y: 100

    # @sprite.appendTo @
    #

