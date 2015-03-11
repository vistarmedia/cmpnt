# @name: SelectFilter
#
# @description:  For filtering and selecting items.
#
# The filtering can be customized by passing a custom function to the filter
# prop.  This function will be called with the list of available options and the
# value of the filter input.
#
# Pressing enter or the down arrow on the keyboard will focus the list in its
# current state.
#
# The "onChange" property will be called with a list of the selected items.
#
# @example: ->
#
#   React.createClass
#
#     getInitialState: ->
#       selected: []
#       items: [
#         {content: 'item 1', id: 'id-1'}
#         {content: 'item 2', id: 'id-2'}
#         {content: 'item 3', id: 'id-3'}
#         {content: 'item 4', id: 'id-4'}
#         {content: 'item 5', id: 'id-5'}
#         {content: 'item 6', id: 'id-6'}
#         {content: 'item 7', id: 'id-7'}
#         {content: 'item 8', id: 'id-8'}
#         {content: 'item 9', id: 'id-9'}
#       ]
#
#     handleSelections: (list) ->
#       @setState selected: list
#
#     render: ->
#       <div className='container'>
#         <div className='row'>
#           <div className='col-xs-2'>
#             <SelectFilter options  = @state.items
#                           onChange = @handleSelections
#                           value    = @state.selected />
#           </div>
#           <div className='col-xs-2'>
#             <ul>
#               {@_selectedItems()}
#             </ul>
#           </div>
#         </div>
#       </div>
#
#     _selectedItems: ->
#       for item in @state.selected
#         <li data-value=item.id key=item.id>
#           {item.content}
#         </li>


_          = require 'lodash'
React      = require 'react'
{classSet} = require('react/addons').addons

Types      = require '../types'

SelectList = require './list'


defaultFilter = (options, term) ->
  contentAsString = (content) ->
    if typeof content isnt 'string'
      throw Error('SelectFilter does not filter non-strings by default')
    content

  if not term or term.length is 0
    return options
  o for o in options when contentAsString(o.content)?.match(///#{term}///i)

SelectFilter = React.createClass
  displayName: 'SelectFilter'

  propTypes:
    className:     React.PropTypes.string
    defaultValue:  React.PropTypes.string
    filter:        React.PropTypes.func
    inputClass:    React.PropTypes.string
    onChange:      React.PropTypes.func
    options:       Types.idContentList.isRequired
    placeholder:   React.PropTypes.string
    value:         Types.idContentList

  getDefaultProps: ->
    filter: defaultFilter
    value:  []

  getInitialState: ->
    opened:        false
    filterTerm:    undefined
    filtered:      @filterResults()

  filterResults: (term) ->
    @props.filter?(@props.options, term) or @props.options

  onUpdateFilter: (term) ->
    @setState
      filterTerm: term
      filtered:   @filterResults(term)

  open: ->
    @setState opened: true

  close: (e) ->
    @setState opened: false, focusList: false

  onInputBlur: (e) ->
    if @_eventOnElementNotOnList(e)
      @close()

  onInputFocus: (e) ->
    @open()

  onBlurList: (e) ->
    @close()

  handleInputCommit: (inputValue) ->
    if @state.filtered.length is 1
      results = _.union @props.value, @state.filtered
      @props.onChange?(results)
      @setState focusList: false
    else
      @setState focusList: true

  setSelected: (list) ->
    @setState
      focusList:     false
      opened:        false
    @props.onChange?(list)

  _classes: ->
    classes =
      'btn-group':      true
      'select-filter':  true
    classes[@props.className] = @props.className?
    classSet classes

  render: ->
    <div className=@_classes()>
      <Input onFocus      = @onInputFocus
             onBlur       = @onInputBlur
             onChange     = @onUpdateFilter
             onCommit     = @handleInputCommit
             defaultValue = @props.defaultValue
             value        = @state.filterTerm
             ref          = 'input'
             className    = @props.inputClass
             placeholder  = @props.placeholder
             />
      <SelectList options     = @state.filtered
                  visible     = @state.opened
                  value       = @props.value
                  shouldFocus = @state.focusList
                  onChange    = @setSelected
                  onBlur      = @onBlurList
                  ref         = 'list'
                  />
    </div>

  _eventOnElementNotOnList: (e) ->
    not e.relatedTarget or (not e.relatedTarget?.className?.match(/list-item/))


Input = React.createClass
  displayName: 'SelectFilter.Input'

  propTypes:
    className:      React.PropTypes.string
    onBlur:         React.PropTypes.func
    onChange:       React.PropTypes.func
    onCommit:       React.PropTypes.func
    onFocus:        React.PropTypes.func
    onPaste:        React.PropTypes.func
    value:          React.PropTypes.string
    commitKeys:     React.PropTypes.array
    commitKeyCodes: React.PropTypes.array
    placeholder:    React.PropTypes.string

  getDefaultProps: ->
    value:          undefined
    commitKeys:     ['Enter', 'ArrowDown']
    commitKeyCodes: []

  getInitialState: ->
    focused: false

  onKeyUp: (e) ->
    @props.onChange?(e.target.value)

  onKeyDown: (e) ->
    if e.key in @props.commitKeys or e.keyCode in @props.commitKeyCodes
      e.preventDefault()
      e.stopPropagation()
      @props.onCommit?(e.target.value)

  focus: ->
    @setState focused: true

  onChange: (e) ->
    @props.onChange?(e.target.value)

  onFocus: (e) ->
    @props.onFocus?(e)

  onBlur: (e) ->
    @setState focused: false
    @props.onBlur?(e)

  value: ->
    if @props.value?
      @props.value
    else
      @props.defaultValue

  componentDidUpdate: ->
    if @state.focused
      @_inputElement().focus()

  render: ->
    classes = 'dropdown-toggle': true
    classes[@props.className] = true if @props.className?

    <span className='input'>
      <input className    = classSet(classes)
             type         = 'text'
             autoComplete = 'off'
             onFocus      = @onFocus
             onKeyUp      = @onKeyUp
             onKeyDown    = @onKeyDown
             onBlur       = @onBlur
             onChange     = @onChange
             onPaste      = @props.onPaste
             value        = @value()
             ref          = 'input'
             placeholder  = @props.placeholder
             />
    </span>

  _inputElement: ->
    @refs.input.getDOMNode()


SelectFilter.Input = Input
SelectFilter.defaultFilter = defaultFilter


module.exports = SelectFilter
