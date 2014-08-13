grunt = require 'grunt'
sys = require('sys')
exec = require('child_process').exec

module.exports = ->

  commit= grunt.file.read '.commit'
  tag = grunt.file.read '.tag'

  if commit

    grunt.initConfig

      shell:
        push:
          command: "git add -A && git commit -m '#{commit}' && git push"

          options:
            callback: (error, stdout, stderr, done) ->
              if error?
                grunt.fail.fatal error

              grunt.file.delete '.commit'

              if tag
                grunt.task.run 'shell:tag'
              done()

        tag:
          command: "git tag #{tag} && git push --tags"

          options:
            callback: (error, stdout, stderr, done) ->
              if error?
                grunt.fail.fatal error

              grunt.file.delete '.tag'
              done()

  grunt.task.run 'shell:push'
