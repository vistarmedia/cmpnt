# @name: DateInput
#
# @description: Ye olde "date picker".  An input, whose value is unmodifiable
# directly displays a formatted date time of the date and time selected in the
# calendar and time selector, which is a DateTime component.
#
# The Moment object in the `value` prop is the selected datetime; the value of
# our input element.
#
# When a date is clicked or a time is updated, the `onChange` prop will be
# called with the updated Moment object.
#
# The formate of the date displayed in the input can be customized by giving a
# function to `props.format`.  It will be called with the Moment object.
#
# Maintains state of whether it is open or not.
#
# @example: ->
#   React.createClass
#     getInitialState: ->
#       value: moment()
#
#     handleChange: (date) ->
#       @setState value: date
#
#     render: ->
#       <DateInput value=@state.value onChange=@handleChange />
#

React      = require 'react'
moment     = require 'moment'
{classSet} = require('react/addons').addons

DateTime        = require './date_time'
Icon            = require '../ui/icon'
{MomentType}    = require '../types'
{OnOutsideBlur} = require '../mixins'
OnClickOutside  = require 'react-onclickoutside'


DateInput = React.createClass
  displayName: 'DateInput'

  mixins: [OnOutsideBlur, OnClickOutside]

  propTypes:
    format:   React.PropTypes.func
    onChange: React.PropTypes.func
    value:    MomentType

  getInitialState: ->
    opened: false

  getDefaultProps: ->
    value:   moment()
    format:  (date) ->
      date.format('MM/DD/YYYY h:mm a')

  handleChange: (date) ->
    @props.onChange?(date)

  handleClickOutside: (e) ->
    @setState opened: false

  render: ->
    # the empty function given to the input's onChange is because we want an
    # enabled input (not a readOnly guy) where the user can't change the value
    # of the input
    value = [@props.value]

    <div className='date-input' onBlur=@handleOutsideBlur>
      <div className='input-group date-input'>
        <input className    = 'form-control for-date'
               onChange     = {->}
               onFocus      = @_handleFocus
               type         = 'text'
               value        = @props.format(@props.value) />
        <span className='input-group-addon'>
          <Icon name='calendar' />
        </span>
      </div>
      <div className=@_calendarClassName()>
        <div className='arrow'></div>
        <div className='popover-content'>
          <DateTime value=value onChange=@handleChange />
        </div>
      </div>
    </div>

  _calendarClassName: ->
    classSet
      popover:  true
      bottom:   true
      in:       true
      open:     @state.opened

  _onOutsideBlur: (e) ->
    # handle tabbing to anthor input
    if e.relatedTarget?
      @setState opened: false

  _handleFocus: (e) ->
    @setState opened: true


module.exports = DateInput
