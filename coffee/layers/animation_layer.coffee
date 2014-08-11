AnimationLayer = cc.Layer.extend
  ctor: ->
    @_super()
    @init()

  spriteSheet:null
  runningAction:null
  sprite:null

  init: ->
    @_super()

    # 1.load spritesheet
    cc.spriteFrameCache.addSpriteFrames res.sprites.runner.plist

    @spriteSheet = cc.SpriteBatchNode.create res.sprites.runner.png
    @addChild @spriteSheet

    # 2.create spriteframe array
    animFrames = []
    for i in [0...8]
      animFrames.push cc.spriteFrameCache.getSpriteFrame("runner#{i}.png")

    # 3.create a animation with the spriteframe array along with a period time
    animation = cc.Animation.create animFrames, 0.1

    # 4.wrap the animate action with a repeat forever action
    @runningAction = cc.RepeatForever.create cc.Animate.create(animation)

    @sprite = cc.Sprite.create "#runner0.png"
    @sprite.attr x: 80, y: 85

    # create the move action
    @sprite.runAction @runningAction
    @spriteSheet.addChild @sprite
