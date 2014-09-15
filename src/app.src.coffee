_.mixin capitalize: (string) ->
  string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

_.mixin pAdd: (objs...) ->
  s = cc.p()
  for obj in objs
    s = cc.pAdd s, cc.p(obj)
  s

_.mixin pAmid: (objs...) ->
  _.pCalc (pt = _.pAdd objs...), (v) -> v /= objs.length

_.mixin pCalc: (pt, fn) -> cc.p (_.map ['x', 'y'], (c) -> fn(pt[c], c, pt) )...

_.mixin pDiff: (a, b) ->
  cc.p (_.map ['x', 'y'], (c) -> cc.p(a)[c] - cc.p(b)[c])...

_.mixin log: (args...) ->
  for arg in args
    cache = []
    out = if _.isObject(arg) or _.isArray(arg)
      JSON.stringify(arg, (key, value) ->
        if typeof value is 'object' && value?
          if cache.indexOf(value) isnt -1
            return
          cache.push(value)
        return value
      , 2)
    else
      arg
    cc.log out


# SCOPE
Space = {}

# GLOBALS

G = {}

G.MAP_SIZE = [1600, 1200]
G.MAP_MOVE_GLIDING_TIME = 2000

###
 # minimum move event delta to
 # begin screen dragging
###
G.MIN_DRAG_DELTA = 3

###
 # size of drag events batch
 # to correct drag gliding
###
G.DRAG_AVG_FACTOR = 1
G.DRAG_SLIP_FACTOR = 5

for e in ['MOUSE', 'TOUCH_ONE_BY_ONE', 'TOUCH_ALL_AT_ONCE', 'KEYBOARD']
  G[e]= cc.EventListener[e]

G.EVENTS =

  types:

    touch: [
      'Began'
      'Moved'
      'Ended'
      'Canceled'
    ]
    keyboard: [
      'Pressed'
      'Released'
    ]
    mouse: [
      'Down'
      'Up'
      'Move'
    ]

G.EVENTS.mapping =

  mouse:
    MOUSE: _.map G.EVENTS.types.mouse, (e) -> "onMouse#{e}"

  touches:
    TOUCH_ALL_AT_ONCE: _.map G.EVENTS.types.touch, (e) -> "onTouches#{e}"
    TOUCH_ONE_BY_ONE: _.map G.EVENTS.types.touch, (e) -> "onTouch#{e}"

  keyboard:
    KEYBOARD: _.map G.EVENTS.types.keyboard, (e) -> "onKey#{e}"

G.FSM =
  re: /([^\-\s]+)[\s]*\-\>[\s]*(.*)/

Skeleton =

  initFsm: ->
    if @stateflow? and @state?

      @_states = []
      @stateflow = @stateflow() if _.isFunction @stateflow

      events = _.map @stateflow, (flow, event) =>

        # check to prevent bugs searching
        unless _.isString flow
          throw Error "fsm flow type error"

        # parse states
        [from, to] = flow.match(G.FSM.re).slice(1)
        from = from.split '/'

        # accumulate for events delegation
        @_states.push from, to
        name: event, from: from, to: to

      # create finite state machine
      @fsm = new StateMachine.create
        initial: @state
        events: events

      # map accumulated states to delegate events
      for state in (@_states = _.uniq _.flatten @_states)
        for type in ["Enter", "Leave"]
          if handler = @["on#{type}#{_.capitalize state}"]

            do (handler) =>
              # revert arguments order
              @fsm["on#{type + state}".toLowerCase()] = (event, from, to, args...) =>
                handler.apply @, args.concat([event, from, to])

  delegateEvents: ->

    # for all known input methods...
    for inputMethod, eventTypes of G.EVENTS.mapping
      if cc.sys.capabilities[inputMethod]
        for type, events of eventTypes
          # search for event handlers
          handlers = _.reduce(events, (result, event) =>
            if @[event]
              result[event] = switch inputMethod
                when "mouse"
                  (e) =>
                    @[event](e, e.getButton(), e.getLocation())
                else
                  (actor, e) =>
                    @[event](e, actor)
            result
          , {})
          if _.size handlers
            cc.eventManager.addListener(
              _.extend {}, handlers, event: cc.EventListener[type]
            , @)

Layer = cc.Layer.extend _.extend {}, Skeleton,

  ctor: (args...) ->
    @_super()
    @init(args)

  init: (args) ->
    @_super()
    @initFsm()
    if @cName
      @__cName = @cName
    @initialize?(args...)
    @delegateEvents()

cc.EventMouse.prototype.checkLocation = (target = @getCurrentTarget()) ->
  s = target.getContentSize()
  l = target.convertToNodeSpace @getLocation()
  cc.rectContainsPoint cc.rect(0, 0, s.width, s.height), l

cc.EventTouch.prototype.checkLocation = (target = @getCurrentTarget(), touches) ->
  if touches.length is 1
    s = target.getContentSize()
    l = target.convertToNodeSpace touches[0].getLocation()
    cc.rectContainsPoint cc.rect(0, 0, s.width, s.height), l

Scene = cc.Scene.extend _.extend {}, Skeleton,

  ctor: (args...) ->
    @_super()
    @init(args)

  init: (args) ->
    @_super()
    @initFsm()
    if @cName
      @__cName = @cName
    @initialize?(args...)
    @delegateEvents()


cc.GLNode = cc.Node.extend
  draw: (ctx) ->
      this._super(ctx)

cc.GLNode.create = ->

  node = new cc.GLNode()
  node.init()
  return node

cc.GLNode.extend = cc.Class.extend

ShaderNode = cc.GLNode.extend(
  ctor: (vertexShader, framentShader) ->
    @_super()
    @init()
    if cc.sys.capabilities.opengl
      @width = 256
      @height = 256
      @anchorX = 0.5
      @anchorY = 0.5
      @shader = cc.GLProgram.create(vertexShader, framentShader)
      @shader.retain()
      @shader.addAttribute "aVertex", cc.VERTEX_ATTRIB_POSITION
      @shader.link()
      @shader.updateUniforms()
      program = @shader.getProgram()
      @uniformCenter = gl.getUniformLocation(program, "center")
      @uniformResolution = gl.getUniformLocation(program, "resolution")
      @initBuffers()
      @scheduleUpdate()
      @_time = 0
    return

  draw: ->

    winSize = cc.director.getWinSize()

    @shader.use()
    @shader.setUniformsForBuiltins()

    #
    # Uniforms
    #
    @shader.setUniformLocationF32 @uniformCenter, 100, 100
    @shader.setUniformLocationF32 @uniformResolution, 256, 256
    cc.glEnableVertexAttribs cc.VERTEX_ATTRIB_FLAG_POSITION

    # Draw fullscreen Square
    gl.bindBuffer gl.ARRAY_BUFFER, @squareVertexPositionBuffer
    gl.vertexAttribPointer cc.VERTEX_ATTRIB_POSITION, 2, gl.FLOAT, false, 0, 0
    gl.drawArrays gl.TRIANGLE_STRIP, 0, 4
    gl.bindBuffer gl.ARRAY_BUFFER, null
    return

  update: (dt) ->
    @_time += dt
    return

  initBuffers: ->

    #
    # Square
    #
    squareVertexPositionBuffer = @squareVertexPositionBuffer = gl.createBuffer()
    gl.bindBuffer gl.ARRAY_BUFFER, squareVertexPositionBuffer
    vertices = [
      256
      256
      0
      256
      256
      0
      0
      0
    ]
    gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW
    gl.bindBuffer gl.ARRAY_BUFFER, null
    return
)

# class Sprite

#   name: null
#   plist: null

#   constructor: (@name) ->
#     @plist = RES["#{name}_plist"]
#     cc.spriteFrameCache.addSpriteFrames @plist
#     @sprite = cc.Sprite.create "##{name}_01"

#   getSpriteFrames: ->
#     return animFrames = for frame in _.keys(cc.spriteFrameCache._frameConfigCache[@plist].frames)
#       cc.spriteFrameCache.getSpriteFrame(frame)

#   animate: (speed, implementation) ->
#     @animation = cc.Animation.create @getSpriteFrames(), speed
#     @action = implementation (cc.Animate.create @animation)
#     @sprite.runAction @action
#     return this

#   appendTo: (parent) ->
#     parent.addChild @sprite
#     return this

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


Space.BackgroundLayer = Layer.extend

  state: "idle"

  cName: "BackgroundLayer"

  initialize: ->

    @voidNode = cc.ParallaxNode.create()

    bg1 = cc.Sprite.create RES.space_nebula_jpg
    bg1.setOpacity 140
    bg1.anchorX = 0
    bg1.anchorY = 0

    bg2 = cc.Sprite.create RES.space_blue_jpg
    bg2.setOpacity 160
    bg2.anchorX = 0
    bg2.anchorY = 0

    bg3 = cc.Sprite.create RES.space_jpg
    bg3.setOpacity 100
    bg3.anchorX = 0
    bg3.anchorY = 0

    for bg, i in [bg1, bg2, bg3]
      scalew = if bg.width < G.MAP_SIZE[0] then G.MAP_SIZE[0] / bg.width else 1
      scaleh = if bg.height < G.MAP_SIZE[1] then G.MAP_SIZE[1] / bg.height else 1
      scale = _.max([scalew, scaleh])
      cc.log "SET SCALE #{i} = #{scale} [#{bg.width}x#{bg.height}]"
      bg.setScale scale

    @voidNode.addChild(bg1, 0, cc.p(0.03, 0.03), cc.p(0, 0))
    @voidNode.addChild(bg2, 1, cc.p(0.05, 0.05), cc.p(0, 0))
    @voidNode.addChild(bg3, 2, cc.p(0.08, 0.08), cc.p(0, 0))

    @addChild(@voidNode)

  # @drawNode.drawRect( cc.p(@voidNode.x, @voidNode.y), cc.p(@voidNode.width, @voidNode.height), null, 2, cc.color(255, 0, 255, 200))

  # TOUCHES
  # onTouchesBegan: (event, touches) ->
  #   cc.log touches.length
  #   for touch in touches
  #     cc.log touch.getLocation().x
  #     cc.log touch.getId()


  # MISC ---------------------------------------------------

  # showLabel: ->
  #   cc.log "SHOW LABEL"
  #   w = cc.director.getWinSize()
  #   @labelCoin = cc.LabelTTF.create("Coins:0", "Helvetica", 40)
  #   @labelCoin.setColor(cc.color.WHITE)
  #   @labelCoin.setPosition(cc.p(w.width/2, w.height/2))
  #   cc.log @labelCoin
  #   @labelCoin.setOpacity 50
  #   @labelCoin.zIndex = 10
  #   @addChild(@labelCoin)

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


Space.HudLayer = Layer.extend

  cName: "HudLayer"

  labelCoin  : null
  labelMeter : null
  coins      : 0

  initialize: ->

    winsize = cc.director.getWinSize()

    @labelCoin = cc.LabelTTF.create("Coins:0", "Helvetica", 20)
    @labelCoin.setColor(cc.color(0,0,0))
    @labelCoin.setPosition(cc.p(70, winsize.height - 20))
    @addChild(@labelCoin)

    @labelMeter = cc.LabelTTF.create("0M", "Helvetica", 20)
    @labelMeter.setPosition(cc.p(winsize.width - 70, winsize.height - 20))
    @addChild(@labelMeter)

    cc.spriteFrameCache.addSpriteFrames RES.smoke_jump_plist
    @sprite = cc.Sprite.create "#smoke_jump_01"
    @sprite.setScale 0.2
    @sprite.attr x: 300, y: 100

    @addChild @sprite

MenuScene = cc.Scene.extend

  ctor: ->
    @_super()

  onEnter: ->
    @_super()
    layer = new Space.BackgroundLayer
    layer.init()
    @addChild layer

Space.Scene = Scene.extend

  ###
   # initial finite state
  ###
  state: "idle"

  ###
   # class name
  ###
  cName: "SpaceScene"

  ###
   # current event target
   # of game layer
  ###
  ctar: null

  ###
   # batch of drag events deltas
   # need for layers's slipping
  ###
  dragDelstasBatch: []

  ###
   # initialize non game object
   # @return {void} description
  ###
  initialize: ->

    ###
     # remember window size
    ###
    @ws = cc.director.getWinSize()

  ###
   # state machine states
   # represended by minimalistic DSL
  ###
  stateflow:
    trap: "* -> trapping"
    drag: "trapping/idle -> dragging"
    slip: "dragging -> slipping"
    move: "* -> moving"
    stay: "moving/slipping -> idle"

  ###
   # some method
   # @return {void} description
  ###
  onEnter: ->
    @_super()

    ###
     * background layer
     * with parallax node
    ###
    @bgl = new Space.BackgroundLayer @

    ###
     # main gameplay layer
    ###
    @gpl = new Space.GameLayer @

    ###
     # gameplay layer position bounds
    ###
    @bounds = cc.p( @ws.width - @gpl.width, @ws.height - @gpl.height)

    @addChild @bgl
    @addChild @gpl

  ###
   # @param {cc.Point} pt point to be fixed if needed
   # @return {cc.Point|Boolean}
  ###
  fixPosOverages: (pt, p = cc.p()) ->
    for c in ['x', 'y']
      p[c] = unless pt[c] > @bounds[c]
        _.max [pt[c], @bounds[c]]
      else
        _.min [pt[c], 0]
    if _.values(pt) is _.values(@gpl.getPosition())
      return false
    p

  ###
   # TODO
   # @param {varType} pt Description
   # @return {void} description
  ###
  fixAnchorOverages: (pt) ->
    false

  ###
   # Drag gameplay layer with passed deltas
   # @param {varType} dX x pos delta
   # @param {varType} dY y pos delta
   # @return {void}
  ###
  drag: (dX, dY) ->

    (d = @dragDelstasBatch).push cc.p dX, dY
    if d.length > G.DRAG_AVG_FACTOR
      d.shift()

    aim = cc.p(@gpl.x + dX, @gpl.y + dY)

    if faim = @fixPosOverages aim
      ###
       # TODO show bouding box with gradient
       # based on _.pDiff(aim, faim)
      ###
      @gpl.setPosition faim
      @bgl.voidNode.setPosition faim

  ###
   # MOUSE -------------------------------
  ###

  onMouseDown: (event, target) ->
    @fsm.trap()

  onMouseMove: (event) ->
    if event.getButton() is cc.EventMouse.BUTTON_LEFT
      @trapMove event.getDeltaX(), event.getDeltaY()

  onMouseUp: (event) ->
    if @fsm.is "dragging"
      @fsm.slip()

  trapMove: (dX, dY) ->
    switch @fsm.current
      when "dragging"
        @drag dX, dY
      when "trapping"
        maxD = _.max _.map [dX, dY], Math.abs
        if maxD > G.MIN_DRAG_DELTA
          @fsm.drag()
          @drag dX, dY

  ###
   # TOUCHES -----------------------------
  ###

  onTouchesBegan: (event, touches) ->
    if touches.length is 1
      @fsm.trap()

  onTouchesMoved: (event, touches) ->
    if touches.length is 1
      @trapMove(touches[0].getDelta().x, touches[0].getDelta().y)

  onTouchesEnded: (event, touches) ->
    if touches.length is 1
      if @fsm.is "dragging"
        @fsm.slip()

  ###
   # STATES ------------------------------
  ###

  onEnterDragging: (currentEventTarget) ->
    cc.log "ENTER MOVING"
    @ctar = null

  onEnterMoving: ->
    cc.log "LAST MOVING DELTA"
    @fsm.stay()

  onEnterTrapping: ->
    cc.log "TRAPPING"

  onEnterSlipping: ->
    d = _.pCalc (_.pAmid @dragDelstasBatch...), (v) ->
      v*= G.DRAG_SLIP_FACTOR

    if aim = @fixPosOverages _.pAdd @gpl, d
      slip = cc.MoveTo.create(1, aim).easing(cc.easeExponentialOut())
      @dragDelstasBatch = []

      @gpl.runAction slip
      @bgl.voidNode.runAction slip.clone()


