React = require 'react'

Button = require '../../src/form/button'
Icon   = require '../../src/ui/icon'

compile = (src) -> eval(src)()

RunExample = React.createClass
  propTypes:
    code: React.PropTypes.string.isRequired
    func: React.PropTypes.string

  getInitialState: ->
    factory = compile(@props.func)
    unless factory? then return {}

    component: factory()

  render: ->
    <span>
      <h4>Example</h4>
      <pre>{@props.code}</pre>
      <hr/>
      {@state.component}
    </span>


module.exports = RunExample
