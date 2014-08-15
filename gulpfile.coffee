_           = require 'xunit-file'
browserify  = require 'gulp-browserify'
cjsx        = require 'gulp-cjsx'
concat      = require 'gulp-concat'
gulp        = require 'gulp'
gutil       = require 'gulp-util'
less        = require 'gulp-less'
mocha       = require 'gulp-mocha'

docparse    = require './docparse'


project =
  dest:   './build/'
  src:    './src/index.coffee'
  srcs:   './src/**/*.coffee'
  style:  './src/**/*.less'
  test:   './test/**/*_spec.coffee'

demo =
  dest:   './demo/build/'
  doc:    './demo/src/doc'
  src:    './demo/src/index.coffee'
  srcs:   './demo/src/**/*.coffee'
  static: './demo/static/**'
  style:  './demo/style/index.less'
  test:   './test-demo/**/*_spec.coffee'


gulp.task 'project:doc', ->
  gulp.src(project.srcs)
    .pipe(docparse('index.js'))
    .pipe(gulp.dest(demo.doc))


gulp.task 'project:style', ->
  gulp.src(project.style)
    .pipe(concat('index.less'))
    .pipe(gulp.dest(project.dest))


_sourceTask = (name, proj, deps=[]) ->
  gulp.task name, deps, ->
    gulp.src(proj.src, read: false)
      .pipe(browserify({
        transform:  ['coffeeify']
        extensions: ['.coffee']
      }))
      .pipe(concat('app.js'))
      .pipe(gulp.dest(proj.dest))


_styleTask = (name, proj, deps=[]) ->
  gulp.task name, deps, ->
    gulp.src(proj.style)
      .pipe(less())
      .pipe(concat('app.css'))
      .pipe(gulp.dest(proj.dest))


_staticTask = (name, proj) ->
  gulp.task name, ->
    gulp.src(proj.static)
      .pipe(gulp.dest(proj.dest))


_testTask = (name, proj, reporter='dot', bail=true) ->
  gulp.task name, ->
    gulp.src(proj.test, read: false)
      .pipe(mocha(reporter: reporter, bail: bail))
      .on 'error', (err) ->
        console.log(err.toString())
        @emit('end')


gulp.task 'project:src', ->
  gulp.src(project.srcs)
    .pipe(cjsx())
    .pipe(gulp.dest(project.dest))


_sourceTask('demo:src', demo, ['project:doc'])

_styleTask('demo:style', demo, ['project:style'])

_staticTask('demo:static', demo)
_staticTask('project:static', project)

_testTask('demo:test', demo)
_testTask('project:test', project)
_testTask('project:test:xunit', project, reporter='xunit-file', bail=false)

gulp.task 'project', ['project:src', 'project:style']

gulp.task 'src', ['demo:src']

gulp.task 'style', ['project:style', 'demo:style']

gulp.task 'static', ['demo:static']

gulp.task 'test', ['project:test']

gulp.task 'default', ['src', 'style', 'static']
