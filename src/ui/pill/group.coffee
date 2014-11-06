# @name: PillGroup
#
# @description:  A collection of Pill components.  This component manages no
# state, instead a parent component should manage this and update what this
# component receives in the options prop accordingly.
#
# The function given to the `onChange` prop will be called when pills are
# "closed".  It will receive one argument; the value of the options prop, minus
# the matching object for the Pill that was closed.
#
# Values are expected to be unique identifiers.
#
#
# @example: ->
#   React.createClass
#
#     getInitialState: ->
#       items: [
#         {name: 'Mike Schmidt',      value: '3B'}
#         {name: 'Ryne Sandberg',     value: '2B'}
#       ]
#
#     onChange: (selectedList) ->
#       @setState(items: selectedList)
#
#     _items: ->
#       items = (<li>{person.name}</li> for person in @state.items)
#       <ul>
#         {items}
#       </ul>
#
#     render: ->
#       <div className='container'>
#         <div className='row'>
#           <PillGroup options=@state.items onChange=@onChange />
#         </div>
#         <div className='row'>
#           {@_items()}
#         </div>
#       </div>


_          = require 'lodash'
React      = require 'react'
{classSet} = require('react/addons').addons
Types      = require '../../types'

Pill       = require './index'


PillGroup = React.createClass
  displayName: 'PillGroup'

  propTypes:
    onChange:  React.PropTypes.func
    options:   Types.nameValueList.isRequired

  _onCloseItem: (value) ->
    filtered = _(@props.options).filter (e) -> e.value isnt value
    @props.onChange?(filtered.value())

  _items: ->
    for item in @props.options
      <Pill key = item.value
        value   = item.value
        onClose = @_onCloseItem>
        {item.name}
      </Pill>

  _classes: ->
    classSet
      'pill-group': true

  render: ->
    <ul className=@_classes()>
      {@_items()}
    </ul>


module.exports = PillGroup
