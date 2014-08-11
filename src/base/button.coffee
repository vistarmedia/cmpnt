React = require 'react'

# @name: Button
# @description: Renders a button and optionally performs some action when its
# clicked.
Button = React.createClass

  propTypes:
    label: React.PropTypes.string.isRequired #TODO: Not really


  render: ->
    <button>{@props.label}</button>


module.exports = {
  Button
}
