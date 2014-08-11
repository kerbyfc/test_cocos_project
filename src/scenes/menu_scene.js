var MenuScene;

MenuScene = cc.Scene.extend({
  ctor: function() {
    return this._super();
  },
  onEnter: function() {
    var layer;
    this._super();
    layer = new MenuLayer;
    layer.init();
    return this.addChild(layer);
  }
});

//# sourceMappingURL=menu_scene.js.map
