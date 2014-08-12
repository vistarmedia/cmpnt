React = require 'react'

Zip = React.pants
Zap = React.zap

Rock = React.rock
  always: true

# @name: Button
# @description: Renders a button and optionally performs some action when its
# clicked.
Button = React.createClass

  propTypes:
    label: React.PropTypes.string.isRequired #TODO: Not really


  render: ->
    <button>{@props.label}</button>


class Foobar

module.exports = {
  Button
}
