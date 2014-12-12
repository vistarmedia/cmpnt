# @name: Editable
#
# @description: # Wraps an input element so it displays as a regular element
# that is then editable.
#
# The `onChange` prop will be called with the value of the input when blurred or
# when the user hits the enter key in the input.
#
# @example: ->
#   React.createClass
#
#     getInitialState: ->
#       value:   'Edit me!'
#
#     onChange: (value) ->
#       @setState value: value
#
#     render: ->
#       <div>
#         <Editable onChange=@onChange value=@state.value>
#           <input defaultValue=@state.value />
#         </Editable>
#       </div>


React      = require 'react'
{classSet} = require('react/addons').addons

Icon = require '../ui/icon'


Editable = React.createClass
  displayName: 'Editable'

  propTypes:
    onChange:  React.PropTypes.func
    value:     React.PropTypes.string

  getInitialState: ->
    editing: false

  handleChange: (e) ->
    @props.onChange?(e.target.value)
    @setState editing: false

  onBlur: (e) ->
    @handleChange(e)

  onClick: (e) ->
    @setState editing: true

  onKeyDown: (e) ->
    if e.key is 'Enter'
      e.preventDefault()
      e.stopPropagation()
      @handleChange(e)

  componentDidUpdate: ->
    if @state.editing
      input = @getDOMNode().querySelector('input')
      input.focus()
      # setting value from value here is just to move the cursor to the end of
      # whatever content might exist in the input element
      input.value = input.value

  render: ->
    <span className=@_className()>
      <Element onClick=@onClick active=@state.editing>
        <span className='value'>
          {@props.value}
        </span>

        <span className='input' onBlur=@onBlur onKeyDown=@onKeyDown>
          {@props.children}
        </span>
      </Element>
    </span>

  _className: ->
    classSet
      editable:  true
      editing:   @state.editing
      viewing:   not @state.editing


Element = React.createClass
  displayName: 'Editable.Element'

  propTypes:
    onClick: React.PropTypes.func.isRequired
    active:  React.PropTypes.bool

  getDefaultProps: ->
    active: false
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

  onClick: (e) ->
    @props.onClick?(e)

  render: ->
    <span
      className   = @_classes()
      onMouseOver = @handleMouseOver
      onMouseOut  = @handleMouseOut
      onClick     = @onClick
      >
      {@props.children}
      {@_icon()}
    </span>

  isOpened: ->
    @state.hovering or @props.active

  _icon: ->
    if @isOpened()
      <Icon className='edit-icon' name='edit' />
    else
      null

  _classes: ->
    classSet
      'editable-element':  true
      active:              @isOpened()


Editable.Element = Element
module.exports   = Editable
