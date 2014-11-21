# @name: Button
#
# @description: Renders a button and calls the given `onClick` function, if
# given, when clicked. Any children passed will be redirected inside the button.
# Passing a type will style the button accordingly.
#
# @example: ->
#   React.createClass
#     onClick: ->
#       alert "oh no you didn't!"
#
#     render: ->
#       <Button type='primary' onClick=@onClick>Careful now!</Button>
React      = require 'react'
{classSet} = require('react/addons').addons


Button = React.createClass
  displayName: 'Button'

  propTypes:
    onClick:     React.PropTypes.func
    className:   React.PropTypes.string
    type:
      React.PropTypes.oneOf [
        'default'
        'primary',
        'link',
        'success',
        'info',
        'warning',
        'danger'
      ]

  getDefaultProps: ->
    type: 'default'

  onClick: (e) ->
    e?.preventDefault()
    @props.onClick?()

  render: ->
    classes =
      btn:      true
      disabled: @props.disabled
    classes['btn-large'] = true
    classes["btn-#{@props.type}"] = true

    if @props.className?
      classes[@props.className] = true

    <button className=classSet(classes) onClick=@onClick>
      {@props.children}
    </button>


module.exports = Button
