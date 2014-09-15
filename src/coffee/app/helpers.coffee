_.mixin capitalize: (string) ->
  string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

_.mixin pAdd: (objs...) ->
  s = cc.p()
  for obj in objs
    s = cc.pAdd s, cc.p(obj)
  s

_.mixin pAmid: (objs...) ->
  _.pCalc (pt = _.pAdd objs...), (v) -> v /= objs.length

_.mixin pCalc: (pt, fn) -> cc.p (_.map ['x', 'y'], (c) -> fn(pt[c], c, pt) )...

_.mixin pDiff: (a, b) ->
  cc.p (_.map ['x', 'y'], (c) -> cc.p(a)[c] - cc.p(b)[c])...

_.mixin log: (args...) ->
  for arg in args
    cache = []
    out = if _.isObject(arg) or _.isArray(arg)
      JSON.stringify(arg, (key, value) ->
        if typeof value is 'object' && value?
          if cache.indexOf(value) isnt -1
            return
          cache.push(value)
        return value
      , 2)
    else
      arg
    cc.log out
