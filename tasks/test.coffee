grunt = require 'grunt'

module.exports = ->

  grunt.initConfig

    shell:
      web:
        command: "cocos run -p web"
      ios:
        command: "cocos run -p ios"
      mac:
        command: "cocos run -p mac"
      android:
        command: "cocos run -p android --ap 20"

  if target = grunt.option('target')
    grunt.task.run "shell:#{target}"
  else
    for platform in ['android', 'ios', 'mac']
      grunt.task.run "shell:#{platform}"
