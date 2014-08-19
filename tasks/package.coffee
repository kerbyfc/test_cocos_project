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
  inspect data.jsList
  grunt.file.write 'project.json', stringify(data)
