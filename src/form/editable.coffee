# @name: Editable
#
# @description: Wraps an input element so it displays as a regular element
# that is then editable when clicked.  If a blur or keyDown where the key is
# "Enter" is triggered on the wrapped element, the @onChange prop will be called
# with that event object.
#
# The example shows usage with input and select elements.  We're maintaining the
# current state of the input and select element using an `onChange` prop given
# to each of those elements.  The Editable component's `onChange` prop will be
# called when the "Enter" key is pressed in the input or when blurred, only if
# the relatedTarget is null or not contained by the Editable element.  This
# allows us to have additional, more complicated input elements wrapped by
# Editable without the `onChange` getting called unecessarily.  The `button`
# element next to the input is an example of this.
#
# The `value` prop given to Editable can be anything renderable.
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
#     now: -> (new Date).getTime()
#
#     getInitialState: ->
#       inputValue:   'Edit me!'
#       selectValue:  'id-1'
#       committedAt:  null
#       savedInput:   'Edit me!'
#       savedSelect:  'id-1'
#       commitCount:  0
#
#     handleCommit: ->
#       @setState
#         committedAt:  @now()
#         lastCommitAt: @lastCommitAt()
#         savedInput:   @state.inputValue
#         savedSelect:  @state.selectValue
#         commitCount:  @state.commitCount + 1
#
#     onCommitInput: (e) ->
#       @handleCommit()
#
#     onCommitSelect: (e) ->
#       @handleCommit()
#
#     onChangeInput: (e) ->
#       @setState
#         inputValue: e.target.value
#
#     onChangeSelect: (e) ->
#       @setState
#         selectValue: e.target.value
#
#     lastCommitAt: ->
#       at = Math.floor((@now() - (@state.committedAt or @now())) / 1000)
#       "#{at} seconds ago"
#
#     render: ->
#       inputView = <i>{@state.savedInput}</i>
#
#       <div>
#         <label htmlFor='input-example'>input example</label>
#         <Editable onChange=@onCommitInput value=inputView>
#           <input id           = 'input-example'
#                  defaultValue = @state.savedInput
#                  onChange     = @onChangeInput />
#           <button>Hi!</button>
#         </Editable>
#         <label htmlFor='select-example'>select example</label>
#         <Editable onChange = @onCommitSelect
#                      value = @_selected().content>
#           <select id='select-example' onChange=@onChangeSelect>
#             {@_options()}
#           </select>
#         </Editable>
#
#         <div className = 'committed'>
#           <h5>committed {@state.commitCount} times.  latest commit {@state.lastCommitAt}</h5>
#           <ul>
#             <li>
#               <b>input</b> {@state.savedInput}
#             </li>
#             <li>
#               <b>select</b> {@_selected().content}
#             </li>
#           </ul>
#         </div>
#       </div>
#
#     _selected: ->
#       _.find @props.items, (e) => e.id == @state.savedSelect
#
#     _options: ->
#       for item in @props.items
#         <option key=item.id value=item.id>{item.content}</option>


React      = require 'react'
_          = require 'lodash'
{classSet} = require('react/addons').addons

Icon = require '../ui/icon'

now = -> (new Date).getTime()


DebouncedChange =
  # sets a @debouncedChange var that is the debounced version of props.onChange

  componentDidMount: ->
    # we're using lodash's `runInContext` here so our tests using sinon's fake
    # timers work correctly
    _ = _.runInContext 'Date': Date
    if @props.onChange
      @debouncedChange = _.debounce @props.onChange, 250,
        leading: true, trailing: false


Editable = React.createClass
  displayName: 'Editable'

  mixins: [DebouncedChange]

  propTypes:
    onChange:  React.PropTypes.func
    value:     React.PropTypes.node

  getInitialState: ->
    editing: false

  handleChange: (e) ->
    @debouncedChange?(e)
    @setState
      editing: false

  onBlur: (e) ->
    @handleChange(e)

  onClick: (e) ->
    if not @state.editing
      @setState
        lastOpenedAt: now()
    @setState
      editing: true

  onKeyDown: (e) ->
    if e.key is 'Enter'
      e.preventDefault()
      e.stopPropagation()
      @handleChange(e)

  componentDidUpdate: ->
    if @state.editing and @_openedRecently()
      @_moveToEndOfInput()

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

  _moveToEndOfInput: ->
    input = @_childInputElement()
    input.focus()
    # setting value from value here is just to move the cursor to the end of
    # whatever content might exist in the input element
    input.value = input.value

  _openedRecently: ->
    now() - (@state.lastOpenedAt or now()) < 10

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
      onClick     = @onClick>
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
