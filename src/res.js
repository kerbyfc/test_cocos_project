var res, resources;

res = {
  bg: {
    play_png: "res/bg/play.png",
    hello_png: "res/bg/hello.png"
  },
  btn: {
    start_n_png: "res/btn/start_n.png",
    start_s_png: "res/btn/start_s.png"
  },
  sprites: {
    runner: {
      png: "res/sprites/runner/runner.png",
      plist: "res/sprites/runner/runner.plist"
    }
  }
};

resources = _.values(_.clone(res, true));

while (_.find(resources, function(e) {
    return _.isObject(e);
  })) {
  resources = _.flatten(_.map(resources, function(e) {
    if (_.isObject(e)) {
      return _.values(e);
    } else {
      return e;
    }
  }));
}

cc.log(resources);

//# sourceMappingURL=res.js.map
