# @name: Calendar
#
# @description: A little bit more functionality than the Month component:
# provides forward/back month navigation and displays month and year name.
#
# This component maintains state about which month is currently displayed.  If
# it receives a new `month` prop, it will update the state with the received
# month and year and then display that month.
#
# The `month` prop is a Moment object which represents the month that will be
# rendered.
#
# The `value` prop is expected to be a list of Moment dates to show as
# selected.  They don't have to be dates within the currently displaying month.
#
# The `onChange` prop will be called with the Moment representing the month
# we've navigated to using the little sideways Chevrons.
#
# The `onSelect` prop will be called with the Moment object representing the
# date we click in the calendar.
#
# @example: ->
#   React.createClass
#
#     getInitialState: ->
#       month: moment()
#
#     handleDateSelect: (date) ->
#       @setState selectedDate: date
#
#     handleCalendarChange: (date) ->
#       @setState month: date
#
#     render: ->
#       <div>
#         <Calendar value    = {[@state.selectedDate]}
#                   month    = @state.month
#                   onSelect = @handleDateSelect
#                   onChange = @handleCalendarChange />
#         <div>
#           {@_selectedDate()}
#         </div>
#       </div>
#
#     _selectedDate: ->
#       if @state?.selectedDate?
#         <span>Selected date: {@state.selectedDate.toString()}</span>
#

React      = require 'react'
_          = require 'lodash'
{classSet} = require('react/addons').addons
moment     = require 'moment'

Month        = require './month'
{MomentType} = require '../types'


Calendar = React.createClass
  displayName: 'Date:Calendar'

  months: moment.months()

  propTypes:
    month:     MomentType
    onChange:  React.PropTypes.func
    onSelect:  React.PropTypes.func
    value:     React.PropTypes.arrayOf MomentType

  getDefaultProps: ->
    month: moment()

  getInitialState: ->
    @_stateFromMonth(@props.month)

  componentWillReceiveProps: (nextProps) ->
    @setState @_stateFromMonth(nextProps.month)

  handleSelect: (date) ->
    @props.onSelect?(date)

  _previousMonth: ->
    @_navigateMonth(-1)

  _nextMonth: ->
    @_navigateMonth(1)

  _navigateMonth: (position) ->
    month = @state.month.clone().add(position, 'month')
    @_setMonth(month)
    @props.onChange?(month)

  _setMonth: (month) ->
    @setState @_stateFromMonth(month)

  _stateFromMonth: (month) ->
    month: month.clone().startOf('month')

  render: ->
    <span className='calendar'>
      <span className='header'>
        <span className='nav left previous' onClick=@_previousMonth>«</span>
        <span className='month-name'>{@_title()}</span>
        <span className='nav right next' onClick=@_nextMonth>»</span>
      </span>
      <Month value    = @state.month
             onChange = @handleSelect
             selected = @props.value />
    </span>

  _title: ->
    # TODO:  maybe allow customizing this thru a prop?
    "#{@state.month.format('MMMM')} #{@state.month.year()}"


module.exports = Calendar
