_.mixin capitalize: (string) ->
  string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

_.mixin fold: (objs...) ->
  s = cc.p()
  for obj in objs
    pt = cc.p obj
    s.x += pt.x
    s.y += pt.y
  s

_.mixin amid: (objs...) ->
  pt = _.fold objs...
  cc.p (_.map ['x', 'y'], (c) ->
    pt[c] /= objs.length)...

_.mixin shift: (pt, factor) ->
  cc.p pt.x * factor, pt.y * factor

