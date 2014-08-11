MenuLayer = cc.Layer.extend

  ctor: ->
    @_super()

  init: ->

    #call super class's super function
    @_super()

    #2. get the screen size of your game canvas
    winsize = cc.director.getWinSize()

    #3. calculate the center point
    centerpos = cc.p(winsize.width / 2, winsize.height / 2)

    #4. create a background image and set it's position at the center of the screen
    spritebg = cc.Sprite.create(res.bg.hello_png)

    spritebg.setPosition centerpos
    @addChild spritebg

    cc.MenuItemFont.setFontSize 60

    #6.create a menu and assign onPlay event callback to it
    # normal state image
    # select state image
    menuSprite = cc.MenuItemSprite.create(cc.Sprite.create(res.btn.start_n_png), cc.Sprite.create(res.btn.start_s_png), @onPlay, this)

    menu = cc.Menu.create(menuSprite) #7. create the menu
    menu.setPosition centerpos
    @addChild menu

  onPlay: ->
    cc.director.runScene new PlayScene
