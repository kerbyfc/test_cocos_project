# HELPERS

_.mixin capitalize: (string) ->
  string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

# SCOPE
Space = {}


# GLOBALS

MAP_SIZE = [2000, 2000]

EVENTS =

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

EVENTS.mapping =

  mouse:
    MOUSE: _.map EVENTS.types.mouse, (e) -> "onMouse#{e}"

  touch:
    TOUCH_ALL_AT_ONCE: _.map EVENTS.types.touch, (e) -> "onTouches#{e}"
    TOUCH_ONE_BY_ONE: _.map EVENTS.types.touch, (e) -> "onTouch#{e}"

  keyboard:
    KEYBOARD: _.map EVENTS.types.keyboard, (e) -> "onKey#{e}"

FSM =

  re: /([^\-\s]+)[\s]*\-\>[\s]*(.*)/

Skeleton =

  _initFsm: ->
    if @stateflow? and @state?

      @_states = []
      @stateflow = @stateflow() if _.isFunction @stateflow

      events = _.map @stateflow, (flow, event) =>

        # check to prevent bugs searching
        unless _.isString flow
          throw Error "fsm flow type error"

        # parse states
        [from, to] = flow.match(FSM.re).slice(1)
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
                handler args.concat([event, from, to])...

  _delegateEvents: ->

    # for all known input methods...
    for inputMethod, eventTypes of EVENTS.mapping
      if cc.sys.capabilities[inputMethod]
        for type, events of eventTypes

          # search for event handlers
          handlers = _.reduce(events, (result, event) =>
            if @[event]
              result[event] = (e) =>
                @[event](e, e.getCurrentTarget())
            result
          , {})

          if _.size handlers
            cc.eventManager.addListener(
              _.extend {}, handlers, event: cc.EventListener[type]
            , @)

Layer = cc.Layer.extend _.extend {}, Skeleton,

  ctor: ->
    @_super()

  init: (args...) ->
    @_super()
    @_initFsm()
    @initialize? args...
    @_delegateEvents()
    return @

Scene = cc.Scene.extend _.extend {}, Skeleton,

  ctor: (args...) ->
    @_super(args)
    @init()

  init: (args) ->
    @_super()
    @_initFsm()
    @initialize? args...
    @_delegateEvents()
    return @

class Sprite

  name: null
  plist: null

  constructor: (@name) ->
    @plist = RES["#{name}_plist"]
    cc.spriteFrameCache.addSpriteFrames @plist
    @sprite = cc.Sprite.create "##{name}_01"

  getSpriteFrames: ->
    return animFrames = for frame in _.keys(cc.spriteFrameCache._frameConfigCache[@plist].frames)
      cc.spriteFrameCache.getSpriteFrame(frame)

  animate: (speed, implementation) ->
    @animation = cc.Animation.create @getSpriteFrames(), speed
    @action = implementation (cc.Animate.create @animation)
    @sprite.runAction @action
    return this

  appendTo: (parent) ->
    parent.addChild @sprite
    return this

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



Space.HudLayer = cc.Layer.extend

  labelCoin  : null
  labelMeter : null
  coins      : 0

  ctor: (@scene) ->
    @_super()
    @init()

  init: ->
    @_super()

    winsize = cc.director.getWinSize()

    @labelCoin = cc.LabelTTF.create("Coins:0", "Helvetica", 20)
    @labelCoin.setColor(cc.color(0,0,0))
    @labelCoin.setPosition(cc.p(70, winsize.height - 20))
    @addChild(@labelCoin)

    @labelMeter = cc.LabelTTF.create("0M", "Helvetica", 20)
    @labelMeter.setPosition(cc.p(winsize.width - 70, winsize.height - 20))
    @addChild(@labelMeter)


MenuScene = cc.Scene.extend

  ctor: ->
    @_super()

  onEnter: ->
    @_super()
    layer = new Space.BackgroundLayer
    layer.init()
    @addChild layer

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
