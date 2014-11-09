# @name: Select List
#
# @description:  A list of things that can be selected, think similar to an
# autocomplete dropdown.
#
# It is hidden by default and expected to be opened and closed by a parent
# component using its "visible" prop.  When it is visible it will grab the arrow
# up, arrow down, and enter key for navigating, selecting, and deselecting
# items.
#
# The 'selected' prop can be used to allow a parent component to set selections.
#
# The function given to the "onChange" prop will be called with a list of
# selected items when one is added or removed.
#
# The function given to the "onKeyDown" prop will be called on for events that
# happen using the arrow up and arrow down keys and it will be called with the
# synthetic event object and the value of @state.focused
#
# The 'onBlur' prop will be called only if an onBlur is triggered on a non-list
# item element, allowing for custom close behavior for instance.
#
# It expects an array of things to render in the "value" prop.  It requires
# objects with a key "name" (for the display name) and "value" (for an
# identifier).
#
#
# @example: ->
#   React.createClass
#
#     getInitialState: ->
#       showSelect: false
#       items: []
#
#     getDefaultProps: ->
#       items: [
#         {name: 'custom made',        value: 'ani-1'}
#         {name: 'custom paid',        value: 'ani-2'}
#         {name: 'just custom fitted', value: 'ani-3'}
#       ]
#
#     toggleSelect: (e) ->
#       e.preventDefault()
#       @setState(showSelect: not @state.showSelect)
#
#     _showOrHideText: ->
#       if @state.showSelect
#         'Hide'
#       else
#         'Show'
#
#     onChange: (selectedItems) ->
#       @setState
#         items: selectedItems
#
#     _selectedItems: ->
#       for item in @state.items
#         <li key=item.value className='list-group-item'>{item.name}</li>
#
#     render: ->
#       <div className='container'>
#         <div className='row'>
#           <div className='dropdown col-xs-2'>
#             <a href='#' onClick=@toggleSelect>
#               {@_showOrHideText()} Luda's questions.  Are you?:
#             </a>
#             <SelectList options = @props.items
#               selections        = @state.items
#               visible           = @state.showSelect
#               onChange          = @onChange
#               />
#           </div>
#           <ul className='list-group col-xs-2'>
#             {@_selectedItems()}
#           </ul>
#         </div>
#       </div>


_          = require 'lodash'
React      = require 'react'
{classSet} = require('react/addons').addons

Types      = require '../types'


SelectList = React.createClass
  displayName: 'SelectList'

  propTypes:
    options:      Types.nameValueList.isRequired
    selections:   Types.nameValueList
    onChange:     React.PropTypes.func
    visible:      React.PropTypes.bool
    shouldFocus:  React.PropTypes.bool
    onKeyDown:    React.PropTypes.func
    onKeyUp:      React.PropTypes.func
    onBlur:       React.PropTypes.func

  getDefaultProps: ->
    visible:      false
    shouldFocus:  false
    selections:   []

  getInitialState: ->
    selected:  []
    focused:   null

  _keys: [
    'ArrowDown'
    'ArrowUp'
  ]

  onSelect: (name, value) ->
    selections = _(_.clone(@props.selections))
      .push(name: name, value: value).value()
    @setState
      selected: selections
      focused: value, ->
        @props.onChange?(selections)

  onDeselect: (name, value) ->
    selections = (_(@props.selections).filter((e) ->
      e.value != value)).value()
    @setState
      selected: selections
    @props.onChange?(selections)

  _itemForValue: (value) ->
    @refs[value]

  _focusItem: ->
    component = @_itemForValue(@state.focused)
    component?.setFocus(true)

  _selectedNotInList: (list) ->
    @state.focused not in _(list).pluck('value')

  _shouldSetDefaultFocusedState: (props) ->
    props.shouldFocus and @_selectedNotInList(props.options)

  _firstNotSelectedItem: (props) ->
    selectedValues = _(props.selections).pluck('value').value()
    item = _.find props.options, (e) => e.value not in selectedValues
    item?.value or props.selections[0]?.value

  componentWillReceiveProps: (nextProps) ->
    @setState
      selected: nextProps.selections

    if @_shouldSetDefaultFocusedState(nextProps)
      @setState(focused: @_firstNotSelectedItem(nextProps))
    else
      @setState(focused: null)

  componentDidUpdate: ->
    if @props.shouldFocus
      @_focusItem()

  onKeyDown: (e) ->
    if @props.visible and e.key in @_keys
      e.stopPropagation()
      e.preventDefault()
      if e.key == 'ArrowUp'
        @_selectPrev(@state.focused)
      if e.key == 'ArrowDown'
        @_selectNext(@state.focused)
      @props.onKeyDown?(e, @state.focused)

  _indexForValue: (value) ->
    _.findIndex @props.options, (e) ->
      e.value is value

  _selectNext: (value) ->
    index = @_indexForValue(value)
    if (index + 1) < @props.options.length
      @select(@props.options[index + 1])

  _selectPrev: (value) ->
    index = @_indexForValue(value)
    if index isnt 0
      @select(@props.options[index - 1])

  select: (element) ->
    @setState focused: element.value

  onKeyUp: (e) ->
    if @props.visible
      e.stopPropagation()
      e.preventDefault()

  _setFocusedItem: (name, value) ->
    @select(name: name, value: value)

  _isItemSelected: (item) ->
    (_(@state.selected).find value: item.value)?

  onBlur: (e) ->
    if not e.relatedTarget?.className.match(/list-item/)
      @props.onBlur?(e)

  _items: ->
    for item in @props.options
      <SelectItem key        = item.value
                  name       = item.name
                  ref        = item.value
                  value      = item.value
                  selected   = @_isItemSelected(item)
                  isActive   = {item.value is @state.focused}
                  onSelect   = @onSelect
                  onDeselect = @onDeselect
                  onHover    = @_setFocusedItem
                  />

  render: ->
    <ul className = @_classes()
        onKeyDown = @onKeyDown
        onKeyUp   = @onKeyUp
        onBlur    = @onBlur>
      {@_items()}
    </ul>

  _classes: ->
    classes =
      'dropdown-menu':  true
      'select-list':    true
      list:             true
      hidden:           not @props.visible

    classSet(classes)


SelectItem = React.createClass
  displayName: 'SelectItem'

  propTypes:
    name:        React.PropTypes.string.isRequired
    value:       React.PropTypes.string.isRequired
    href:        React.PropTypes.string
    tabIndex:    React.PropTypes.string
    selected:    React.PropTypes.bool
    hovered:     React.PropTypes.bool
    isActive:    React.PropTypes.bool
    onSelect:    React.PropTypes.func
    onDeselect:  React.PropTypes.func
    onFocus:     React.PropTypes.func

  getDefaultProps: ->
    tabIndex:  '-1'
    selected:  false
    hovered:   false
    isActive:  false
    href:      '#'

  getInitialState: ->
    hovered:  @props.hovered
    selected: @props.selected

  selected: (bool) ->
    @setState(selected: bool)
    @setState(hovered: bool)

  setFocus: (bool) ->
    @setState hovered: bool, ->
      if bool
        anchor = @getDOMNode().querySelector('a')
        anchor.focus()

  setHover: (bool) ->
    @setState hovered: bool
    @props.onHover?(@props.name, @props.value)

  onSelect: (e) ->
    e.preventDefault()
    e.stopPropagation()
    toggleValue = not @state.selected
    @selected(toggleValue)
    if toggleValue
      @props.onSelect?(@props.name, @props.value)
    else
      @props.onDeselect?(@props.name, @props.value)

  _classes: ->
    classSet
      hover:         @hasFocus()
      item:          true
      selected:      @props.selected

  _onMouseOut: (e) ->
    @setHover(false)
    @props.onMouseOut?(e)

  _onMouseOver: (e) ->
    @setHover(true)
    @props.onMouseOver?(e)

  _onFocus: (e) ->
    @setHover(true)
    @props.onFocus?(e)

  _onBlur: (e) ->
    @setHover(false)
    @props.onBlur?(e)

  hasFocus: ->
    @props.isActive or @state.hovered or @props.selected

  _onKeyUp: (e) ->
    if e.key is 'ArrowUp' or e.key is 'ArrowDown'
      @setHover(true)

  _onKeyDown: (e) ->
    if e.key is 'Enter' and @hasFocus()
      @onSelect(e)

  render: ->
    <li className=@_classes() role='presentation'>
      <a role        = 'menuitem'
         className   = 'list-item'
         tabIndex    = @props.tabIndex
         href        = @props.href
         onClick     = @onSelect
         onKeyDown   = @_onKeyDown
         onKeyUp     = @_onKeyUp
         onMouseOver = @_onMouseOver
         onMouseOut  = @_onMouseOut
         onBlur      = @_onBlur
         onFocus     = @_onFocus>

        {@props.name}
      </a>
    </li>


SelectList.SelectItem = SelectItem

module.exports = SelectList
