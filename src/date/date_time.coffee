# @name: DateTime
#
# @description: Displays the date and time of the Moment given in a nice little
# date'n'time widget.
#
# The `value` prop is a list of the Moment objects that are currently selected.
# Can be omitted.
#
# The `month` prop is the month that should be rendered.  If not given it will
# default to the month.
#
# @example: ->
#   React.createClass
#
#     getInitialState: ->
#       selected: [moment()]
#
#     onChange: (date) ->
#       @setState selected: [date]
#
#     render: ->
#       <div>
#         <DateTime value=@state.selected onChange=@onChange />
#         <p>
#           <p><strong>KYW News Time:</strong></p>
#           {@state.selected[0].toString()}
#         </p>
#       </div>
#

React      = require 'react'
moment     = require 'moment'
{classSet} = require('react/addons').addons

Calendar     = require './calendar'
TimeInput    = require './time'
{MomentType} = require '../types'


DateTime = React.createClass
  displayName: 'Date:DateInput'

  propTypes:
    month:     MomentType
    onChange:  React.PropTypes.func
    value:     React.PropTypes.arrayOf MomentType

  getDefaultProps: ->
    value: [moment()]
    month: moment()

  getInitialState: ->
    value: @props.value

  componentWillReceiveProps: (nextProps) ->
    @setState value: nextProps.value

  handleChange: (date) ->
    @props.onChange?(date)

  handleDateChange: (date) ->
    @setState @_stateFromDate(date)
    @props.onChange?(date)

  handleTimeChange: (date) ->
    current = @state.value[0]
    withTime = current.clone()
      .set('hour', date.hour())
      .set('minute', date.minute())
      .set('second', date.second())
    @setState @_stateFromDate(date)
    @props.onChange?(withTime)

  render: ->
    <div className='date-time'>
      <Calendar value    = @props.value
                month    = @_monthValue()
                onSelect = @handleDateChange />
      <TimeInput value    = @_timeInputValue()
                 onChange = @handleTimeChange />
    </div>

  _timeInputValue: -> @state.value[0]

  _monthValue: ->
    @state.value[0] or @props.month

  _stateFromDate: (date) ->
    # doing all this array business with the idea of adding the ability to have
    # multiple date selections in this guy later
    value: [date]


module.exports = DateTime
