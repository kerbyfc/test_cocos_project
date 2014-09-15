var AnimationLayer, G, Layer, MenuScene, Scene, ShaderNode, Skeleton, Space, a, e, _i, _len, _ref,
  __slice = [].slice;

_.mixin({
  capitalize: function(string) {
    return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
  }
});

_.mixin({
  pAdd: function() {
    var obj, objs, s, _i, _len;
    objs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    s = cc.p();
    for (_i = 0, _len = objs.length; _i < _len; _i++) {
      obj = objs[_i];
      s = cc.pAdd(s, cc.p(obj));
    }
    return s;
  }
});

_.mixin({
  pAmid: function() {
    var objs, pt;
    objs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return _.pCalc((pt = _.pAdd.apply(_, objs)), function(v) {
      return v /= objs.length;
    });
  }
});

_.mixin({
  pCalc: function(pt, fn) {
    return cc.p.apply(cc, _.map(['x', 'y'], function(c) {
      return fn(pt[c], c, pt);
    }));
  }
});

_.mixin({
  pDiff: function(a, b) {
    return cc.p.apply(cc, _.map(['x', 'y'], function(c) {
      return cc.p(a)[c] - cc.p(b)[c];
    }));
  }
});

_.mixin({
  log: function() {
    var arg, args, cache, out, _i, _len, _results;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    _results = [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      arg = args[_i];
      cache = [];
      out = _.isObject(arg) || _.isArray(arg) ? JSON.stringify(arg, function(key, value) {
        if (typeof value === 'object' && (value != null)) {
          if (cache.indexOf(value) !== -1) {
            return;
          }
          cache.push(value);
        }
        return value;
      }, 2) : arg;
      _results.push(cc.log(out));
    }
    return _results;
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
      if (cc.sys.capabilities[inputMethod]) {
        _results.push((function() {
          var _results1;
          _results1 = [];
          for (type in eventTypes) {
            events = eventTypes[type];
            handlers = _.reduce(events, (function(_this) {
              return function(result, event) {
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

cc.EventMouse.prototype.checkLocation = function(target) {
  var l, s;
  if (target == null) {
    target = this.getCurrentTarget();
  }
  s = target.getContentSize();
  l = target.convertToNodeSpace(this.getLocation());
  return cc.rectContainsPoint(cc.rect(0, 0, s.width, s.height), l);
};

cc.EventTouch.prototype.checkLocation = function(target, touches) {
  var l, s;
  if (target == null) {
    target = this.getCurrentTarget();
  }
  if (touches.length === 1) {
    s = target.getContentSize();
    l = target.convertToNodeSpace(touches[0].getLocation());
    return cc.rectContainsPoint(cc.rect(0, 0, s.width, s.height), l);
  }
};

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

cc.GLNode = cc.Node.extend({
  draw: function(ctx) {
    return this._super(ctx);
  }
});

cc.GLNode.create = function() {
  var node;
  node = new cc.GLNode();
  node.init();
  return node;
};

cc.GLNode.extend = cc.Class.extend;

ShaderNode = cc.GLNode.extend({
  ctor: function(vertexShader, framentShader) {
    var program;
    this._super();
    this.init();
    if (cc.sys.capabilities.opengl) {
      this.width = 256;
      this.height = 256;
      this.anchorX = 0.5;
      this.anchorY = 0.5;
      this.shader = cc.GLProgram.create(vertexShader, framentShader);
      this.shader.retain();
      this.shader.addAttribute("aVertex", cc.VERTEX_ATTRIB_POSITION);
      this.shader.link();
      this.shader.updateUniforms();
      program = this.shader.getProgram();
      this.uniformCenter = gl.getUniformLocation(program, "center");
      this.uniformResolution = gl.getUniformLocation(program, "resolution");
      this.initBuffers();
      this.scheduleUpdate();
      this._time = 0;
    }
  },
  draw: function() {
    var winSize;
    winSize = cc.director.getWinSize();
    this.shader.use();
    this.shader.setUniformsForBuiltins();
    this.shader.setUniformLocationF32(this.uniformCenter, 100, 100);
    this.shader.setUniformLocationF32(this.uniformResolution, 256, 256);
    cc.glEnableVertexAttribs(cc.VERTEX_ATTRIB_FLAG_POSITION);
    gl.bindBuffer(gl.ARRAY_BUFFER, this.squareVertexPositionBuffer);
    gl.vertexAttribPointer(cc.VERTEX_ATTRIB_POSITION, 2, gl.FLOAT, false, 0, 0);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    gl.bindBuffer(gl.ARRAY_BUFFER, null);
  },
  update: function(dt) {
    this._time += dt;
  },
  initBuffers: function() {
    var squareVertexPositionBuffer, vertices;
    squareVertexPositionBuffer = this.squareVertexPositionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer);
    vertices = [256, 256, 0, 256, 256, 0, 0, 0];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
    gl.bindBuffer(gl.ARRAY_BUFFER, null);
  }
});

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
    bg1.setOpacity(140);
    bg1.anchorX = 0;
    bg1.anchorY = 0;
    bg2 = cc.Sprite.create(RES.space_blue_jpg);
    bg2.setOpacity(160);
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
    this.voidNode.addChild(bg1, 0, cc.p(0.03, 0.03), cc.p(0, 0));
    this.voidNode.addChild(bg2, 1, cc.p(0.05, 0.05), cc.p(0, 0));
    this.voidNode.addChild(bg3, 2, cc.p(0.08, 0.08), cc.p(0, 0));
    return this.addChild(this.voidNode);
  }
});

a = null;

Space.GameLayer = Layer.extend({
  cName: "GameLayer",
  initialize: function(scene) {
    var center, clipper, fade, mask, move, move2, orb, orb2, planet, planet2, planetNode, rotate, rotate2, w;
    this.scene = scene;
    this.scheduleUpdate();
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

    /*
      * ------------------------------------------------------
     */

    /*
      * ---------------------------------------------------
     */
    planetNode = cc.Node.create();
    mask = cc.Sprite.create(RES.planet_clip_png);
    planet = cc.Sprite.create(RES.planet_brown_jpg);
    planet2 = cc.Sprite.create(RES.planet_brown_jpg);
    orb = cc.Sprite.create(RES.planet_orb_png);
    orb2 = cc.Sprite.create(RES.atmos_png);
    mask.opacity = 50;
    planet2.x = -planet2.width;
    clipper = cc.ClippingNode.create();
    clipper.setStencil(mask);
    clipper.setAlphaThreshold(0.5);
    clipper.setContentSize(cc.size(mask.getContentSize().width, mask.getContentSize().height));
    clipper.addChild(mask, 1);
    clipper.addChild(planet, 2);
    clipper.addChild(planet2, 3);
    move = cc.Sequence.create(cc.MoveTo.create(35, cc.p(planet.width, 0)), cc.CallFunc.create(function() {
      cc.log("HERE");
      cc.log(this);
      return this.setPosition(cc.p(0, 0));
    }, planet)).repeatForever();
    move2 = cc.Sequence.create(cc.MoveTo.create(35, cc.p(0, 0)), cc.CallFunc.create(function() {
      cc.log("HERE");
      cc.log(this);
      return this.setPosition(cc.p(-planet2.width, 0));
    }, planet2)).repeatForever();
    planet.runAction(move);
    planet2.runAction(move2);
    rotate = cc.RotateBy.create(180, 180).repeatForever();
    fade = cc.Sequence.create(cc.FadeTo.create(90, 220), cc.FadeTo.create(90, 255)).repeatForever();
    mask.runAction(rotate);
    clipper.attr({
      x: 300,
      y: 300
    });
    orb.setPosition(clipper.getPosition());
    orb.opacity = 250;
    orb2.setPosition(clipper.getPosition());
    orb2.opacity = 250;
    rotate2 = rotate.clone();
    orb2.runAction(rotate2);
    orb.runAction(rotate);
    orb.runAction(fade);
    orb2.runAction(fade.clone());
    clipper.setRotation(30);
    planetNode.addChild(clipper, 1);
    planetNode.addChild(orb, 3);
    planetNode.addChild(orb2, 2);
    this.addChild(planetNode);
    this.drawNode.drawRect(cc.p(this.x, this.y), cc.p(this.width, this.height), null, 2, cc.color(255, 0, 255, 120));
    this.w = w = cc.director.getWinSize();
    return this.addChild(this.drawNode, 10);
  },
  assign: function(assigment, fn) {
    return (function(_this) {
      return function(e) {
        assigment.ctar = e.getCurrentTarget();
        cc.log("SCENE TARGET");
        cc.log(_this.scene.currentEventTarget);
        return fn.apply(null, arguments);
      };
    })(this);
  },
  assigned: function(assigment, fn) {
    return (function(_this) {
      return function(e, touches) {
        var target;
        target = e.getCurrentTarget();
        cc.log("ASSIGNED");
        cc.log(e);
        cc.log(assigment.ctar);
        cc.log(assigment.ctar === target);
        cc.log(_this.scene.currentEventTarget);
        if (assigment.ctar === target) {
          assigment.ctar = null;
          if (e.checkLocation(target, touches)) {
            return fn.apply(null, arguments);
          }
        }
      };
    })(this);
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
    * current event target
    * of game layer
   */
  ctar: null,

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
    this.bgl = new Space.BackgroundLayer(this);

    /*
      * main gameplay layer
     */
    this.gpl = new Space.GameLayer(this);

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
  fixPosOverages: function(pt, p) {
    var c, _j, _len1, _ref1;
    if (p == null) {
      p = cc.p();
    }
    _ref1 = ['x', 'y'];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      c = _ref1[_j];
      p[c] = !(pt[c] > this.bounds[c]) ? _.max([pt[c], this.bounds[c]]) : _.min([pt[c], 0]);
    }
    if (_.values(pt) === _.values(this.gpl.getPosition())) {
      return false;
    }
    return p;
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
    var aim, d, faim;
    (d = this.dragDelstasBatch).push(cc.p(dX, dY));
    if (d.length > G.DRAG_AVG_FACTOR) {
      d.shift();
    }
    aim = cc.p(this.gpl.x + dX, this.gpl.y + dY);
    if (faim = this.fixPosOverages(aim)) {

      /*
        * TODO show bouding box with gradient
        * based on _.pDiff(aim, faim)
       */
      this.gpl.setPosition(faim);
      return this.bgl.voidNode.setPosition(faim);
    }
  },

  /*
    * MOUSE -------------------------------
   */
  onMouseDown: function(event, target) {
    return this.fsm.trap();
  },
  onMouseMove: function(event) {
    if (event.getButton() === cc.EventMouse.BUTTON_LEFT) {
      return this.trapMove(event.getDeltaX(), event.getDeltaY());
    }
  },
  onMouseUp: function(event) {
    if (this.fsm.is("dragging")) {
      return this.fsm.slip();
    }
  },
  trapMove: function(dX, dY) {
    var maxD;
    switch (this.fsm.current) {
      case "dragging":
        return this.drag(dX, dY);
      case "trapping":
        maxD = _.max(_.map([dX, dY], Math.abs));
        if (maxD > G.MIN_DRAG_DELTA) {
          this.fsm.drag();
          return this.drag(dX, dY);
        }
    }
  },

  /*
    * TOUCHES -----------------------------
   */
  onTouchesBegan: function(event, touches) {
    if (touches.length === 1) {
      return this.fsm.trap();
    }
  },
  onTouchesMoved: function(event, touches) {
    if (touches.length === 1) {
      return this.trapMove(touches[0].getDelta().x, touches[0].getDelta().y);
    }
  },
  onTouchesEnded: function(event, touches) {
    if (touches.length === 1) {
      if (this.fsm.is("dragging")) {
        return this.fsm.slip();
      }
    }
  },

  /*
    * STATES ------------------------------
   */
  onEnterDragging: function(currentEventTarget) {
    cc.log("ENTER MOVING");
    return this.ctar = null;
  },
  onEnterMoving: function() {
    cc.log("LAST MOVING DELTA");
    return this.fsm.stay();
  },
  onEnterTrapping: function() {
    return cc.log("TRAPPING");
  },
  onEnterSlipping: function() {
    var aim, d, slip;
    d = _.pCalc(_.pAmid.apply(_, this.dragDelstasBatch), function(v) {
      return v *= G.DRAG_SLIP_FACTOR;
    });
    if (aim = this.fixPosOverages(_.pAdd(this.gpl, d))) {
      slip = cc.MoveTo.create(1, aim).easing(cc.easeExponentialOut());
      this.dragDelstasBatch = [];
      this.gpl.runAction(slip);
      return this.bgl.voidNode.runAction(slip.clone());
    }
  }
});

//# sourceMappingURL=app.js.map
