var PlayScene;

PlayScene = cc.Scene.extend({
  onEnter: function() {
    this._super();
    this.addChild(new BackgroundLayer);
    this.addChild(new AnimationLayer);
    return this.addChild(new HUDLayer);
  }
});

//# sourceMappingURL=play_scene.js.map
