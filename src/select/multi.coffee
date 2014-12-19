# @name: Multiple Select
#
# @description:  Select multiple items from a list.
#
# @example: ->
#   React.createClass
#
#     getInitialState: ->
#       value: ['id-3']
#       selectable: [
#         {node: 'akon',          id: 'id-1'}
#         {node: 'alizzz',        id: 'id-2'}
#         {node: 'aesop rock',    id: 'id-3'}
#         {node: 'adebisi shank', id: 'id-4'}
#         {node: 'apparat',       id: 'id-5'}
#         {node: 'armand hammer', id: 'id-6'}
#         {node: 'baby huey',     id: 'id-7'}
#         {node: 'baths',         id: 'id-8'}
#         {node: 'billy paul',    id: 'id-9'}
#       ]
#
#     onChange: (list) ->
#       @setState(value: list)
#
#     render: ->
#       <div>
#         <div>
#           Selected {@state.value.length} items
#         </div>
#         <Multiselect options  = @state.selectable
#                      value    = @state.value
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
    options:  Types.idNodeList.isRequired
    value:    React.PropTypes.array
    onChange: React.PropTypes.func
    filter:   React.PropTypes.func

  getDefaultProps: ->
    filter: SelectFilter.defaultFilter
    value: []

  getInitialState: ->
    value: @props.value

  focusInput: ->
    input = @refs.filter.refs.input
    input.focus()

  clearInput: ->
    @refs.filter.setState(filterTerm: '')

  onChange: (list) ->
    value = list.map (i) -> i.id
    @setState value: value, ->
      @focusInput()
      @clearInput()
      @props.onChange?(list)

  render: ->
    <div className='select-multi'>
      <PillGroup options  = @_pillGroups()
                 onChange = @onChange />
      <SelectFilter ref        = 'filter'
                    options    = @props.options
                    value      = @_pillGroups()
                    filter     = @props.filter
                    onChange   = @onChange />
    </div>

  _pillGroups: ->
    _(@state.value)
      .map (v) =>
        _(@props.options).find (o) -> o.id is v
      .value()

module.exports = Multiselect
