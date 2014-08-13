grunt = require 'grunt'

module.exports = ->

  tails = /^[\s]+|([\s\|\%]+$)/g

  unless grunt.option('m')?
    grunt.fail.warn('-m option missed')

  message = grunt.option('m').replace(tails, '')

  if _.indexOf(message, "%") > 1
    [message, changes] = message.split('%')

  message = message.replace(tails, '')

  # UP VERSION -----------------------------------------
  build = grunt.file.readJSON('package.json')

  types = ['major', 'minor', 'revision']
  type = grunt.option('type') || 'revision'

  unless type in types
    grunt.fail.fatal "unknown version type #{type}"

  version = _.map build.version.split('.'), (e) ->
    parseInt(e)

  type_index = _.indexOf types, type
  version[type_index] += 1

  for i in [(type_index+1)...types.length]
    version[i] = 0

  build.version = version.join '.'

  grunt.log.ok "bump #{type} version to #{build.version}"

  if type isnt 'revision'
    grunt.file.write '.tag', build.version

  # write commit message for push task
  grunt.file.write '.commit', message

  # UPDATE CHANGELOG -----------------------------------
  if changes
    changes = _.map changes.replace(tails, '').split('|'), (c) -> c.replace tails, ''
    changelog = grunt.file.read('CHANGELOG.md')
    grunt.file.write 'CHANGELOG.md', "### #{build.version}\n  **#{message}**\n  - #{changes.join('\n  - ')}\n\n#{changelog}"

  grunt.file.write 'package.json', JSON.stringify(build, null, 2)
