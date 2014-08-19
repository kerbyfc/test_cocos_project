var AnimationLayer, EVENTS, FSM, Layer, MAP_SIZE, MenuScene, Scene, Skeleton, Space, Sprite,
  __slice = [].slice;

_.mixin({
  capitalize: function(string) {
    return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
  }
});

Space = {};

MAP_SIZE = [2000, 2000];

EVENTS = {
  types: {
    touch: ['Began', 'Moved', 'Ended', 'Canceled'],
    keyboard: ['Pressed', 'Released'],
    mouse: ['Down', 'Up', 'Move']
  }
};

EVENTS.mapping = {
  mouse: {
    MOUSE: _.map(EVENTS.types.mouse, function(e) {
      return "onMouse" + e;
    })
  },
  touch: {
    TOUCH_ALL_AT_ONCE: _.map(EVENTS.types.touch, function(e) {
      return "onTouches" + e;
    }),
    TOUCH_ONE_BY_ONE: _.map(EVENTS.types.touch, function(e) {
      return "onTouch" + e;
    })
  },
  keyboard: {
    KEYBOARD: _.map(EVENTS.types.keyboard, function(e) {
      return "onKey" + e;
    })
  }
};

FSM = {
  re: /([^\-\s]+)[\s]*\-\>[\s]*(.*)/
};

Skeleton = {
  _initFsm: function() {
    var events, handler, state, type, _i, _len, _ref, _results;
    if ((this.stateflow != null) && (this.state != null)) {
      this._states = [];
      if (_.isFunction(this.stateflow)) {
        this.stateflow = this.stateflow();
      }
      events = _.map(this.stateflow, (function(_this) {
        return function(flow, event) {
          var from, to, _ref;
          if (!_.isString(flow)) {
            throw Error("fsm flow type error");
          }
          _ref = flow.match(FSM.re).slice(1), from = _ref[0], to = _ref[1];
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
      _ref = (this._states = _.uniq(_.flatten(this._states)));
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        state = _ref[_i];
        _results.push((function() {
          var _j, _len1, _ref1, _results1;
          _ref1 = ["Enter", "Leave"];
          _results1 = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            type = _ref1[_j];
            if (handler = this["on" + type + (_.capitalize(state))]) {
              _results1.push((function(_this) {
                return function(handler) {
                  return _this.fsm[("on" + (type + state)).toLowerCase()] = function() {
                    var args, event, from, to;
                    event = arguments[0], from = arguments[1], to = arguments[2], args = 4 <= arguments.length ? __slice.call(arguments, 3) : [];
                    return handler.apply(null, args.concat([event, from, to]));
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
  _delegateEvents: function() {
    var eventTypes, events, handlers, inputMethod, type, _ref, _results;
    _ref = EVENTS.mapping;
    _results = [];
    for (inputMethod in _ref) {
      eventTypes = _ref[inputMethod];
      if (cc.sys.capabilities[inputMethod]) {
        _results.push((function() {
          var _results1;
          _results1 = [];
          for (type in eventTypes) {
            events = eventTypes[type];
            handlers = _.reduce(events, (function(_this) {
              return function(result, event) {
                if (_this[event]) {
                  result[event] = function(e) {
                    return _this[event](e, e.getCurrentTarget());
                  };
                }
                return result;
              };
            })(this), {});
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
    return this._super();
  },
  init: function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this._super();
    this._initFsm();
    if (typeof this.initialize === "function") {
      this.initialize.apply(this, args);
    }
    this._delegateEvents();
    return this;
  }
}));

Scene = cc.Scene.extend(_.extend({}, Skeleton, {
  ctor: function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    this._super(args);
    return this.init();
  },
  init: function(args) {
    this._super();
    this._initFsm();
    if (typeof this.initialize === "function") {
      this.initialize.apply(this, args);
    }
    this._delegateEvents();
    return this;
  }
}));

Sprite = (function() {
  Sprite.prototype.name = null;

  Sprite.prototype.plist = null;

  function Sprite(name) {
    this.name = name;
    this.plist = RES["" + name + "_plist"];
    cc.spriteFrameCache.addSpriteFrames(this.plist);
    this.sprite = cc.Sprite.create("#" + name + "_01");
  }

  Sprite.prototype.getSpriteFrames = function() {
    var animFrames, frame;
    return animFrames = (function() {
      var _i, _len, _ref, _results;
      _ref = _.keys(cc.spriteFrameCache._frameConfigCache[this.plist].frames);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        frame = _ref[_i];
        _results.push(cc.spriteFrameCache.getSpriteFrame(frame));
      }
      return _results;
    }).call(this);
  };

  Sprite.prototype.animate = function(speed, implementation) {
    this.animation = cc.Animation.create(this.getSpriteFrames(), speed);
    this.action = implementation(cc.Animate.create(this.animation));
    this.sprite.runAction(this.action);
    return this;
  };

  Sprite.prototype.appendTo = function(parent) {
    parent.addChild(this.sprite);
    return this;
  };

  return Sprite;

})();

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
  stateflow: function() {
    return {
      stay: "gliding -> idle",
      glide: "moving -> gliding",
      move: "gliding/idle -> moving"
    };
  },
  initialize: function(mapSize) {
    var w;
    this.mapSize = mapSize;
    w = cc.director.getWinSize();
    this.sprite = cc.Sprite.create(RES.space_jpg);
    this.sprite.setPosition(cc.p(w.width / 2, w.height / 2));
    return this.scale = this.addChild(this.sprite);
  },
  onMouseDown: function(event, target) {
    return this.fsm.move(event);
  },
  onEnterMoving: function(event, from, to) {}
});

Space.HudLayer = cc.Layer.extend({
  labelCoin: null,
  labelMeter: null,
  coins: 0,
  ctor: function(scene) {
    this.scene = scene;
    this._super();
    return this.init();
  },
  init: function() {
    var winsize;
    this._super();
    winsize = cc.director.getWinSize();
    this.labelCoin = cc.LabelTTF.create("Coins:0", "Helvetica", 20);
    this.labelCoin.setColor(cc.color(0, 0, 0));
    this.labelCoin.setPosition(cc.p(70, winsize.height - 20));
    this.addChild(this.labelCoin);
    this.labelMeter = cc.LabelTTF.create("0M", "Helvetica", 20);
    this.labelMeter.setPosition(cc.p(winsize.width - 70, winsize.height - 20));
    return this.addChild(this.labelMeter);
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
  initialize: function() {
    return this.bg = new Space.BackgroundLayer().init({
      mapSize: MAP_SIZE
    });
  },
  onEnter: function() {
    this._super();
    return this.addChild(this.bg);
  },
  onMouseDown: function(event, target) {
    cc.log("MOUSE IN SCENE");
    cc.log(event);
    return cc.log(target);
  }
});

//# sourceMappingURL=app.js.map
