grunt = require 'grunt'

# to use lodash in all custom tasks
global._ = require './vendor/lodash.js'

global.stringify = (obj) ->
  JSON.stringify obj, null, 2

global.inspect = (objs...) ->
  for obj in objs
    grunt.log.debug "\n" + stringify(obj)

module.exports = (grunt) ->

  sources = _.map [
    'app/helpers'
    'env'
    'res'
    'app/skeleton'
    'app/*'
    'layers/**/*'
    'scenes/**/*'
  ], (p) -> "coffee/#{p}.coffee"

  grunt.initConfig

    coffee:

      options:
        sourceMap: true
        bare: true
      compile:
        files:
          'src/app.js': sources

    concat:

      main:
        files:
          'main.js': ['vendor/*.js', 'boot.js']

    watch:

      coffee:
        files: ['coffee/**/*.coffee']
        tasks: ['coffee']

      main:
        files: ['boot.js', 'vendor/**/*.js']
        tasks: ['concat:main']

      sprites:
        files: ['res/sprites/*.{png,jpg,plist}']
        tasks: ['resources']
        options:
          spawn: false

    shell:
      run:
        command: 'cocos run -p web'

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-spritesmith'

  for file in grunt.file.expand {cwd: 'tasks'}, '*.coffee'
    grunt.registerTask file.replace(/\.coffee$/, ''), require("./tasks/#{file}")

  grunt.registerTask 'default', [
    'resources'
    'coffee'
    'concat'
    'watch'
  ]

