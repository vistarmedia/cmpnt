Parser        = require 'coffee-react-transform/lib/parser'
serializeJsx  = require 'coffee-react-transform/lib/serialiser'
Stream      = require 'stream'
coffee      = require 'coffee-script'
gutil       = require 'gulp-util'
jsxToCoffee = require 'coffee-react-transform'


class Source

  @fromJsx: (jsx) ->
    ast = new Parser().parse(jsx)
    comments = (n.value for n in ast.children when n.type is 'CS_COMMENT')
    new Source(comments, serializeJsx(ast))

  constructor: (@comments, @source) ->
    exprs = coffee.nodes(@source).expressions
    @views = @_viewDeclarations(exprs)

  _viewDeclarations: (nodes) ->
    node for node in nodes when @_isViewDeclaration(node)

  _isViewDeclaration: (node) ->
    console.log @_propName(node.variable)
    variable = node.value?.variable
    return false unless variable and variable.properties
    properties = variable.properties

    return variable.base?.value is 'React' and \
      properties[0]?.name?.value is 'createClass'

  _propName: (node) ->
    node

class Docparse extends Stream.Transform

  constructor: () ->
    @_commentProp = /^# @([\w.-]+):/
    super(objectMode: true)

  _transform: (file, _, callback) ->
    jsx    = file.contents.toString()
    source = Source.fromJsx(jsx)
    return

    ast = new Parser().parse(source)
    console.log '------------------------------'
    console.log serialise(ast)
    console.log '------------------------------'
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
