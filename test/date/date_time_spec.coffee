require '../test_case'
require '../test_date'

React    = require 'react'
moment   = require 'moment'
sinon    = require 'sinon'
{expect} = require 'chai'

DateTime = require '../../src/date/date_time'


describe 'DateTime', ->

  it 'should render the current month if value and month are omitted', ->
    view = @render <DateTime />

    header       = view.getDOMNode().querySelector('.month-name')
    currentMonth = moment().format('MMMM')
    currentYear  = moment().year()

    expect(header).to.have.innerHTML "#{currentMonth} #{currentYear}"

  it 'should render the month given in the `value` prop if no `month` prop', ->
    date = moment([2012, 11, 11])
    view = @render <DateTime value={[date]} />

    header = view.getDOMNode().querySelector('.month-name')

    expect(header).to.have.innerHTML 'December 2012'

  it 'should render the time of the `value` prop in the TimeInput', ->
    date = moment([2012, 11, 11, 8, 12])
    view = @render <DateTime value={[date]} />

    timeInput = view.getDOMNode().querySelector('.time-input input')

    expect(timeInput).to.have.value '8:12 am'

  it 'should render the date of the `value` prop as selected', ->
    date = moment([2012, 11, 11, 8, 12])
    view = @render <DateTime value={[date]} />

    day = view.getDOMNode().querySelector('.day.selected')
    expect(day).to.have.innerHTML '11'

  context 'when updating date', ->

    it 'should call `onChange` with selected date', ->
      date     = moment([2012, 11, 1])
      onChange = sinon.spy()
      view     = @render <DateTime value={[date]} onChange=onChange />

      day = @getByDay(14, view)
      @simulate.click day

      expect(onChange).to.have.been.called.once

      arg = onChange.lastCall.args[0]
      expect(arg.year()).to.equal   2012
      expect(arg.month()).to.equal  11
      expect(arg.date()).to.equal   14
      expect(arg.hour()).to.equal   0
      expect(arg.minute()).to.equal 0

  context 'when updating time', ->

    it 'should call `onChange` with selected date and time', ->
      date      = moment([2012, 11, 1])
      onChange  = sinon.spy()
      view      = @render <DateTime value={[date]} onChange=onChange />
      timeInput = @findByTag(view, 'input')

      @inputValue view, '1pm'
      @simulate.change timeInput
      @simulate.blur timeInput

      expect(onChange).to.have.been.called.once

      arg = onChange.lastCall.args[0]
      expect(arg.year()).to.equal   2012
      expect(arg.month()).to.equal  11
      expect(arg.date()).to.equal   1
      expect(arg.hour()).to.equal   13
      expect(arg.minute()).to.equal 0

  context 'when updating date and time', ->

    it 'should call `onChange` with selected date and time', ->
      date      = moment([2012, 11, 1])
      onChange  = sinon.spy()
      view      = @render <DateTime value={[date]} onChange=onChange />
      timeInput = @findByTag(view, 'input')

      day = @getByDay(23, view)
      @simulate.click day
      @inputValue view, '2:31pm'
      @simulate.change timeInput
      @simulate.blur timeInput

      expect(onChange).to.have.been.called.twice

      dateArg = onChange.firstCall.args[0]
      timeArg = onChange.lastCall.args[0]

      expect(dateArg.year()).to.equal   2012
      expect(dateArg.month()).to.equal  11
      expect(dateArg.date()).to.equal   23
      expect(dateArg.hour()).to.equal   0
      expect(dateArg.minute()).to.equal 0

      expect(timeArg.year()).to.equal   2012
      expect(timeArg.month()).to.equal  11
      expect(timeArg.date()).to.equal   23
      expect(timeArg.hour()).to.equal   14
      expect(timeArg.minute()).to.equal 31

  context 'when receiving new props', ->

    it 'should set `state.value`', ->
      date   = moment([2012, 11, 1])
      view   = @render <DateTime value={[date]} />
      update = date.clone().add(2, 'days')

      view.setProps value: [update]

      expect(view.state.value[0].date()).to.equal 3

    it 'should render the month from the value prop', ->
      date   = moment([2013, 1, 11])
      view   = @render <DateTime value={[date]} />
      update = moment([2013, 5, 11, 13, 16])

      view.setProps value: [update]

      header = view.getDOMNode().querySelector('.month-name')

      expect(header).to.have.innerHTML 'June 2013'

    it 'should render the time of the `value` prop in the TimeInput', ->
      date   = moment([2013, 0, 1])
      view   = @render <DateTime value={[date]} />
      update = moment([2013, 5, 11, 13, 16])

      view.setProps value: [update]

      timeInput = view.getDOMNode().querySelector('.time-input input')

      expect(timeInput).to.have.value '1:16 pm'
