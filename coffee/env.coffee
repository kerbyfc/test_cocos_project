# HELPERS

_.mixin capitalize: (string) ->
  string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

# SCOPE
Space = {}


# GLOBALS

MAP_SIZE = [2000, 2000]

EVENTS =

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

EVENTS.mapping =

  mouse:
    MOUSE: _.map EVENTS.types.mouse, (e) -> "onMouse#{e}"

  touch:
    TOUCH_ALL_AT_ONCE: _.map EVENTS.types.touch, (e) -> "onTouches#{e}"
    TOUCH_ONE_BY_ONE: _.map EVENTS.types.touch, (e) -> "onTouch#{e}"

  keyboard:
    KEYBOARD: _.map EVENTS.types.keyboard, (e) -> "onKey#{e}"

FSM =

  re: /([^\-\s]+)[\s]*\-\>[\s]*(.*)/
