var MenuLayer;

MenuLayer = cc.Layer.extend({
  ctor: function() {
    return this._super();
  },
  init: function() {
    var centerpos, menu, menuSprite, spritebg, winsize;
    this._super();
    winsize = cc.director.getWinSize();
    centerpos = cc.p(winsize.width / 2, winsize.height / 2);
    spritebg = cc.Sprite.create(res.bg.hello_png);
    spritebg.setPosition(centerpos);
    this.addChild(spritebg);
    cc.MenuItemFont.setFontSize(60);
    menuSprite = cc.MenuItemSprite.create(cc.Sprite.create(res.btn.start_n_png), cc.Sprite.create(res.btn.start_s_png), this.onPlay, this);
    menu = cc.Menu.create(menuSprite);
    menu.setPosition(centerpos);
    return this.addChild(menu);
  },
  onPlay: function() {
    return cc.director.runScene(new PlayScene);
  }
});

//# sourceMappingURL=menu_layer.js.map
