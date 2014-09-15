cc.EventMouse.prototype.checkLocation = (target = @getCurrentTarget()) ->
  s = target.getContentSize()
  l = target.convertToNodeSpace @getLocation()
  cc.rectContainsPoint cc.rect(0, 0, s.width, s.height), l

cc.EventTouch.prototype.checkLocation = (target = @getCurrentTarget(), touches) ->
  if touches.length is 1
    s = target.getContentSize()
    l = target.convertToNodeSpace touches[0].getLocation()
    cc.rectContainsPoint cc.rect(0, 0, s.width, s.height), l
