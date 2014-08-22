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


