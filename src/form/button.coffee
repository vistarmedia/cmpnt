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


Button = React.createClass
  displayName: 'Button'

  propTypes:
    onClick:    React.PropTypes.func
    className:  React.PropTypes.string

  onClick: (e) ->
    e?.preventDefault()
    @props.onClick?()

  render: ->
    classes = if @props.className? then [@props.className] else []
    classes = classes.concat('btn', 'btn-default', 'btn-large')
    classes.push 'disabled' if @props.disabled

    <button className={classes.join(' ')} onClick=@onClick>
      {@props.children}
    </button>


module.exports = Button
