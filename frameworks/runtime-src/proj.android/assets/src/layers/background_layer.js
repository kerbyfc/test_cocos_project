var BackgroundLayer;

BackgroundLayer = cc.Layer.extend({
  ctor: function() {
    this._super();
    this.init();
  },
  init: function() {
    var centerPos, spriteBG, winsize;
    this._super();
    winsize = cc.director.getWinSize();
    centerPos = cc.p(winsize.width / 2, winsize.height / 2);
    spriteBG = cc.Sprite.create(res.bg.play_png);
    spriteBG.setPosition(centerPos);
    return this.addChild(spriteBG);
  }
});

//# sourceMappingURL=background_layer.js.map
