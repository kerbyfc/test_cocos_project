var AnimationLayer, G, Layer, MenuScene, Scene, Skeleton, Space, e, _i, _len, _ref,
  __slice = [].slice;

_.mixin({
  capitalize: function(string) {
    return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
  }
});

_.mixin({
  fold: function() {
    var obj, objs, pt, s, _i, _len;
    objs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    s = cc.p();
    for (_i = 0, _len = objs.length; _i < _len; _i++) {
      obj = objs[_i];
      pt = cc.p(obj);
      s.x += pt.x;
      s.y += pt.y;
    }
    return s;
  }
});

_.mixin({
  amid: function() {
    var objs, pt;
    objs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    pt = _.fold.apply(_, objs);
    return cc.p.apply(cc, _.map(['x', 'y'], function(c) {
      return pt[c] /= objs.length;
    }));
  }
});

_.mixin({
  shift: function(pt, factor) {
    return cc.p(pt.x * factor, pt.y * factor);
  }
});

Space = {};

G = {};

G.MAP_SIZE = [1600, 1200];

G.MAP_MOVE_GLIDING_TIME = 2000;


/*
  * minimum move event delta to
  * begin screen dragging
 */

G.MIN_DRAG_DELTA = 3;


/*
  * size of drag events batch
  * to correct drag gliding
 */

G.DRAG_AVG_FACTOR = 1;

G.DRAG_SLIP_FACTOR = 5;

_ref = ['MOUSE', 'TOUCH_ONE_BY_ONE', 'TOUCH_ALL_AT_ONCE', 'KEYBOARD'];
for (_i = 0, _len = _ref.length; _i < _len; _i++) {
  e = _ref[_i];
  G[e] = cc.EventListener[e];
}

G.EVENTS = {
  types: {
    touch: ['Began', 'Moved', 'Ended', 'Canceled'],
    keyboard: ['Pressed', 'Released'],
    mouse: ['Down', 'Up', 'Move']
  }
};

G.EVENTS.mapping = {
  mouse: {
    MOUSE: _.map(G.EVENTS.types.mouse, function(e) {
      return "onMouse" + e;
    })
  },
  touches: {
    TOUCH_ALL_AT_ONCE: _.map(G.EVENTS.types.touch, function(e) {
      return "onTouches" + e;
    }),
    TOUCH_ONE_BY_ONE: _.map(G.EVENTS.types.touch, function(e) {
      return "onTouch" + e;
    })
  },
  keyboard: {
    KEYBOARD: _.map(G.EVENTS.types.keyboard, function(e) {
      return "onKey" + e;
    })
  }
};

G.FSM = {
  re: /([^\-\s]+)[\s]*\-\>[\s]*(.*)/
};

Skeleton = {
  initFsm: function() {
    var events, handler, state, type, _j, _len1, _ref1, _results;
    if ((this.stateflow != null) && (this.state != null)) {
      this._states = [];
      if (_.isFunction(this.stateflow)) {
        this.stateflow = this.stateflow();
      }
      events = _.map(this.stateflow, (function(_this) {
        return function(flow, event) {
          var from, to, _ref1;
          if (!_.isString(flow)) {
            throw Error("fsm flow type error");
          }
          _ref1 = flow.match(G.FSM.re).slice(1), from = _ref1[0], to = _ref1[1];
          from = from.split('/');
          _this._states.push(from, to);
          return {
            name: event,
            from: from,
            to: to
          };
        };
      })(this));
      this.fsm = new StateMachine.create({
        initial: this.state,
        events: events
      });
      _ref1 = (this._states = _.uniq(_.flatten(this._states)));
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        state = _ref1[_j];
        _results.push((function() {
          var _k, _len2, _ref2, _results1;
          _ref2 = ["Enter", "Leave"];
          _results1 = [];
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            type = _ref2[_k];
            if (handler = this["on" + type + (_.capitalize(state))]) {
              _results1.push((function(_this) {
                return function(handler) {
                  return _this.fsm[("on" + (type + state)).toLowerCase()] = function() {
                    var args, event, from, to;
                    event = arguments[0], from = arguments[1], to = arguments[2], args = 4 <= arguments.length ? __slice.call(arguments, 3) : [];
                    return handler.apply(_this, args.concat([event, from, to]));
                  };
                };
              })(this)(handler));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    }
  },
  delegateEvents: function() {
    var eventTypes, events, handlers, inputMethod, type, _ref1, _results;
    _ref1 = G.EVENTS.mapping;
    _results = [];
    for (inputMethod in _ref1) {
      eventTypes = _ref1[inputMethod];
      cc.log(inputMethod);
      cc.log(eventTypes);
      cc.log(cc.sys.capabilities[inputMethod]);
      if (cc.sys.capabilities[inputMethod]) {
        _results.push((function() {
          var _results1;
          _results1 = [];
          for (type in eventTypes) {
            events = eventTypes[type];
            cc.log(events);
            handlers = _.reduce(events, (function(_this) {
              return function(result, event) {
                cc.log("EVENT " + event);
                cc.log(_this[event]);
                if (_this[event]) {
                  result[event] = (function() {
                    switch (inputMethod) {
                      case "mouse":
                        return (function(_this) {
                          return function(e) {
                            return _this[event](e, e.getButton(), e.getLocation());
                          };
                        })(this);
                      default:
                        return (function(_this) {
                          return function(actor, e) {
                            return _this[event](e, actor);
                          };
                        })(this);
                    }
                  }).call(_this);
                }
                return result;
              };
            })(this), {});
            cc.log("HANDLERS " + (JSON.stringify(handlers, null, 2)));
            if (_.size(handlers)) {
              _results1.push(cc.eventManager.addListener(_.extend({}, handlers, {
                event: cc.EventListener[type]
              }), this));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  }
};

Layer = cc.Layer.extend(_.extend({}, Skeleton, {
  ctor: function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this._super();
    return this.init(args);
  },
  init: function(args) {
    this._super();
    this.initFsm();
    if (this.cName) {
      this.__cName = this.cName;
    }
    if (typeof this.initialize === "function") {
      this.initialize.apply(this, args);
    }
    return this.delegateEvents();
  }
}));

Scene = cc.Scene.extend(_.extend({}, Skeleton, {
  ctor: function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this._super();
    return this.init(args);
  },
  init: function(args) {
    this._super();
    this.initFsm();
    if (this.cName) {
      this.__cName = this.cName;
    }
    if (typeof this.initialize === "function") {
      this.initialize.apply(this, args);
    }
    return this.delegateEvents();
  }
}));

AnimationLayer = cc.Layer.extend({
  spriteSheet: null,
  runningAction: null,
  sprite: null,
  ctor: function() {
    this._super();
    return this.init();
  },
  init: function() {
    return this._super();
  }
});

Space.BackgroundLayer = Layer.extend({
  state: "idle",
  cName: "BackgroundLayer",
  initialize: function() {
    var bg, bg1, bg2, bg3, i, scale, scaleh, scalew, _j, _len1, _ref1;
    this.voidNode = cc.ParallaxNode.create();
    bg1 = cc.Sprite.create(RES.space_nebula_jpg);
    bg1.setOpacity(255);
    bg1.anchorX = 0;
    bg1.anchorY = 0;
    bg2 = cc.Sprite.create(RES.space_blue_jpg);
    bg2.setOpacity(120);
    bg2.anchorX = 0;
    bg2.anchorY = 0;
    bg3 = cc.Sprite.create(RES.space_jpg);
    bg3.setOpacity(100);
    bg3.anchorX = 0;
    bg3.anchorY = 0;
    _ref1 = [bg1, bg2, bg3];
    for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
      bg = _ref1[i];
      scalew = bg.width < G.MAP_SIZE[0] ? G.MAP_SIZE[0] / bg.width : 1;
      scaleh = bg.height < G.MAP_SIZE[1] ? G.MAP_SIZE[1] / bg.height : 1;
      scale = _.max([scalew, scaleh]);
      cc.log("SET SCALE " + i + " = " + scale + " [" + bg.width + "x" + bg.height + "]");
      bg.setScale(scale);
    }
    this.voidNode.addChild(bg1, 0, cc.p(0.1, 0.1), cc.p(0, 0));
    this.voidNode.addChild(bg2, 1, cc.p(0.3, 0.3), cc.p(0, 0));
    this.voidNode.addChild(bg3, 2, cc.p(0.5, 0.5), cc.p(0, 0));
    return this.addChild(this.voidNode);
  }
});

Space.GameLayer = Layer.extend({
  cName: "GameLayer",
  initialize: function(bg) {
    var center, label, listener, w;
    this.bg = bg;
    this.width = G.MAP_SIZE[0];
    this.height = G.MAP_SIZE[1];
    this.drawNode = cc.DrawNode.create();
    this.ws = cc.director.getWinSize();

    /*
      * bounds for layer position
     */
    this.bounds = cc.p(this.ws.width - this.width, this.ws.height - this.height);
    this.drawDot(0, 0);
    this.drawDot.apply(this, G.MAP_SIZE);
    this.drawDot(0, G.MAP_SIZE[1]);
    this.drawDot(G.MAP_SIZE[0], 0);
    center = cc.p(this.width / 2, this.height / 2);
    label = cc.LabelTTF.create("Coins:0", "Helvetica", 40);
    label.setPosition(center);
    label.__cName = "LABEL";
    listener = cc.EventListener.create({
      event: G.MOUSE,
      onMouseDown: (function(_this) {
        return function(event) {
          return _this.parent.currentEventTarget = event.getCurrentTarget();
        };
      })(this),
      onMouseUp: (function(_this) {
        return function(event) {
          var target;
          if (_this.parent.currentEventTarget === event.getCurrentTarget()) {
            target = event.getCurrentTarget();
            cc.log(">>>");
            return cc.log(target);
          }
        };
      })(this)
    });
    cc.eventManager.addListener(listener, label);
    this.drawNode.drawRect(cc.p(this.x, this.y), cc.p(this.width, this.height), null, 2, cc.color(255, 0, 255, 120));
    this.w = w = cc.director.getWinSize();
    this.addChild(label);
    return this.addChild(this.drawNode, 10);
  },
  drawDot: function(x, y, radius) {
    if (radius == null) {
      radius = 40;
    }
    return this.drawNode.drawDot(cc.p(x, y), radius, cc.color.WHITE);
  }
});

Space.HudLayer = Layer.extend({
  cName: "HudLayer",
  labelCoin: null,
  labelMeter: null,
  coins: 0,
  initialize: function() {
    var winsize;
    winsize = cc.director.getWinSize();
    this.labelCoin = cc.LabelTTF.create("Coins:0", "Helvetica", 20);
    this.labelCoin.setColor(cc.color(0, 0, 0));
    this.labelCoin.setPosition(cc.p(70, winsize.height - 20));
    this.addChild(this.labelCoin);
    this.labelMeter = cc.LabelTTF.create("0M", "Helvetica", 20);
    this.labelMeter.setPosition(cc.p(winsize.width - 70, winsize.height - 20));
    this.addChild(this.labelMeter);
    cc.spriteFrameCache.addSpriteFrames(RES.smoke_jump_plist);
    this.sprite = cc.Sprite.create("#smoke_jump_01");
    this.sprite.setScale(0.2);
    this.sprite.attr({
      x: 300,
      y: 100
    });
    return this.addChild(this.sprite);
  }
});

MenuScene = cc.Scene.extend({
  ctor: function() {
    return this._super();
  },
  onEnter: function() {
    var layer;
    this._super();
    layer = new Space.BackgroundLayer;
    layer.init();
    return this.addChild(layer);
  }
});

Space.Scene = Scene.extend({

  /*
    * initial finite state
   */
  state: "idle",

  /*
    * class name
   */
  cName: "SpaceScene",

  /*
    * batch of drag events deltas
    * need for layers's slipping
   */
  dragDelstasBatch: [],

  /*
    * initialize non game object
    * @return {void} description
   */
  initialize: function() {

    /*
      * remember window size
     */
    return this.ws = cc.director.getWinSize();
  },

  /*
    * state machine states
    * represended by minimalistic DSL
   */
  stateflow: {
    trap: "* -> trapping",
    drag: "trapping/idle -> dragging",
    slip: "dragging -> slipping",
    move: "* -> moving",
    stay: "moving/slipping -> idle"
  },

  /*
    * some method
    * @return {void} description
   */
  onEnter: function() {
    this._super();

    /*
     * background layer
     * with parallax node
     */
    this.bgl = new Space.BackgroundLayer();

    /*
      * main gameplay layer
     */
    this.gpl = new Space.GameLayer();

    /*
      * gameplay layer position bounds
     */
    this.bounds = cc.p(this.ws.width - this.gpl.width, this.ws.height - this.gpl.height);
    this.addChild(this.bgl);
    return this.addChild(this.gpl);
  },

  /*
    * @param {cc.Point} pt point to be fixed if needed
    * @return {cc.Point|Boolean}
   */
  fixPosOverages: function(pt) {
    var c, _j, _len1, _ref1;
    _ref1 = ['x', 'y'];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      c = _ref1[_j];
      pt[c] = !(pt[c] > this.bounds[c]) ? _.max([pt[c], this.bounds[c]]) : _.min([pt[c], 0]);
    }
    if (_.values(pt) === _.values(this.gpl.getPosition())) {
      return false;
    }
    return pt;
  },

  /*
    * TODO
    * @param {varType} pt Description
    * @return {void} description
   */
  fixAnchorOverages: function(pt) {
    return false;
  },

  /*
    * Drag gameplay layer with passed deltas
    * @param {varType} dX x pos delta
    * @param {varType} dY y pos delta
    * @return {void}
   */
  drag: function(dX, dY) {
    var aim, d;
    (d = this.dragDelstasBatch).push(cc.p(dX, dY));
    if (d.length > G.DRAG_AVG_FACTOR) {
      d.shift();
    }
    if (aim = this.fixPosOverages(cc.p(this.gpl.x + dX, this.gpl.y + dY))) {
      this.gpl.x = aim.x;
      this.gpl.y = aim.y;
      this.bgl.voidNode.x = aim.x;
      return this.bgl.voidNode.y = aim.y;
    }
  },

  /*
    * MOUSE -------------------------------
   */
  onMouseDown: function(event, target) {
    return this.fsm.trap();
  },
  onMouseMove: function(event) {
    var drag, maxD;
    if (event.getButton() === cc.EventMouse.BUTTON_LEFT) {
      drag = (function(_this) {
        return function() {
          return _this.drag(event.getDeltaX(), event.getDeltaY());
        };
      })(this);
      switch (this.fsm.current) {
        case "dragging":
          return drag();
        case "trapping":
          maxD = _.max(_.map([event.getDeltaX(), event.getDeltaY()], Math.abs));
          if (maxD > G.MIN_DRAG_DELTA) {
            this.fsm.drag();
            return drag();
          }
      }
    }
  },
  onMouseUp: function(event) {
    if (this.fsm.is("dragging")) {
      return this.fsm.slip();
    }
  },

  /*
    * TOUCHES -----------------------------
   */

  /*
    * STATES ------------------------------
   */
  onEnterDragging: function(currentEventTarget) {
    cc.log("ENTER MOVING");
    return this.currentEventTarget = null;
  },
  onEnterMoving: function() {
    cc.log("LAST MOVING DELTA");
    return this.fsm.stay();
  },
  onEnterTrapping: function() {
    return cc.log("TRAPPING");
  },
  onEnterSlipping: function() {
    var aim, slip;
    if (aim = this.fixPosOverages(_.fold(this.gpl, _.shift(_.amid.apply(_, this.dragDelstasBatch), G.DRAG_SLIP_FACTOR)))) {
      slip = cc.MoveTo.create(1, aim).easing(cc.easeExponentialOut());
      this.gpl.runAction(slip);
      this.dragDelstasBatch = [];
      return this.bgl.voidNode.runAction(slip.clone());
    }
  }
});

//# sourceMappingURL=app.js.map
