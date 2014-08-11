Parser = require 'coffee-react-transform/lib/parser'
Stream = require 'stream'
gutil  = require 'gulp-util'


class Docparse extends Stream.Transform

  constructor: (@opts) ->
    @_commentProp = /^# @([\w.-]+):/
    super(objectMode: true)

  _transform: (file, _, callback) ->
    source = file.contents.toString()

    ast = new Parser().parse(source, @opts)
    comments = (n.value for n in ast.children when n.type is 'CS_COMMENT')

    props = {}
    for comment in comments
      for k, v of @_commentProps(comment)
        props[k] = v

    props.path   = file.relative
    props.source = source
    contents = 'module.exports=' + JSON.stringify(props)

    file = new gutil.File
      base:     file.base
      cwd:      file.cwd
      path:     gutil.replaceExtension(file.path, '.js')
      contents: new Buffer(contents)
    callback(null, file)

  _commentProps: (comment) ->
    props = {}

    key = undefined
    buf = []

    for line in comment.split('\n')
      match = line.match @_commentProp
      if match?
        if key?
          props[key] = buf.join('\n')
          key = undefined
          buf = []

        key = match[1]
        buf = [line[match[0].length...]]
      else if key?
        buf.push(line[2...])

    if key?
      props[key] = buf.join('\n')

    props

module.exports = (opts={}) -> new Docparse(opts)
