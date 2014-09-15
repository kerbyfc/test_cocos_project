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
