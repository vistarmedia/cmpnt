browserify  = require 'gulp-browserify'
cjsx        = require 'gulp-cjsx'
concat      = require 'gulp-concat'
connect     = require 'connect'
gulp        = require 'gulp'
gutil       = require 'gulp-util'
http        = require 'http'
less        = require 'gulp-less'
mocha       = require 'gulp-mocha'
serve       = require 'serve-static'

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
    require 'xunit-file'
    exitOnFinish runTests, proj, reporter, false


runTests = (project, reporter='dot', bail=true) ->
  gulp.src(project.test, read: false)
    .pipe(mocha(reporter: reporter, bail: bail))
    .on 'error', (err) ->
      gutil.log(err.toString())


getCurrentVersion = (cb) ->
  options =
    hostname: 'registry.npmjs.org'
    path:     '/cmpnt/'
    headers:
      'accept': 'application/json'

  out = []
  req = http.get options, (res) ->
    res.on 'data', (c) -> out.push(c)
    res.on 'end', -> cb(JSON.parse(Buffer.concat(out))['dist-tags']['latest'])

exitOnFinish = (func, args...) ->
  func(args...)
    .on 'error', -> process.exit(1)
    .on 'end',   -> process.exit(0)


gulp.task 'autoversion', ->
  getCurrentVersion (version) ->
    [major, minor, patch] = version.split('.')
    process.stdout.write "#{major}.#{minor}.#{Number(patch) + 1}"

gulp.task 'project:src', ->
  gulp.src(project.srcs)
    .pipe(cjsx())
    .pipe(gulp.dest(project.dest))


gulp.task 'project:test:watch', ->
  gulp.watch([project.srcs, project.test], -> runTests(project))

gulp.task 'serve', ->
  app = connect()
  app.use(serve(demo.dest))
  app.listen(process.env['PORT'] or 4011)

gulp.task 'watch:serve', ['serve'], ->
  gulp.watch([project.srcs, demo.srcs, demo.style], ['src', 'style', 'static'])


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

gulp.task 'test:watch', ['project:test:watch']

gulp.task 'default', ['src', 'style', 'static']
