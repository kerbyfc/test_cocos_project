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


