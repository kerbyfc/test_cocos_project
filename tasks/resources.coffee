grunt = require 'grunt'

module.exports = ->

  re = "res/**/*[^0-9].{png,jpg,plist,gif,fsh,vsh}"
  r = {}

  r[key] = file for file in grunt.file.expand re when key = [file.replace(/\./g, '_').split('/').slice(-1)]

  inspect r

  grunt.file.write "src/res.js",
    grunt.file.read("src/res.tpl").replace "[[[RESOURCES]]]", stringify(r)
