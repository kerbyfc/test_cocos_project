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

