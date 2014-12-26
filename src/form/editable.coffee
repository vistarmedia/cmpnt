# @name: Editable
#
# @description: Wraps an input element so it displays as a regular element
# that is then editable when clicked.
#
# The `onChange` prop will be called with the value of the input when blurred or
# when the user hits the enter key in the input.
#
# The example shows usage with input, select, and textarea elements wrapped.
# The input and textarea elements share a state value; update one and the other
# will update as well.
#
# @example: ->
#   React.createClass
#
#     getDefaultProps: ->
#       items: [
#         {id: 'id-1', content: 'Horses'}
#         {id: 'id-2', content: 'Lemons'}
#         {id: 'id-3', content: 'Oranges'}
#         {id: 'id-4', content: 'Pears'}
#       ]
#
#     getInitialState: ->
#       inputValue:   'Edit me!'
#       selectValue:  'id-1'
#
#     onChangeInput: (value) ->
#       @setState inputValue: value
#
#     onChangeSelect: (value) ->
#       @setState selectValue: value
#
#     render: ->
#       <div>
#         <label htmlFor='input-example'>input example</label>
#         <Editable onChange=@onChangeInput value=@state.inputValue>
#           <input id='input-example' defaultValue=@state.value />
#         </Editable>
#         <label htmlFor='select-example'>select example</label>
#         <Editable onChange=@onChangeSelect value=@_selected().content>
#           <select id='select-example'>
#             {@_options()}
#           </select>
#         </Editable>
#         <label htmlFor='textarea-example'>textarea example</label>
#         <Editable onChange=@onChangeInput value=@state.inputValue>
#           <textarea defaultValue=@state.inputValue />
#         </Editable>
#       </div>
#
#     _selected: ->
#       _.find @props.items, (e) => e.id == @state.selectValue
#
#     _options: ->
#       for item in @props.items
#         <option key=item.id value=item.id>{item.content}</option>


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
      input = @_childInputElement()
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

  _childInputElement: ->
    @getDOMNode().querySelector('input, textarea, select')

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
