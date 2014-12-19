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
# The 'value' prop can be used to allow a parent component to set selections.
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
# It expects an array of things to render in the "options" prop.  It requires
# objects with a key "node" (for the display content, which can be a string,
# number, or any renderable component) and "id" (for an identifier).
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
#         {node: 'custom made',        id: 'ani-1'}
#         {node: 'custom paid',        id: 'ani-2'}
#         {node: 'just custom fitted', id: 'ani-3'}
#       ]
#
#     toggleSelect: (e) ->
#       e.preventDefault()
#       @setState(showSelect: not @state.showSelect)
#
#     onChange: (selectedItems) ->
#       @setState
#         items: selectedItems
#
#     render: ->
#       <div className='container'>
#         <div className='row'>
#           <div className='dropdown col-xs-2'>
#             <a href='#' onClick=@toggleSelect>
#               {@_showOrHideText()} Luda's questions.  Are you?:
#             </a>
#             <SelectList options = @props.items
#               value             = @state.items
#               visible           = @state.showSelect
#               onChange          = @onChange
#               />
#           </div>
#           <ul className='list-group col-xs-2'>
#             {@_selectedItems()}
#           </ul>
#         </div>
#       </div>
#
#     _showOrHideText: ->
#       if @state.showSelect
#         'Hide'
#       else
#         'Show'
#
#     _selectedItems: ->
#       for item in @state.items
#         <li key=item.id className='list-group-item'>{item.node}</li>


_          = require 'lodash'
React      = require 'react'
{classSet} = require('react/addons').addons

Types      = require '../types'


SelectList = React.createClass
  displayName: 'SelectList'

  propTypes:
    options:      Types.idNodeList.isRequired
    value:        Types.idNodeList
    onChange:     React.PropTypes.func
    visible:      React.PropTypes.bool
    shouldFocus:  React.PropTypes.bool
    onKeyDown:    React.PropTypes.func
    onKeyUp:      React.PropTypes.func
    onBlur:       React.PropTypes.func

  getDefaultProps: ->
    visible:      false
    shouldFocus:  false
    value:        []

  getInitialState: ->
    selected:  []
    focused:   null

  onKeyDown: (e) ->
    if @props.visible and e.key in @_keys
      e.stopPropagation()
      e.preventDefault()
      if e.key == 'ArrowUp'
        @_selectPrev(@state.focused)
      if e.key == 'ArrowDown'
        @_selectNext(@state.focused)
      @props.onKeyDown?(e, @state.focused)

  onKeyUp: (e) ->
    if @props.visible
      e.stopPropagation()
      e.preventDefault()

  onBlur: (e) ->
    if not e.relatedTarget?.className.match(/list-item/)
      @props.onBlur?(e)

  onSelect: (node, id) ->
    selections = _(_.clone(@props.value))
      .push(node: node, id: id).value()
    @setState
      selected: selections
      focused: id, ->
        @props.onChange?(selections)

  onDeselect: (node, id) ->
    selections = (_(@props.value).filter((e) ->
      e.id != id)).value()
    @setState
      selected: selections
    @props.onChange?(selections)

  componentWillReceiveProps: (nextProps) ->
    @setState
      selected: nextProps.value

    if @_shouldSetDefaultFocusedState(nextProps)
      @setState(focused: @_firstNotSelectedItem(nextProps))
    else
      @setState(focused: null)

  componentDidUpdate: ->
    if @props.shouldFocus
      @_focusItem()

  select: (element) ->
    @setState focused: element.id

  render: ->
    <ul className = @_classes()
        onKeyDown = @onKeyDown
        onKeyUp   = @onKeyUp
        onBlur    = @onBlur>
      {@_items()}
    </ul>

  _items: ->
    for item in @props.options
      <SelectItem key        = item.id
                  node       = item.node
                  ref        = item.id
                  id         = item.id
                  selected   = @_isItemSelected(item)
                  isActive   = {item.id is @state.focused}
                  onSelect   = @onSelect
                  onDeselect = @onDeselect
                  onHover    = @_setFocusedItem
                  />

  _keys: [
    'ArrowDown'
    'ArrowUp'
  ]

  _itemForId: (id) ->
    @refs[id]

  _focusItem: ->
    component = @_itemForId(@state.focused)
    component?.setFocus(true)

  _selectedNotInList: (list) ->
    @state.focused not in _(list).pluck('id')

  _shouldSetDefaultFocusedState: (props) ->
    props.shouldFocus and @_selectedNotInList(props.options)

  _firstNotSelectedItem: (props) ->
    selectedIds = _(props.value).pluck('id').value()
    item = _.find props.options, (e) => e.id not in selectedIds
    item?.id or props.value[0]?.id

  _indexForId: (id) ->
    _.findIndex @props.options, (e) ->
      e.id is id

  _selectNext: (id) ->
    index = @_indexForId(id)
    if (index + 1) < @props.options.length
      @select(@props.options[index + 1])

  _selectPrev: (id) ->
    index = @_indexForId(id)
    if index isnt 0
      @select(@props.options[index - 1])

  _setFocusedItem: (node, id) ->
    @select(node: node, id: id)

  _isItemSelected: (item) ->
    (_(@state.selected).find id: item.id)?

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
    # With react 0.12, renderable will be renamed to "node"
    node:       React.PropTypes.renderable.isRequired
    id:         React.PropTypes.string.isRequired
    href:       React.PropTypes.string
    tabIndex:   React.PropTypes.string
    selected:   React.PropTypes.bool
    hovered:    React.PropTypes.bool
    isActive:   React.PropTypes.bool
    onSelect:   React.PropTypes.func
    onDeselect: React.PropTypes.func
    onFocus:    React.PropTypes.func

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
    @props.onHover?(@props.node, @props.id)

  onSelect: (e) ->
    e.preventDefault()
    e.stopPropagation()
    toggleValue = not @state.selected
    @selected(toggleValue)
    if toggleValue
      @props.onSelect?(@props.node, @props.id)
    else
      @props.onDeselect?(@props.node, @props.id)

  hasFocus: ->
    @props.isActive or @state.hovered or @props.selected

  render: ->
    <li key=@props.id className=@_classes() role='presentation'>
      <a role        = 'menuitem'
         className   = 'list-item'
         tabIndex    = @props.tabIndex
         href        = @props.href
         onClick     = @onSelect
         onKeyDown   = @_onKeyDown
         onMouseOver = @_onMouseOver
         onMouseOut  = @_onMouseOut
         onBlur      = @_onBlur
         onFocus     = @_onFocus>

        {@props.node}
      </a>
    </li>

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

  _onKeyDown: (e) ->
    if e.key is 'Enter' and @hasFocus()
      @onSelect(e)


SelectList.SelectItem = SelectItem

module.exports = SelectList
