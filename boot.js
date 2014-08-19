cc.game.onStart = function(){

  size = cc.view.getFrameSize();

  cc.view.setDesignResolutionSize(size.width, size.height, cc.ResolutionPolicy.EXACT_FIT);

  cc.view.resizeWithBrowserSize(true);
    cc.LoaderScene.preload(resources, function () {
        cc.director.runScene(new Space.Scene());
    }, this);
};

cc.game.run();
