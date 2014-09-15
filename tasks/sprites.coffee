grunt = require 'grunt'
exec = require("child_process").exec

grunt.event.on 'watch', (action, filepath, target) ->
  if target is 'sprites'
    grunt.task.run "sprites:#{filepath}"

module.exports = (filepath) ->

  re = /\_\d{1,5}\.(png|gif)$/
  if filepath.match(re)?

    [path..., basename] = filepath.split('/')
    [name, ext] = basename.split('.')

    path = path.join('/')

    done = @async()
    target = "#{path}/#{basename.replace(re, '.png')}"

    cmd = "rm -f #{target} && TexturePacker --basic-sort-by Name --basic-order Ascending --format cocos2d --trim-sprite-names --sheet #{target} --data #{path}/#{basename.replace(re, '.plist')} #{path}"

    grunt.log.ok cmd

    exec cmd, (error, stdout, stderr) ->
      grunt.fail.warn error if error?
      grunt.log.ok stdout
      grunt.log.writeln stderr

      done()
