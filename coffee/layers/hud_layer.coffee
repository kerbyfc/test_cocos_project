HUDLayer = cc.Layer.extend

  labelCoin  : null
  labelMeter : null
  coins      : 0

  ctor: ->
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
