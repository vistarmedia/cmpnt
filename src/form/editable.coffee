# @name: Editable
#
# @description: Wraps child components so that on mouse over, a border
# and edit icon are displayed.
#
# @example: ->
#   React.createClass
#     render: ->
#       onClick = -> alert "Starting edit"
#
#       <Editable onClick=onClick>Edit me!</Editable>
React      = require 'react'

Icon = require '../ui/icon'


Editable = React.createClass
  displayName: 'Editable'

  propTypes:
    onClick: React.PropTypes.func.isRequired

  getDefaultProps: ->
    onClick: ->

  getInitialState: ->
    hovering: false

  handleMouseOver: (e) ->
    @setState hovering: true

  handleMouseOut: (e) ->
    if e.currentTarget.contains e.relatedTarget
      @setState hovering: true
    else
      @setState hovering: false

  render: ->
    if @state.hovering
      <span
        className='editable active'
        onMouseOut=@handleMouseOut
        onClick=@props.onClick>
        <Icon className='edit-icon' name='edit' />
        {@props.children}
      </span>
    else
      <span className='editable' onMouseOver=@handleMouseOver>
        {@props.children}
      </span>


module.exports = Editable
