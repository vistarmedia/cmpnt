# @name: Button
#
# @description: Renders a button and calls the given `onClick` function, if
# given, when clicked. Any children passed will be redirected inside the button.
#
# @example: ->
#   React.createClass
#     onClick: ->
#       alert "oh no you didn't!"
#
#     render: ->
#       <Button onClick=@onClick>Careful now!</Button>
React = require 'react'

Button = React.createClass

  propTypes:
    onClick: React.PropTypes.func

  render: ->
    <button>{@props.children}</button>


module.exports = Button
