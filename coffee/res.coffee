res =
  bg:
    play_png: "res/bg/play.png"
    hello_png: "res/bg/hello.png"

  btn:
    start_n_png: "res/btn/start_n.png"
    start_s_png: "res/btn/start_s.png"

  sprites:
    runner:
      png: "res/sprites/runner/runner.png"
      plist: "res/sprites/runner/runner.plist"

# transform res object to flatten array of resources
resources = _.values _.clone res, true
while (_.find(resources, (e) -> _.isObject(e) ))
  resources = _.flatten(_.map(resources, (e) -> if _.isObject(e) then _.values(e) else e ))

cc.log resources
