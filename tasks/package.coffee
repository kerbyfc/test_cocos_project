grunt = require 'grunt'

module.exports = ->

  # read project.json
  conf = grunt.config('package')
  data = grunt.file.readJSON 'project.json'

  # form jsList array
  data.jsList = []
  for path in conf.jsList
    for file in grunt.file.expand {cwd: ''}, "src/#{path}"
      data.jsList.push file

  # remove duplicates
  data.jsList = _.uniq data.jsList

  # write file
  json = JSON.stringify data, null, 2
  grunt.log.writeln "Project config: \n#{json}"
  grunt.file.write 'project.json', json
