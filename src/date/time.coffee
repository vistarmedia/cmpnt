# @name: Time
#
# @description: An input element for describing a time.  `format` and `parse`
# functions can be customized if given as props:
#
# The `value` prop should be a Moment object.  The `onChange` prop will be
# called with two arguments:  result of the calling `@props.parse` function with
# the date time, and the event object (incase you need to preventDefault,
# stopPropagation, etc) when the 'Enter' key is pressed while within the time
# input element or when the time input element is blurred.
#
# `parse` will be called with the Date from the `value` prop and the value of
# the input element.
#
# `format` will be called with only the `value` prop.  This function is used for
# formatting the display of the time in the input element.
#
# @example: ->
#   React.createClass
#
#     getInitialState: ->
#       time: moment()
#
#     handleChange: (datetime) ->
#       @setState time: datetime
#
#     render: ->
#       <div>
#         <TimeInput value=@state.time onChange=@handleChange />
#         <p>
#           <p><strong>KYW News Time:</strong></p>
#           {@state.time.toString()}
#         </p>
#       </div>

React      = require 'react'
moment     = require 'moment'

Icon         = require '../ui/icon'
{MomentType} = require '../types'


TimeInput = React.createClass
  displayName: 'Date:TimeInput'

  propTypes:
    format:    React.PropTypes.func
    parse:     React.PropTypes.func
    value:     MomentType
    onChange:  React.PropTypes.func

  getInitialState: ->
    @_stateFromMoment(@props.value)

  getDefaultProps: ->
    format: (date) ->
      moment(date).format('h:mm a')

    parse: (datetime, timeString) ->
      # take value from the input element and apply the time to our given date
      parseFormat = 'YYYY-MM-DD h:mm a'
      dateString  = moment(datetime).format('YYYY-MM-DD')
      moment("#{dateString} #{timeString}", parseFormat)

  componentWillReceiveProps: (nextProps) ->
    @setState @_stateFromMoment(nextProps.value)

  handleChange: (e) ->
    value  = e.target.value
    parsed = @props.parse(@props.value, value)
    date   = if parsed.isValid() then parsed else @props.value
    @setState
      datetime: date
      input:    value

  handleSubmit: (e) ->
    if e.key is 'Enter'
      @_handleSubmit(e)

  handleBlur: (e) ->
    @_handleSubmit(e)

  render: ->
    <div className='input-group time-input'>
      <input className    = 'form-control'
             type         = 'text'
             onChange     = @handleChange
             onKeyDown    = @handleSubmit
             onBlur       = @handleBlur
             value        = @state.input />
      <span className='input-group-addon'>
        <Icon name='clock-o' />
      </span>
    </div>

  _handleSubmit: (e) ->
    @setState @_stateFromMoment(@state.datetime)
    @props.onChange?(@state.datetime, e)

  _stateFromMoment: (date) ->
    datetime: date
    input:    @props.format(date)


module.exports = TimeInput
