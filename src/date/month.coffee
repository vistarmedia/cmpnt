# @name: Month
#
# @description: Display a month as a calendar.
#
# The demo shows a simple example of implementing a month/year selector,
# maintaining the state of the selected year and month in your component and
# rendering the given month and year using props given to the Month component.
#
# It also shows use of the Month `onChange` prop, which will fire with a Moment
# object representing the day that was clicked.
#
# @example: ->
#
#   React.createClass
#
#     getInitialState: ->
#       month:  moment().month()
#       year:   moment().year()
#
#     handleMonth: (e) ->
#       @setState month: e.target.value
#
#     handleYear: (e) ->
#       @setState year: e.target.value
#
#     handleDateSelect: (date) ->
#       @setState selectedDate: "#{date.toString()}"
#
#     render: ->
#       <div>
#         <div>
#           <select onChange     = @handleYear
#                   name         = 'year'
#                   defaultValue = {@state.year}>
#             {@_yearOptions()}
#           </select>
#           <select onChange     = @handleMonth
#                   name         = 'month'
#                   defaultValue = {@state.month}>
#             {@_monthOptions()}
#           </select>
#         </div>
#         <Month value={@_selectedMonth()} onChange=@handleDateSelect />
#         <div>
#           {@_selectedDate()}
#         </div>
#       </div>
#
#     _yearOptions: ->
#       startYear = moment().year()
#       for year in [startYear..(startYear+10)]
#         <option value=year>{year}</option>
#
#     _monthOptions: ->
#       for month, i in moment.months()
#         <option value=i>{month}</option>
#
#     _selectedMonth: ->
#       moment([@state.year, @state.month])
#
#     _selectedDate: ->
#       if @state?.selectedDate?
#         <span>Selected date: {@state.selectedDate}</span>

React      = require 'react'
moment     = require 'moment'
_          = require 'lodash'
{classSet} = require('react/addons').addons

{MomentType} = require '../types'


Day = React.createClass
  displayName: 'Date:Day'

  propTypes:
    value:     MomentType
    onChange:  React.PropTypes.func
    selected:  React.PropTypes.bool

  handleClick: (e) ->
    @props.onChange?(@props.value, e)

  render: ->
    <span tabIndex='0' className=@_className() onClick=@handleClick>
      {@props.value?.date() or ''}
    </span>

  _className: ->
    classSet
      day:       true
      selected:  @props.selected


Week = React.createClass
  displayName: 'Date:Week'

  propTypes:
    value:     React.PropTypes.arrayOf MomentType
    selected:  React.PropTypes.arrayOf MomentType
    onChange:  React.PropTypes.func

  getDefaultProps: ->
    selected:  []

  render: ->
    <span className='week'>
      {@_days()}
    </span>

  isSelected: (day) ->
    selected = _.find @props.selected, (d) ->
      d?.isSame(day) or
        d?.isBetween moment(day).startOf('day'), moment(day).endOf('day')
    selected?

  _days: ->
    for day, index in @props.value
      <Day key      = index
           value    = day
           selected = @isSelected(day)
           onChange = @props.onChange />


Month = React.createClass
  displayName: 'Date:Month'

  propTypes:
    dayNames:  React.PropTypes.arrayOf React.PropTypes.node
    onChange:  React.PropTypes.func
    selected:  React.PropTypes.arrayOf MomentType
    value:     MomentType

  getDefaultProps: ->
    dayNames: (w[0] for w in moment.weekdays())
    value:    moment()

  render: ->
    <span className='month'>
      <span className='day-names'>
        {@_dayNames()}
      </span>
      {@_weeks()}
    </span>

  _month: ->
    days = daysForMonth(@props.value)
    daysToCalendar(days)

  _weeks: ->
    for week, index in @_month()
      <Week key      = index
            value    = week
            onChange = @props.onChange
            selected = @props.selected />

  _dayNames: ->
    for day, index in @props.dayNames
      <span className='day-of-week' key=index>
        {day}
      </span>


daysForMonth = (month) ->
  # month is expected to be a Moment
  current = month.clone().startOf('month')
  last    = month.clone().endOf('month')
  days    = []
  while current <= last
    days.push(current.clone())
    current.add(1, 'day')
  days


daysToCalendar = (days) ->
  # chunk a list of days into lists of weeks, each list indexed by day of week
  # will pad lists starting with a non-Sunday day of week with an appropriate
  # number of undefineds so it lines up on the calendar grid and can be cleanly
  # iterated over
  padding = days[0].day()
  days    = (new Array(padding)).concat(days)
  cal     = []
  while(days.length > 0)
    cal.push(days.splice(0, 7))
  cal


Month.Day      = Day
Month.Week     = Week
Month.days     = daysForMonth
Month.calendar = daysToCalendar

module.exports = Month
