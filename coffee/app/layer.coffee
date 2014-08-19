Layer = cc.Layer.extend _.extend {}, Skeleton,

  ctor: ->
    @_super()

  init: (args...) ->
    @_super()
    @_initFsm()
    @initialize? args...
    @_delegateEvents()
    return @
