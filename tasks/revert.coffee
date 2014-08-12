grunt = require 'grunt'
sys = require('sys')
exec = require('child_process').exec

module.exports = ->

  current = grunt.file.readJSON 'package.json'

  exec 'git checkout -f package.json', (err, out) ->
    sys.print out
    if err?
      grunt.fail.fatal err

    # REWRITE CHANGELOG
    exec 'git checkout -f CHANGELOG.md', (err, out) ->
      sys.print out
      if err?
        grunt.fail.fatal err

      # DOWN VERSION
      last = grunt.file.readJSON 'package.json'
      current.version = last.version
      grunt.file.write 'package.json', current
