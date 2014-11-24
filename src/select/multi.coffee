# @name: Multiple Select
#
# @description:  Select multiple items from a list.
#
# @example: ->
#   React.createClass
#
#     getInitialState: ->
#       selected: ['id-3']
#       selectable: [
#         {name: 'akon',          id: 'id-1'}
#         {name: 'alizzz',        id: 'id-2'}
#         {name: 'aesop rock',    id: 'id-3'}
#         {name: 'adebisi shank', id: 'id-4'}
#         {name: 'apparat',       id: 'id-5'}
#         {name: 'armand hammer', id: 'id-6'}
#         {name: 'baby huey',     id: 'id-7'}
#         {name: 'baths',         id: 'id-8'}
#         {name: 'billy paul',    id: 'id-9'}
#       ]
#
#     onChange: (list) ->
#       @setState(selected: list)
#
#     render: ->
#       <div>
#         <div>
#           Selected {@state.selected.length} items
#         </div>
#         <Multiselect options  = @state.selectable
#                      selected = @state.selected
#                      onChange = @onChange />
#       </div>

_     = require 'lodash'
React = require 'react'

Types = require '../types'

SelectFilter = require './filter'
PillGroup    = require '../ui/pill/group'


Multiselect = React.createClass
  displayName: 'Multiselect'

  propTypes:
    options:  Types.idNameList.isRequired
    selected: React.PropTypes.array
    onChange: React.PropTypes.func
    filter:   React.PropTypes.func

  getDefaultProps: ->
    filter: SelectFilter.defaultFilter
    selected: []

  getInitialState: ->
    selected: @props.selected

  focusInput: ->
    input = @refs.filter.refs.input
    input.focus()

  clearInput: ->
    @refs.filter.setState(filterTerm: '')

  onChange: (list) ->
    selected = list.map (i) -> i.id
    @setState selected: selected, ->
      @focusInput()
      @clearInput()
      @props.onChange?(list)

  render: ->
    <div className='select-multi'>
      <PillGroup options  = @_pillGroups()
                 onChange = @onChange />
      <SelectFilter ref        = 'filter'
                    options    = @props.options
                    selections = @_pillGroups()
                    filter     = @props.filter
                    onChange   = @onChange />
    </div>

  _pillGroups: ->
    _(@state.selected)
      .map (selected) =>
        _(@props.options).find (o) -> o.id is selected
      .value()


module.exports = Multiselect
