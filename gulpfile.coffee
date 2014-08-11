require 'gulp-cjsx'

browserify  = require 'gulp-browserify'
concat      = require 'gulp-concat'
gulp        = require 'gulp'
gutil       = require 'gulp-util'
less        = require 'gulp-less'
mocha       = require 'gulp-mocha'

docparse    = require './docparse'


project =
  src:    './src/index.coffee'
  dest:   './build/'
  srcs:   './src/**/*.coffee'

demo =
  dest:   './demo/build/'
  src:    './demo/src/index.coffee'
  srcs:   './demo/src/**/*.coffee'
  static: './demo/static/**'
  style:  './demo/style/index.less'


gulp.task 'project:doc', ->
  gulp.src(project.srcs)
    .pipe(docparse())
    .pipe(gulp.dest(project.dest))

_sourceTask = (name, proj) -> gulp.task name, ->
    gulp.src(proj.src, read: false)
      .pipe(browserify({
        transform:  ['coffeeify']
        extensions: ['.coffee']
      }))
      .pipe(concat('app.js'))
      .pipe(gulp.dest(proj.dest))


_styleTask = (name, proj) ->
  gulp.task name, ->
    gulp.src(proj.style)
      .pipe(less())
      .pipe(concat('app.css'))
      .pipe(gulp.dest(proj.dest))


_staticTask = (name, proj) ->
  gulp.task name, ->
    gulp.src(proj.static)
      .pipe(gulp.dest(proj.dest))

_testTask = (name, proj) ->
  gulp.task name, ->
    gulp.src(proj.test, read: false)
      .pipe(mocha(reporter: 'dot', bail: true))
      .on 'error', (err) ->
        console.log(err.toString())
        @emit('end')


_sourceTask('demo:src', demo)
_sourceTask('project:src', project)

_styleTask('demo:style', demo)
_styleTask('project:style', project)

_staticTask('demo:static', demo)
_staticTask('project:static', project)

_testTask('demo:test', demo)
_testTask('project:test', project)


gulp.task 'src', ['demo:src']

gulp.task 'style', ['demo:style']

gulp.task 'static', ['demo:static']

gulp.task 'default', ['src', 'style', 'static']
