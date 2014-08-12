grunt = require 'grunt'

module.exports = ->

  tails = /^[\s]+|([\s\|\%]+$)/g

  unless grunt.option('m')?
    grunt.fail.warn('-m option missed')

  message = grunt.option('m').replace(tails, '')

  if _.indexOf(message, "%") > 1
    [message, changes] = message.split('%')

  # UP VERSION -----------------------------------------
  build = grunt.file.readJSON('package.json')
  version = _.zipObject ['major', 'minor', 'revision'], _.map(build.version.split('.'), (e) -> parseInt(e))
  type = grunt.config('type') || 'revision'
  version[type] += 1
  build.version = _.values(version).join('.')

  if type isnt 'revision'
    grunt.file.write '.tag', build.version

  # write commit message for push task
  grunt.file.write '.commit', message.replace(tails, '')

  # UPDATE CHANGELOG -----------------------------------
  if changes
    changes = _.map changes.replace(tails, '').split('|'), (c) -> c.replace tails, ''
    changelog = grunt.file.read('CHANGELOG.md')
    grunt.file.write 'CHANGELOG.md', "### #{build.version}\n  **#{message}**\n  - #{changes.join('\n  - ')}\n\n#{changelog}"

  grunt.file.write 'package.json', JSON.stringify(build, null, 2)
