cc.game.onStart = function(){
  cc.view.setDesignResolutionSize(800, 450, cc.ResolutionPolicy.SHOW_ALL);
  cc.view.resizeWithBrowserSize(true);
    cc.LoaderScene.preload(resources, function () {
        cc.director.runScene(new MenuScene());
    }, this);
};
cc.game.run();
