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
#         {node: 'item 1', id: 'id-1'}
#         {node: 'item 2', id: 'id-2'}
#         {node: 'item 3', id: 'id-3'}
#         {node: 'item 4', id: 'id-4'}
#         {node: 'item 5', id: 'id-5'}
#         {node: 'item 6', id: 'id-6'}
#         {node: 'item 7', id: 'id-7'}
#         {node: 'item 8', id: 'id-8'}
#         {node: 'item 9', id: 'id-9'}
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
#           {item.node}
#         </li>


_          = require 'lodash'
React      = require 'react'
{classSet} = require('react/addons').addons

Types      = require '../types'

SelectList = require './list'


defaultFilter = (options, term) ->
  nodeAsString = (node) ->
    if typeof node isnt 'string'
      throw Error('SelectFilter does not filter non-strings by default')
    node

  if not term or term.length is 0
    return options
  o for o in options when nodeAsString(o.node)?.match(///#{term}///i)

SelectFilter = React.createClass
  displayName: 'SelectFilter'

  propTypes:
    options:      Types.idNodeList.isRequired
    value:        Types.idNodeList
    inputClass:   React.PropTypes.string
    filter:       React.PropTypes.func
    onChange:     React.PropTypes.func

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

  render: ->
    <div className='btn-group select-filter'>
      <Input onFocus    = @onInputFocus
             onBlur     = @onInputBlur
             onChange   = @onUpdateFilter
             onCommit   = @handleInputCommit
             value      = @state.filterTerm
             ref        = 'input'
             className  = @props.inputClass
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

  getDefaultProps: ->
    value:          ''
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
             value        = @props.value
             ref          = 'input'
             />
    </span>

  _inputElement: ->
    @refs.input.getDOMNode()


SelectFilter.Input = Input
SelectFilter.defaultFilter = defaultFilter


module.exports = SelectFilter
