grunt = require 'grunt'

module.exports = ->

  if target = grunt.option 'target'

    flag = grunt.option('flag') || "n"
    from = grunt.option('from')
    to = grunt.option('to')
    ext = grunt.option('ext') || ".gif"

    cmd = "rename -#{flag} 's/#{from}([^0-9])(\\d+)#{ext}$/#{to}_$2.png/' #{target}/*#{ext} && rename -#{flag} 's/#{to}_(\\d{1}).png$/#{to}_0$1.png/' #{target}/*.png"

    grunt.log.ok cmd

    grunt.initConfig

      shell:
        rename:
          command: cmd
          options:
            callback: (error, stdout, stderr, done) ->
              grunt.log.writeln stdout
              grunt.log.writeln stderr
              done()

    grunt.task.run "shell:rename"

  else
    grunt.fail.fatal "--target option is required"
