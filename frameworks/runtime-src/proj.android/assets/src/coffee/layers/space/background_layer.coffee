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
