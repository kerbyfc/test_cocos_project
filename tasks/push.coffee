grunt = require 'grunt'
sys = require('sys')
exec = require('child_process').exec

module.exports = ->

  if commit= grunt.file.read '.commit'

    exec "git add -A && git commit -m '#{commit}'", (err) ->
      if err?
        grunt.fail.fatal err

      if grunt.file.exists '.tag'
        tag = grunt.file.read '.tag'

        exec "git tag #{tag} && git push --tags", (err) ->
          if err?
            grunt.fail.fatal err
          grunt.file.delete '.tag'

  else
    grunt.fail.warn 'ensure .commit file exists'

