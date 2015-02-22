require '../test_case'
require '../test_date'

React     = require 'react'
moment    = require 'moment'
sinon     = require 'sinon'
{expect}  = require 'chai'

TimeInput = require '../../src/date/time'


describe 'Date:TimeInput', ->

  it 'should call onChange with datetime on "enter" keypress', ->
    onChange = sinon.spy()
    date     = moment([2015, 0, 1, 15, 31])
    view     = @render <TimeInput value=date onChange=onChange />

    @inputValue view, '11:55pm'
    @simulate.keyPress @findByTag(view, 'input'), key: 'Enter'

    expect(onChange).to.have.been.called.once

    arg = onChange.lastCall.args[0]
    expect(arg.year()).to.equal 2015
    expect(arg.month()).to.equal 0
    expect(arg.date()).to.equal 1
    expect(arg.hour()).to.equal 15
    expect(arg.minute()).to.equal 31

  it 'should retain inputted value onChange', ->
    onChange = sinon.spy()
    date     = moment([2015, 0, 1, 15, 31])
    view     = @render <TimeInput value=date onChange=onChange />

    @inputValue view, '9pm'
    @simulate.change @findByTag view, 'input'

    expect(view.getDOMNode().querySelector('input')).to.have.value '9pm'

  it 'should update input value with parsed value on "enter" keypress', ->
    onChange = sinon.spy()
    date     = moment([2015, 0, 1, 15, 31])
    view     = @render <TimeInput value=date onChange=onChange />
    input    = view.getDOMNode().querySelector('input')

    @inputValue view, '8pm'
    @simulate.change input
    @simulate.keyPress @findByTag(view, 'input'), key: 'Enter'

    expect(input).to.have.value '8:00 pm'

  it 'should default format the time for the Moment in `value` prop', ->
    date = moment([2015, 0, 1, 15, 31])
    view = @render <TimeInput value=date />

    expect(view.getDOMNode().querySelector('input')).to.have.value '3:31 pm'

  it 'should handle short input', (done) ->
    onChange = (date) ->
      expect(date.year()).to.equal 2015
      expect(date.month()).to.equal 0
      expect(date.date()).to.equal 1
      expect(date.hour()).to.equal 11
      expect(date.minute()).to.equal 0
      done()

    date  = moment([2015, 0, 1, 15, 31])
    view  = @render <TimeInput value=date onChange=onChange />
    input = @findByTag(view, 'input')

    @inputValue view, '11am'
    @simulate.change input
    @simulate.keyPress input, key: 'Enter'

  it 'should handle more exact input', (done) ->
    onChange = (date) ->
      expect(date.year()).to.equal 2015
      expect(date.month()).to.equal 0
      expect(date.date()).to.equal 1
      expect(date.hour()).to.equal 23
      expect(date.minute()).to.equal 55
      done()

    date = moment([2015, 0, 1, 15, 31])
    view  = @render <TimeInput value=date onChange=onChange />
    input = @findByTag(view, 'input')

    @inputValue view, '11:55pm'
    @simulate.change input
    @simulate.keyPress input, key: 'Enter'

  it 'should call `onChange` onBlur', ->
    onChange = sinon.spy()
    date = moment([2015, 0, 1, 15, 31])
    view  = @render <TimeInput value=date onChange=onChange />
    input = @findByTag(view, 'input')

    @inputValue view, '11:55pm'
    @simulate.change input
    @simulate.blur input

    expect(onChange).to.have.been.called.once

    date = onChange.lastCall.args[0]

    expect(date.year()).to.equal 2015
    expect(date.month()).to.equal 0
    expect(date.date()).to.equal 1
    expect(date.hour()).to.equal 23
    expect(date.minute()).to.equal 55

  context 'when receiving new props', ->

    it 'should update `state.datetime', ->
      date   = moment([2015, 0, 1, 15, 31])
      view   = @render <TimeInput value=date />
      update = date.clone().add(2, 'hours')

      view.setProps value: update

      expect(view.state.datetime.hour()).to.equal 17
      expect(view.state.input).to.equal update.format('h:mm a')

    it 'should update `state.input` with parsed value of datetime', ->
      date   = moment([2015, 0, 1, 15, 31])
      view   = @render <TimeInput value=date />
      update = date.clone().add(2, 'hours')

      view.setProps value: update

      expect(view.state.input).to.equal update.format('h:mm a')

    it 'should display the parsed datetime in the input element', ->
      date   = moment([2015, 0, 1, 15, 31])
      view   = @render <TimeInput value=date />
      update = date.clone().add(2, 'hours')
      input = @findByTag(view, 'input')

      view.setProps value: update

      expect(input.getDOMNode()).to.have.value update.format('h:mm a')

  context 'after entering an invalid time and hitting "Enter"', ->

    it 'should fire onChange with original moment', ->
      # this seems a little strange to me but I wasn't sure how else to handle
      # invalid input in a generic-ish way. saying "gross!  get this outta
      # here!" and onChange'ing and reverting the input to the valid original
      # seems alright.  should be enough of a "yo, you fucked up" visual queue
      #
      # messing around with it on the demo site made me think it made sense -
      # with the simple onChange -> setState from result flow it seems to work
      # nicely; if you fat-finger a "42", you'll get 4am
      onChange = sinon.spy()
      date     = moment([2015, 0, 1, 15, 31])
      view     = @render <TimeInput value=date onChange=onChange />
      input    = @findByTag(view, 'input')

      @inputValue view, '42'
      @simulate.change input
      @simulate.keyPress input, key: 'Enter'

      expect(onChange).to.have.been.called.once

      date = onChange.lastCall.args[0]
      expect(date.year()).to.equal 2015
      expect(date.month()).to.equal 0
      expect(date.date()).to.equal 1
      expect(date.hour()).to.equal 15
      expect(date.minute()).to.equal 31

    it 'should revert input value to last valid datetime value', ->
      onChange = sinon.spy()
      date     = moment([2015, 0, 1, 15, 31])
      view     = @render <TimeInput value=date onChange=onChange />
      input    = @findByTag(view, 'input')

      @inputValue view, '42'
      @simulate.change @findByTag(view, 'input')
      @simulate.keyPress @findByTag(view, 'input'), key: 'Enter'

      expect(input.getDOMNode()).to.have.value '3:31 pm'
