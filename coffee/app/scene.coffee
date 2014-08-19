Scene = cc.Scene.extend _.extend {}, Skeleton,

  ctor: (args...) ->
    @_super(args)
    @init()

  init: (args) ->
    @_super()
    @_initFsm()
    @initialize? args...
    @_delegateEvents()
    return @
