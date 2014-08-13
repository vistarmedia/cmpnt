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
React       = require 'react'
{classSet}  = require('react/addons').addons


Button = React.createClass

  propTypes:
    onClick: React.PropTypes.func

  onClick: (e) ->
    e?.preventDefault()
    @props.onClick?()

  render: ->
    classes = classSet
      'btn':          true
      'btn-default':  true
      'btn-lg':       true
      'disabled':     @props.disabled

    <button className={classes} onClick=@onClick>
      {@props.children}
    </button>


module.exports = Button
