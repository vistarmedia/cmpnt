require '../test_case'

React    = require 'react'
moment   = require 'moment'
sinon    = require 'sinon'
{expect} = require 'chai'

DateInput = require '../../src/date/input'


describe 'DateInput', ->

  it 'should not allow changing input manually', ->
    date = moment([2012, 5, 22])
    view = @render <DateInput value=date />

    input = view.getDOMNode().querySelector('.date-input input')
    input.value = 'horses'
    @simulate.change input

    expect(input.value).to.equal '06/22/2012 12:00 am'

  it 'should open the DateTime component on input focus', ->

  it 'should display the formatted input in the input element', ->
    date = moment([2012, 5, 22])
    view = @render <DateInput value=date />

    input = view.getDOMNode().querySelector('.date-input input')

  it 'should allow customize input value using props.format func', ->
    format = (moment) ->
      moment.format('YYYY-MM-DD HH:mm:ss')
    date = moment([2012, 5, 22])
    view = @render <DateInput value=date format=format />

    input = view.getDOMNode().querySelector('.date-input input')
    expect(input.value).to.equal '2012-06-22 00:00:00'

  describe 'when input is focused', ->

    it 'should open Calendar', ->
      date = moment([2012, 5, 22])
      view = @render <DateInput value=date />

      expect(view.state.opened).to.be.false
      input = view.getDOMNode().querySelector('.date-input input')
      @simulate.focus input
      expect(view.state.opened).to.be.true

    context 'when Calendar is opened', ->

      beforeEach ->
        date = moment([2012, 5, 22])
        @view = @render <DateInput value=date />
        input = @view.getDOMNode().querySelector('.date-input input')
        @simulate.focus input

      it 'should set `state.opened` to true', ->
        expect(@view.state.opened).to.be.true

      it 'should close Calendar onBlur', ->
        element = document.createElement('input')
        input = @view.getDOMNode().querySelector('.date-input input')
        @simulate.blur input, relatedTarget: element

        expect(@view.state.opened).to.be.false
        openCalendars = @view.getDOMNode().querySelectorAll('.popover.open')
        expect(openCalendars).to.have.length 0

      it 'should close Calendar when outside element is clicked', ->
        # can't figure out a good way to test this guy right now.  this is what
        # a test would look like
        #element = document.createElement('div')
        #input   = @findByClass @view, 'for-date'
        #@simulate.mouseDown global.document, target: element

        #openCalendars = @view.getDOMNode().querySelectorAll('.popover.open')
        #expect(openCalendars).to.have.length 0

    context 'when a Date and time is selected', ->

      it 'should fire an onChange with the selected Date', ->
        onChange = sinon.spy()
        date = moment([2012, 5, 22])
        view = @render <DateInput value=date onChange=onChange />
        input = view.getDOMNode().querySelector('.date-input input')
        @simulate.focus input

        day = @getByDay 30, view
        @simulate.click day

        expect(onChange).to.have.been.called.once
        dateArg = onChange.lastCall.args[0]

        expect(dateArg.year()).to.equal 2012
        expect(dateArg.month()).to.equal 5
        expect(dateArg.date()).to.equal 30
        expect(dateArg.hour()).to.equal 0
        expect(dateArg.minute()).to.equal 0

      it 'should fire an onChange with the selected datetime', ->
        onChange = sinon.spy()
        date = moment([2012, 5, 22])
        view = @render <DateInput value=date onChange=onChange />
        input     = view.getDOMNode().querySelector('.date-input input')
        timeInput = view.getDOMNode().querySelector('.time-input input')
        @simulate.focus input

        day = @getByDay 30, view
        @simulate.click day
        timeInput.value = '3:55pm'
        @simulate.change timeInput
        @simulate.blur timeInput

        # first time we changed the date, second time we updated the time
        expect(onChange.callCount).to.equal 2
        dateArg = onChange.lastCall.args[0]

        expect(dateArg.year()).to.equal 2012
        expect(dateArg.month()).to.equal 5
        expect(dateArg.date()).to.equal 30
        expect(dateArg.hour()).to.equal 15
        expect(dateArg.minute()).to.equal 55
