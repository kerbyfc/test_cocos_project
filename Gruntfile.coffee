# to use lodash in all custom tasks
global._ = require './vendor/lodash.js'

module.exports = (grunt) ->
  grunt.initConfig

    coffee:
      options: {
        sourceMap: true
        bare: true
      }
      compile: {
        expand: true
        src: ['**/*.coffee']
        cwd: 'coffee'
        dest: 'src'
        ext: '.js'
      }

    package:
      jsList: [
        'res.js'
        'layers/**/*.js'
        'scenes/**/*.js'
        '**/*.js'
      ]

    watch:

      coffee:
        files: ['coffee/**/*.coffee']
        tasks: ['coffee']

      js:
        files: ['src/**/*.js']
        tasks: ['package']

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'

  for file in grunt.file.expand {cwd: 'tasks'}, '*.coffee'
    grunt.registerTask file.replace(/\.coffee$/, ''), require("./tasks/#{file}")

  grunt.registerTask 'default', [
    'coffee',
    'package',
    'watch'
  ]
