# @name: Multiple Select
#
# @description:  Select multiple items from a list.
#
# @example: ->
#   React.createClass
#
#     getInitialState: ->
#       selected: []
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
#                      onChange = @onChange />
#       </div>


React = require 'react'

Types = require '../types'

SelectFilter = require './filter'
PillGroup    = require '../ui/pill/group'


Multiselect = React.createClass
  displayName: 'Multiselect'

  getInitialState: ->
    selected: []

  propTypes:
    options:   Types.idNameList.isRequired
    onChange:  React.PropTypes.func
    filter:    React.PropTypes.func

  getDefaultProps: ->
    filter: SelectFilter.defaultFilter

  focusInput: ->
    input = @refs.filter.refs.input
    input.focus()

  clearInput: ->
    @refs.filter.setState(filterTerm: '')

  onChange: (list) ->
    @setState selected: list, ->
      @focusInput()
      @clearInput()
      @props.onChange?(list)

  render: ->
    <div className='select-multi'>
      <PillGroup options  = @state.selected
                 onChange = @onChange />
      <SelectFilter ref        = 'filter'
                    options    = @props.options
                    selections = @state.selected
                    filter     = @props.filter
                    onChange   = @onChange />
    </div>


module.exports = Multiselect
