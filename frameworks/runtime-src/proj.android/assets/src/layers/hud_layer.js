var HUDLayer;

HUDLayer = cc.Layer.extend({
  labelCoin: null,
  labelMeter: null,
  coins: 0,
  ctor: function() {
    this._super();
    return this.init();
  },
  init: function() {
    var winsize;
    this._super();
    winsize = cc.director.getWinSize();
    this.labelCoin = cc.LabelTTF.create("Coins:0", "Helvetica", 20);
    this.labelCoin.setColor(cc.color(0, 0, 0));
    this.labelCoin.setPosition(cc.p(70, winsize.height - 20));
    this.addChild(this.labelCoin);
    this.labelMeter = cc.LabelTTF.create("0M", "Helvetica", 20);
    this.labelMeter.setPosition(cc.p(winsize.width - 70, winsize.height - 20));
    return this.addChild(this.labelMeter);
  }
});

//# sourceMappingURL=hud_layer.js.map
