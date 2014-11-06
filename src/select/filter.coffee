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
# The "onChange" property will be called with a list of the values of the
# selected items.
#
# @example: ->
#
#   React.createClass
#
#     getInitialState: ->
#       selected: []
#       items: [
#         {name: 'item 1', value: 'id-1'}
#         {name: 'item 2', value: 'id-2'}
#         {name: 'item 3', value: 'id-3'}
#         {name: 'item 4', value: 'id-4'}
#         {name: 'item 5', value: 'id-5'}
#         {name: 'item 6', value: 'id-6'}
#         {name: 'item 7', value: 'id-7'}
#         {name: 'item 8', value: 'id-8'}
#         {name: 'item 9', value: 'id-9'}
#       ]
#
#     updateSelections: (list) ->
#       @setState selected: list
#
#     _selectedItems: ->
#       for value in @state.selected
#         <li data-value=value>
#           {value}
#         </li>
#
#     render: ->
#       <div className='container'>
#         <div className='row'>
#           <div className='col-xs-2'>
#             <SelectFilter options=@state.items
#                           onChange=@updateSelections />
#           </div>
#           <div className='col-xs-2'>
#             <ul>
#               {@_selectedItems()}
#             </ul>
#           </div>
#         </div>
#       </div>
#


React      = require 'react'
{classSet} = require('react/addons').addons

Types      = require '../types'

SelectList = require './list'


defaultFilter = (options, term) ->
  if not term
    return options
  o for o in options when o.name?.toLowerCase() == term.toLowerCase()


SelectFilter = React.createClass
  displayName: 'SelectFilter'

  propTypes:
    options:   Types.nameValueList.isRequired
    filter:    React.PropTypes.func
    onChange:  React.PropTypes.func

  getDefaultProps: ->
    filter: defaultFilter

  getInitialState: ->
    opened:        false
    filterTerm:    undefined
    selected:      []
    filtered:      @props.options

  filterResults: (term) ->
    @props.filter?(@props.options, term) or @props.options

  onUpdateFilter: (term) ->
    @setState
      filtered:   @filterResults(term)

  open: ->
    @setState opened: true

  close: (e) ->
    @setState opened: false, focusList: false

  onInputBlur: (e) ->
    if not e.relatedTarget
      @close()

  onInputFocus: (e) ->
    @open()

  giveListFocus: (inputValue) ->
    @setState focusList: true

  setSelected: (list) ->
    @setState
      selected:      list
      focusList:     false
      opened:        false
    @props.onChange?(list)

  render: ->
    <div className='btn-group select-filter'>
      <Input onFocus  = @onInputFocus
             onBlur   = @onInputBlur
             onChange = @onUpdateFilter
             onCommit = @giveListFocus
             />
      <SelectList options     = @state.filtered
                  visible     = @state.opened
                  shouldFocus = @state.focusList
                  onChange    = @setSelected
                  />
    </div>


Input = React.createClass
  displayName: 'SelectFilter.Input'

  propTypes:
    onChange: React.PropTypes.func
    onCommit: React.PropTypes.func
    onFocus:  React.PropTypes.func
    onBlur:   React.PropTypes.func
    value:    React.PropTypes.string

  getDefaultProps: ->
    hint:       'Select an item...'
    value:      ''
    commitKeys: ['Enter', 'ArrowDown']

  onKeyUp: (e) ->
    @props.onChange?(e.target.value)

  onKeyDown: (e) ->
    if e.key in @props.commitKeys
      e.preventDefault()
      e.stopPropagation()
      @props.onCommit?(e.target.value)

  onFocus: (e) ->
    @props.onFocus?(e)

  onBlur: (e) ->
    @props.onBlur?(e)

  render: ->
    <span className='input'>
      <input className    = 'dropdown-toggle'
             type         = 'text'
             autoComplete = 'off'
             onFocus      = @onFocus
             onKeyUp      = @onKeyUp
             onKeyDown    = @onKeyDown
             onBlur       = @onBlur
             />
    </span>


SelectFilter.Input = Input


module.exports = SelectFilter
