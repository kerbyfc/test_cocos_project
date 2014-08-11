BackgroundLayer = cc.Layer.extend

  ctor: ->
    @_super()
    @init()
    return

  init: ->
    @_super()
    winsize = cc.director.getWinSize()

    #create the background image and position it at the center of screen
    centerPos = cc.p(winsize.width / 2, winsize.height / 2)
    spriteBG = cc.Sprite.create(res.bg.play_png)
    spriteBG.setPosition centerPos
    @addChild spriteBG


