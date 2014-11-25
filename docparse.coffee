Parser        = require 'coffee-react-transform/lib/parser'
coffee        = require 'coffee-script'
fs            = require 'fs'
gutil         = require 'gulp-util'
jsxTransform  = require 'coffee-react-transform'
path          = require 'path'
serializeJsx  = require 'coffee-react-transform/lib/serialiser'
through       = require 'through'


class Source

  @fromJsx: (jsx) ->
    ast = new Parser().parse(jsx)
    comments = (n.value for n in ast.children when n.type is 'CS_COMMENT')
    new Source(comments, serializeJsx(ast))

  constructor: (@comments, @source) ->
    @_commentProp = /^# @([\w.-]+):/
    @_lines = @source.split('\n')
    exprs = coffee.nodes(@source).expressions
    @views = @_viewDeclarations(exprs)

  _viewDeclarations: (nodes) ->
    node for node in nodes when @_isViewDeclaration(node)

  _isViewDeclaration: (node) ->
    variable = node.value?.variable
    return false unless variable and variable.properties
    properties = variable.properties

    return variable.base?.value is 'React' and \
      properties[0]?.name?.value is 'createClass'

  viewProps: ->
    @_viewProps(v) for v in @views

  _viewProps: (view) ->
    viewName = @_propName(view.variable)
    methods  = view.value.args[0].base.properties

    methodsByName = {}
    for method in methods
      name = method.variable.base.value
      body = method.value
      methodsByName[name] = body

    propTypes = @_extractProps(methodsByName.propTypes)

    name:      viewName
    propTypes: propTypes

  _extractProps: (node) ->
    return {} unless node?
    props = {}
    for p in node.base.properties
      name = p.variable.base.value
      props[name] = @_propName(p.value)
    props

  _propName: (node) ->
    unless node?.base?
      return @_rawSource(node)
    name = [node.base.value]
    for prop in node.properties
      name.push(prop.name.value)
    name.join('.')

  _rawSource: (node) ->
    loc = node.locationData
    lines = @_lines[loc.first_line..loc.last_line]
    lines[lines.length-1] = lines[lines.length-1][0..loc.last_column]
    lines[0] = lines[0][loc.first_column..]
    lines.join '\n'

  commentProps: ->
    props = {}
    for comment in @comments
      for k, v of @_commentProps(comment)
        props[k] = v
    props

  _commentProps: (comment) ->
    props = {}
    key   = undefined
    buf   = []

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


compileExample = (jsxSource) ->
  coffeeSource = jsxTransform(jsxSource)
  coffee.compile(coffeeSource, bare: on)


module.exports = (filename, opt={}) ->
  unless filename? then throw new gutil.PluginError('docparse', 'Missing filename for docparse')

  files = []
  firstFile = undefined

  bufferContents = (file) ->
    if file.isNull() then return
    files.push(file)

  endStream = ->
    unless files
      @emit('end')
      return

    lines = ['module.exports=[']
    for file, i in files
      jsx    = file.contents.toString()
      source = Source.fromJsx(jsx)
      props  = source.commentProps()
      if props.private? then continue

      props.path   = file.relative.replace('.coffee', '')
      props.source = source.source
      props.views  = source.viewProps()

      if props.example
        compiled = compileExample(props.example)
        if compiled?
          props.example_compiled = compiled

      style = file.path.replace('.coffee', '.less')
      if fs.existsSync(style)
        props.style = fs.readFileSync(style).toString()

      line = if i is 0
        JSON.stringify(props)
      else
        ",#{JSON.stringify(props)}"
      lines.push(line)
    lines.push '];'

    file = files[0].clone()
    file.path = path.join(files[0].base, filename)
    file.contents = new Buffer(lines.join('\n'))
    @emit('data', file)
    @emit('end')

  through(bufferContents, endStream)
