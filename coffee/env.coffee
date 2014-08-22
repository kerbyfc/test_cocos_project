
# SCOPE
Space = {}

# GLOBALS

G = {}

G.MAP_SIZE = [1600, 1200]
G.MAP_MOVE_GLIDING_TIME = 2000

###
 # minimum move event delta to
 # begin screen dragging
###
G.MIN_DRAG_DELTA = 3

###
 # size of drag events batch
 # to correct drag gliding
###
G.DRAG_AVG_FACTOR = 1
G.DRAG_SLIP_FACTOR = 5

for e in ['MOUSE', 'TOUCH_ONE_BY_ONE', 'TOUCH_ALL_AT_ONCE', 'KEYBOARD']
  G[e]= cc.EventListener[e]

G.EVENTS =

  types:

    touch: [
      'Began'
      'Moved'
      'Ended'
      'Canceled'
    ]
    keyboard: [
      'Pressed'
      'Released'
    ]
    mouse: [
      'Down'
      'Up'
      'Move'
    ]

G.EVENTS.mapping =

  mouse:
    MOUSE: _.map G.EVENTS.types.mouse, (e) -> "onMouse#{e}"

  touches:
    TOUCH_ALL_AT_ONCE: _.map G.EVENTS.types.touch, (e) -> "onTouches#{e}"
    TOUCH_ONE_BY_ONE: _.map G.EVENTS.types.touch, (e) -> "onTouch#{e}"

  keyboard:
    KEYBOARD: _.map G.EVENTS.types.keyboard, (e) -> "onKey#{e}"

G.FSM =
  re: /([^\-\s]+)[\s]*\-\>[\s]*(.*)/
