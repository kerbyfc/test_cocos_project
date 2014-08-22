_.mixin capitalize: (string) ->
  string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

_.mixin fold: (objs...) ->
  s = cc.p()
  for obj in objs
    pt = cc.p obj
    s.x += pt.x
    s.y += pt.y
  s

_.mixin amid: (objs...) ->
  pt = _.fold objs...
  cc.p (_.map ['x', 'y'], (c) ->
    pt[c] /= objs.length)...

_.mixin shift: (pt, factor) ->
  cc.p pt.x * factor, pt.y * factor



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
      cc.log inputMethod
      cc.log eventTypes
      cc.log cc.sys.capabilities[inputMethod]
      if cc.sys.capabilities[inputMethod]
        for type, events of eventTypes

          cc.log events

          # search for event handlers
          handlers = _.reduce(events, (result, event) =>
            cc.log "EVENT #{event}"
            cc.log @[event]
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

          cc.log "HANDLERS #{JSON.stringify(handlers, null, 2)}"

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

Space.BackgroundLayer = Layer.extend

  state: "idle"

  cName: "BackgroundLayer"

  initialize: ->

    @voidNode = cc.ParallaxNode.create()

    bg1 = cc.Sprite.create RES.space_nebula_jpg
    bg1.setOpacity 255
    bg1.anchorX = 0
    bg1.anchorY = 0

    bg2 = cc.Sprite.create RES.space_blue_jpg
    bg2.setOpacity 120
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

    @voidNode.addChild(bg1, 0, cc.p(0.1, 0.1), cc.p(0, 0))
    @voidNode.addChild(bg2, 1, cc.p(0.3, 0.3), cc.p(0, 0))
    @voidNode.addChild(bg3, 2, cc.p(0.5, 0.5), cc.p(0, 0))

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

Space.GameLayer = Layer.extend

  cName: "GameLayer"

  initialize: (@bg) ->

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

    label = cc.LabelTTF.create("Coins:0", "Helvetica", 40)
    label.setPosition center
    label.__cName = "LABEL"

    listener = cc.EventListener.create
      event: G.MOUSE,
      onMouseDown: (event) =>
        @parent.currentEventTarget = event.getCurrentTarget()
      onMouseUp: (event) =>
        if @parent.currentEventTarget is event.getCurrentTarget()
          target = event.getCurrentTarget()
          cc.log ">>>"
          cc.log target

    cc.eventManager.addListener(listener, label)

    @drawNode.drawRect( cc.p(@x, @y), cc.p(@width, @height), null, 2, cc.color(255, 0, 255, 120))

    @w = w = cc.director.getWinSize()

    @addChild(label)
    @addChild @drawNode, 10









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
    @bgl = new Space.BackgroundLayer()

    ###
     # main gameplay layer
    ###
    @gpl = new Space.GameLayer()

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
  fixPosOverages: (pt) ->
    for c in ['x', 'y']
      pt[c] = unless pt[c] > @bounds[c]
        _.max [pt[c], @bounds[c]]
      else
        _.min [pt[c], 0]
    if _.values(pt) is _.values(@gpl.getPosition())
      return false
    pt

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

    if aim = @fixPosOverages cc.p(@gpl.x + dX, @gpl.y + dY)
      # TODO refactor this code !
      @gpl.x = aim.x
      @gpl.y = aim.y
      @bgl.voidNode.x = aim.x
      @bgl.voidNode.y = aim.y

  ###
   # MOUSE -------------------------------
  ###

  onMouseDown: (event, target) ->
    @fsm.trap()

  onMouseMove: (event) ->
    if event.getButton() is cc.EventMouse.BUTTON_LEFT
      drag = =>
        @drag(event.getDeltaX(), event.getDeltaY())
      switch @fsm.current
        when "dragging"
          drag()
        when "trapping"
          maxD = _.max _.map [event.getDeltaX(), event.getDeltaY()], Math.abs
          if maxD > G.MIN_DRAG_DELTA
            @fsm.drag()
            drag()

  onMouseUp: (event) ->
    if @fsm.is "dragging"
      @fsm.slip()

  ###
   # TOUCHES -----------------------------
  ###

  # onTouchesBegan: (event, touches) ->
  #   if touches.length is 1
  #     @fsm.drag()

  # onTouchesMoved: (event, touches) ->
  #   if touches.length is 1
  #     @grag(touches[0].getDelta().x, touches[0].getDelta().y)

  # onTouchesEnded: (event, touches) ->
  #   if touches.length is 1
  #     @fsm.move() # TODO pass delta batch!

  ###
   # STATES ------------------------------
  ###

  onEnterDragging: (currentEventTarget) ->
    cc.log "ENTER MOVING"
    @currentEventTarget = null

  onEnterMoving: ->
    cc.log "LAST MOVING DELTA"
    @fsm.stay()

  onEnterTrapping: ->
    cc.log "TRAPPING"

  onEnterSlipping: ->
    if aim = @fixPosOverages( _.fold @gpl, (_.shift (_.amid @dragDelstasBatch...), G.DRAG_SLIP_FACTOR ))
      slip = cc.MoveTo.create(1, aim).easing(cc.easeExponentialOut())
      @gpl.runAction slip
      @dragDelstasBatch = []
      @bgl.voidNode.runAction slip.clone()


