# @name: Button
#
# @description: Renders a button and calls the given `onClick` function, if
# given, when clicked. Any children passed will be redirected inside the button.
#
# @example:
#   Button = require 'base/button'
#
#   <Button onClick=alert('Oops')>Careful now!</Button>
#
React = require 'react'

Button = React.createClass

  propTypes:
    onClick: React.PropTypes.func

  render: ->
    <button>{@props.children}</button>


module.exports = Button
