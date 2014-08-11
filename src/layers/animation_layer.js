var AnimationLayer;

AnimationLayer = cc.Layer.extend({
  ctor: function() {
    this._super();
    return this.init();
  },
  spriteSheet: null,
  runningAction: null,
  sprite: null,
  init: function() {
    var animFrames, animation, i, _i;
    this._super();
    cc.spriteFrameCache.addSpriteFrames(res.sprites.runner.plist);
    this.spriteSheet = cc.SpriteBatchNode.create(res.sprites.runner.png);
    this.addChild(this.spriteSheet);
    animFrames = [];
    for (i = _i = 0; _i < 8; i = ++_i) {
      animFrames.push(cc.spriteFrameCache.getSpriteFrame("runner" + i + ".png"));
    }
    animation = cc.Animation.create(animFrames, 0.1);
    this.runningAction = cc.RepeatForever.create(cc.Animate.create(animation));
    this.sprite = cc.Sprite.create("#runner0.png");
    this.sprite.attr({
      x: 80,
      y: 85
    });
    this.sprite.runAction(this.runningAction);
    return this.spriteSheet.addChild(this.sprite);
  }
});

//# sourceMappingURL=animation_layer.js.map
