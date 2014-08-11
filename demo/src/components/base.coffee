React = require 'react'

Component = require './index'

Butt = React.createClass
  propTypes:
    name: React.PropTypes.string.isRequired

  render: ->
    'hi hi hi'


Button = React.createClass
  render: ->
    <Component
      name        = 'button'
      component   = Butt
      description = 'Button-y clicker thing'>

      <button key='button' type='button' className='btn btn-default btn-lg'>
        Bonjour!
      </button>

    </Component>


module.exports = [
  Button
]
