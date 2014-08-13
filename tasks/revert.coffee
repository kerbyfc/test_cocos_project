grunt = require 'grunt'

module.exports = ->

  curr = grunt.file.readJSON 'package.json'

  grunt.initConfig

    shell:

      gco_package:
        command: 'git checkout -f package.json'

        options:
          callback: (error, stdout, stderr, done) ->
            if error?
              grunt.fail.fatal error

            grunt.task.run 'shell:gco_changelog'
            done()

      gco_changelog:
        command: 'git checkout -f CHANGELOG.md'

        options:
          callback: (error, stdout, stderr, done) ->
            if error?
              grunt.fail.fatal error

            last = grunt.file.readJSON 'package.json'
            grunt.log.ok "revert version from #{curr.version} to #{last.version}"
            curr.version = last.version

            grunt.file.write 'package.json', JSON.stringify(curr, null, 2)
            done()

  grunt.task.run 'shell:gco_package'
