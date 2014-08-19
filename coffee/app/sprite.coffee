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
