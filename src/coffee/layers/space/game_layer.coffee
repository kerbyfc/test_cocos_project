a = null
Space.GameLayer = Layer.extend

  cName: "GameLayer"

  initialize: (@scene) ->

    @scheduleUpdate()

    @width = G.MAP_SIZE[0]
    @height = G.MAP_SIZE[1]

    @drawNode = cc.DrawNode.create()

    @ws = cc.director.getWinSize()

    ###
     # bounds for layer position
    ###
    @bounds = cc.p( @ws.width - @width, @ws.height - @height )

    @drawDot 0, 0
    @drawDot G.MAP_SIZE...
    @drawDot 0, G.MAP_SIZE[1]
    @drawDot G.MAP_SIZE[0], 0

    center = cc.p(@width/2, @height/2)


    ###
     # ------------------------------------------------------
    ###



    # label = cc.LabelTTF.create("Coins:0", "Helvetica", 40)
    # label.setPosition center

    # cc.log "SCENE"
    # cc.log @scene

    # _.extend label, Skeleton,

    #   onMouseDown: @assign @scene, (event) ->
    #     cc.log event.getCurrentTarget()

    #   onTouchesBegan: @assign @scene, (event) ->
    #     cc.log "TOUCH"
    #     false

    #   onTouchesEnded: @assigned @scene, (event) ->
    #     cc.log "TOUCH ENDED"
    #     event.getCurrentTarget().opacity = 180
    #     false

    #   onMouseUp: @assigned @scene, (event) ->
    #     cc.log "UP"
    #     cc.log arguments
    #     cc.log event.getCurrentTarget()
    #     event.getCurrentTarget().opacity = 180
    #     return true

    # label.delegateEvents()

    ###
     # ---------------------------------------------------
    ###
    #

    planetNode = cc.Node.create()

    mask = cc.Sprite.create RES.planet_clip_png
    planet = cc.Sprite.create RES.planet_brown_jpg
    planet2 = cc.Sprite.create RES.planet_brown_jpg
    orb = cc.Sprite.create RES.planet_orb_png
    orb2 = cc.Sprite.create RES.atmos_png

    mask.opacity = 50

    planet2.x = - planet2.width

    clipper = cc.ClippingNode.create()
    clipper.setStencil(mask)
    clipper.setAlphaThreshold(0.5)
    clipper.setContentSize cc.size mask.getContentSize().width, mask.getContentSize().height

    clipper.addChild(mask, 1)
    clipper.addChild(planet, 2)
    clipper.addChild(planet2, 3)

    move = cc.Sequence.create(
      cc.MoveTo.create(35, cc.p(planet.width, 0)),
      cc.CallFunc.create( ->
        cc.log "HERE"
        cc.log @
        @setPosition cc.p(0, 0)
      planet)).repeatForever()

    move2 = cc.Sequence.create(
      cc.MoveTo.create(35, cc.p(0, 0)),
      cc.CallFunc.create( ->
        cc.log "HERE"
        cc.log @
        @setPosition cc.p(-planet2.width, 0)
      planet2)).repeatForever()

    planet.runAction(move)
    planet2.runAction(move2)
    rotate = cc.RotateBy.create(180, 180).repeatForever()
    fade = cc.Sequence.create(cc.FadeTo.create(90, 220), cc.FadeTo.create(90, 255)).repeatForever()
    mask.runAction(rotate)

    clipper.attr
      x: 300
      y: 300

    orb.setPosition clipper.getPosition()
    orb.opacity = 250

    orb2.setPosition clipper.getPosition()
    orb2.opacity = 250

    rotate2 = rotate.clone()
    orb2.runAction rotate2
    orb.runAction rotate
    orb.runAction fade
    orb2.runAction fade.clone()

    clipper.setRotation 30
    planetNode.addChild clipper, 1
    planetNode.addChild orb, 3
    planetNode.addChild orb2, 2

    # planetNode.runAction cc.MoveTo.create(10, cc.p(800, 600))
    @addChild planetNode


    # cc.log ">>>>>>>>>>>>>>>>>>>"
    # G.cam = @getCamera()

    @drawNode.drawRect( cc.p(@x, @y), cc.p(@width, @height), null, 2, cc.color(255, 0, 255, 120))

    @w = w = cc.director.getWinSize()



    # @addChild label
    @addChild @drawNode, 10

  assign: (assigment, fn) ->
    (e) =>
      assigment.ctar = e.getCurrentTarget()
      cc.log "SCENE TARGET"
      cc.log @scene.currentEventTarget
      fn arguments...

  assigned: (assigment, fn) ->
    (e, touches) =>
      target = e.getCurrentTarget()
      cc.log "ASSIGNED"
      cc.log e
      cc.log assigment.ctar
      cc.log assigment.ctar is target
      cc.log @scene.currentEventTarget
      if assigment.ctar is target
        assigment.ctar = null
        if e.checkLocation target, touches
          fn arguments...

  drawDot: (x, y, radius = 40) ->
    @drawNode.drawDot cc.p(x, y), radius, cc.color.WHITE

