# @name: Range Selector
#
# @description: Select a range from the provided options.
#
# @example: ->
#   React.createClass
#     render: ->
#       <RangeSelector options={[
#           {value: 0, label: 'Sun'}
#           {value: 1, label: 'Mon'}
#           {value: 2, label: 'Tue'}
#           {value: 3, label: 'Wed'}
#           {value: 4, label: 'Thu'}
#           {value: 5, label: 'Fri'}
#           {value: 6, label: 'Sat'}
#         ]} />
_           = require 'lodash'
React       = require 'react'
{classSet}  = require('react/addons').addons

Button  = require '../form/button'
Icon    = require './icon'


RangeSelector = React.createClass
  displayName: 'RangeSelector'

  propTypes:
    options:  React.PropTypes.array
    value:    React.PropTypes.array
    onChange: React.PropTypes.func

  getDefaultProps: ->
    options:  []
    value:    []
    onChange: ->

  getInitialState: ->
    # We need to map the values to ordinals for easy manipulation
    ords = @props.value.map (v) =>
      _.findIndex(@props.options, (o) -> o.value is v)

    selected: ords
    active:   false
    current:  []
    onMode:   true

  getOrdinal: (el) -> parseInt(el.getAttribute('data-ordinal'))

  applyChange: (attrs) ->
    @setState attrs, =>
      selectedVals = @state.selected.map (ord) => @props.options[ord].value
      @props.onChange selectedVals

  select: (el, toggleOn) ->
    ord = @getOrdinal(el)     # the ordinal of the current selection section
    current = @state.current  # the sections in the current selection

    if current.length is 0 or ord > Math.min.apply(null, current)
      # Select if this is a new selection or is being dragged left to right
      newValue = if toggleOn and ord in @state.selected
        # If toggling is enabled and this is a selected item, deselect it
        @setState active: false
        selected = @state.selected[0..@state.selected.length-1]
        selected.splice(selected.indexOf(ord), 1)
        selected
      else if ord not in @state.selected
        max = if current.length
          # If current has length, grab the max
          Math.max.apply(null, current)
        else
          # Otherwise, assume the max is the previous section
          ord-1

        toAdd = if ord > max+1
          # If any sections were skipped (due to mouse speed) select them
          [max+1..ord]
        else
          # Otherwise, just select the current section
          [ord]

        # If this section is not selected, select it and track it in `current`
        if @state.active
          current.push(i) for i in toAdd
        @state.selected.concat toAdd

      if @state.active and newValue
        # If selection is active and changes have been made, update state
        @applyChange current: current, selected: newValue.map (v) -> parseInt(v)

  deselectAfter: (ord) ->
    # Deselect all sections after the given ordinal
    selected = @state.selected[0..@state.selected.indexOf(ord)]
    current = @state.current[0..@state.current.indexOf(ord)]
    @applyChange current: current, selected: selected.map (v) -> parseInt(v)

  deactivate: ->
    # Stop the selection process
    @setState active: false, current: []

  mouseDown: (e) ->
    # On mouse down, start the selection process and select the current section
    el = e.target
    @setState active: true, =>
      # We always want to toggle on mouse down
      @select(el, true)

  mouseUp: ->
    # On mouse up, stop selection process
    @deactivate()

  mouseOver: (e) ->
    ord = @getOrdinal(e.target)
    if @state.active and ord in @state.current
      # If we are re-treading during a selection, deselect
      @deselectAfter(ord)
    else
      # Otherwise select the next section, but do not deselect current ones
      @select(e.target, false)

  reset: ->
    @applyChange selected: []

  isSelected: (i) ->
    i in @state.selected

  render: ->
    sections = for opt, i in @props.options
      @transferPropsTo(
        <RangeSelector.Section ordinal=i
                               value=opt.value
                               label=opt.label
                               key="section-#{i}"
                               selected=@isSelected(i)
                               mouseOver=@mouseOver
                               mouseUp=@mouseUp
                               mouseDown=@mouseDown />)

    <div className="range-selector">
      <div className="range-sections">
        {sections}
      </div>
      <div className="range-refresh">
        <Button onClick=@reset>
          <Icon name="refresh" />
        </Button>
      </div>
    </div>


RangeSelector.Section = React.createClass
  propTypes:
    ordinal:    React.PropTypes.number.isRequired
    value:      React.PropTypes.any.isRequired
    label:      React.PropTypes.string
    mouseOver:  React.PropTypes.func
    mouseUp:    React.PropTypes.func
    mouseDown:  React.PropTypes.func
    selected:   React.PropTypes.bool
    options:    React.PropTypes.array

  getDefaultProps: ->
    selected: false

  render: ->
    val     = @props.value
    content = if @props.label then @props.label else val

    classes =
      "range-section": true
      selected: @props.selected

    <div className={classSet(classes)}
         data-ordinal=@props.ordinal
         onMouseOver=@props.mouseOver
         onMouseDown=@props.mouseDown
         onMouseUp=@props.mouseUp
         style={width: "calc(100% / #{@props.options.length})"}>
       {content}
    </div>


module.exports = RangeSelector
