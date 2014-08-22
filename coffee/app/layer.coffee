Layer = cc.Layer.extend _.extend {}, Skeleton,

  ctor: (args...) ->
    @_super()
    @init(args)

  init: (args) ->
    @_super()
    @initFsm()
    if @cName
      @__cName = @cName
    @initialize?(args...)
    @delegateEvents()
