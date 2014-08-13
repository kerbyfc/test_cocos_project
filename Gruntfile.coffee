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
        'env.js'
        'res.js'
        'layers/**/*.js'
        'scenes/**/*.js'
        'app.js'
      ]

    concat:

      vendors:
        files:
          'main.js': ['vendor/lodash.js', 'main.js']

    watch:

      coffee:
        files: ['coffee/**/*.coffee']
        tasks: ['coffee']

      js:
        files: ['src/**/*.js']
        tasks: ['package']

    shell:

      gco_package:
        command: 'git checkout -f package.json'

      gco_changelog:
        command: 'git checkout -f CHANGELOG.md'

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-shell'

  for file in grunt.file.expand {cwd: 'tasks'}, '*.coffee'
    grunt.registerTask file.replace(/\.coffee$/, ''), require("./tasks/#{file}")

  grunt.registerTask 'default', [
    'coffee',
    'concat',
    'package',
    'watch'
  ]
