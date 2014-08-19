Space.BackgroundLayer = Layer.extend

  state: "idle"

  stateflow: ->
    stay  : "gliding -> idle"
    glide : "moving -> gliding"
    move  : "gliding/idle -> moving"

  initialize: (@mapSize) ->

    w = cc.director.getWinSize()

    # Add background sprite
    @sprite = cc.Sprite.create RES.space_jpg
    @sprite.setPosition cc.p(w.width/2, w.height/2)

    @scale = 

    @addChild @sprite

  onMouseDown: (event, target) ->
    @fsm.move(event)

  onEnterMoving: (event, from, to) ->



  # onMouseMove: (event, target) ->
  #   switch true
  #     when @bg.fsm.is "moving"
  #       @bg.move(event)

  # onMouseUp: (event) ->
  #   switch true
  #     when @bg.fsm.is "moving"
  #       @bg.fsm.glide(event)


