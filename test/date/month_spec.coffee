require '../test_case'
require '../test_date'

React     = require 'react'
_         = require 'lodash'
moment    = require 'moment'
sinon     = require 'sinon'
{expect}  = require 'chai'

Month = require '../../src/date/month'
Day   = Month.Day
Week  = Month.Week


describe 'Date:Month', ->

  describe 'Date.Day', ->

    it 'should render the number of the day', ->
      date = moment([2012, 11, 31])
      view = @render <Day value=date />

      expect(view.getDOMNode().innerHTML).to.have.string '31'

    it 'should render nothing if value is undefined', ->
      view = @render <Day value={undefined} />

      expect(view.getDOMNode().parentNode.querySelector('.day').innerHTML)
        .to.be.empty

    it 'should call onChange with its Moment when clicked', ->
      spy = sinon.spy()
      date = moment([2012, 11, 31])
      view = @render <Day value=date onChange=spy />

      @simulate.click view.getDOMNode()
      expect(spy).to.have.been.calledWith date

    it 'should have "selected" class if selected == true', ->
      date = moment([2012, 11, 31])
      view = @render <Day value=date selected=true />

      expect(view.getDOMNode().parentNode.querySelector('.day.selected'))
        .to.exist

  describe 'Date.Week', ->

    it 'should render blank days for null values', ->
      week = [
        undefined
        undefined
        undefined
        undefined
        moment([2015, 0, 1])
        moment([2015, 0, 2])
        moment([2015, 0, 3])
      ]

      view = @render <Week value=week />
      dayElements = view.getDOMNode().querySelectorAll('.day')

      expect(dayElements[0].innerHTML).to.be.empty
      expect(dayElements[1].innerHTML).to.be.empty
      expect(dayElements[2].innerHTML).to.be.empty
      expect(dayElements[3].innerHTML).to.be.empty

    it 'should render correct day number for each day', ->
      week = [
        undefined
        undefined
        undefined
        undefined
        moment([2015, 0, 1])
        moment([2015, 0, 2])
        moment([2015, 0, 3])
      ]

      view = @render <Week value=week />
      dayElements = view.getDOMNode().querySelectorAll('.day')

      expect(dayElements[4].innerHTML).to.have.string '1'
      expect(dayElements[5].innerHTML).to.have.string '2'
      expect(dayElements[6].innerHTML).to.have.string '3'

    it 'should have none selected if selected prop does not exist', ->
      week = [
        undefined
        undefined
        undefined
        undefined
        moment([2015, 0, 1])
        moment([2015, 0, 2])
        moment([2015, 0, 3])
      ]

      view = @render <Week value=week />
      dayElements = view.getDOMNode().querySelectorAll('.day.selected')

      expect(dayElements).to.be.empty

    it 'should select days that match the dates in selected prop list', ->
      week = [
        null
        null
        null
        null
        moment([2015, 0, 1])
        moment([2015, 0, 2])
        moment([2015, 0, 3])
      ]
      selected = [
        moment([2015, 0, 2])
      ]
      onChange = sinon.spy()

      view = @render <Week onChange=onChange value=week selected=selected />
      dayElements = view.getDOMNode().querySelectorAll('.day.selected')

      expect(dayElements).to.have.length 1
      expect(dayElements[0].innerHTML).to.have.string '2'

    it 'should select days that contain datetimes in selected prop list', ->
      week = [
        null
        null
        null
        null
        moment([2015, 0, 1])
        moment([2015, 0, 2])
        moment([2015, 0, 3])
      ]
      selected = [
        moment([2015, 0, 3, 1, 11])
      ]
      onChange = sinon.spy()

      view = @render <Week onChange=onChange value=week selected=selected />
      dayElements = view.getDOMNode().querySelectorAll('.day.selected')

      expect(dayElements).to.have.length 1
      expect(dayElements[0].innerHTML).to.have.string '3'

    it 'should call its onChange prop with whichever Date is clicked', ->
      week = [
        null
        null
        null
        null
        moment([2015, 0, 1])
        moment([2015, 0, 2])
        moment([2015, 0, 3])
      ]
      selected = [
        moment([2015, 0, 2])
      ]
      onChange = sinon.spy()

      view = @render <Week onChange=onChange value=week selected=selected />
      dayElement = view.getDOMNode().querySelector('.day:nth-child(6)')

      @simulate.click dayElement

      expect(onChange).to.have.been.calledWith week[5]

  describe 'Date.Month', ->

    it 'should render all weeks for the month and year', ->
      month = moment([2014, 11])
      view = @render <Month value=month />

      weeks = view.getDOMNode().querySelectorAll('.week')
      expect(weeks).to.have.length 5

    it 'should render days in the correct spots', ->
      month = moment([2014, 11])
      view = @render <Month value=month />

      expect(@daysByIndex(1, view)).to.deep.equal ['', '7', '14', '21', '28']
      expect(@daysByIndex(2, view)).to.deep.equal ['1', '8', '15', '22', '29']
      expect(@daysByIndex(3, view)).to.deep.equal ['2', '9', '16', '23', '30']
      expect(@daysByIndex(4, view)).to.deep.equal ['3', '10', '17', '24', '31']
      expect(@daysByIndex(5, view)).to.deep.equal ['4', '11', '18', '25']
      expect(@daysByIndex(6, view)).to.deep.equal ['5', '12', '19', '26']
      expect(@daysByIndex(7, view)).to.deep.equal ['6', '13', '20', '27']

    it 'should call onChange with Moment of the day that is clicked', (done) ->
      month = moment([2014, 11])

      onChange = (date) ->
        expect(date.year()).to.equal 2014
        expect(date.month()).to.equal 11
        expect(date.date()).to.equal 17
        done()

      view = @render <Month value=month onChange=onChange />

      @simulate.click @getByDay(17, view)

    it 'should render day of week abbreviations at the top', ->
      month = moment([2014, 11])
      view = @render <Month value=month />

      daysOfWeekNames = view.getDOMNode().querySelectorAll('.day-of-week')
      expect(daysOfWeekNames).to.have.length 7

    it 'should use default dayOfWeekNames', ->
      month = moment([2014, 11])
      view = @render <Month value=month />

      daysOfWeekNames = view.getDOMNode().querySelectorAll('.day-of-week')
      expect(daysOfWeekNames[0].innerHTML).to.equal 'S'
      expect(daysOfWeekNames[1].innerHTML).to.equal 'M'
      expect(daysOfWeekNames[2].innerHTML).to.equal 'T'
      expect(daysOfWeekNames[3].innerHTML).to.equal 'W'
      expect(daysOfWeekNames[4].innerHTML).to.equal 'T'
      expect(daysOfWeekNames[5].innerHTML).to.equal 'F'
      expect(daysOfWeekNames[6].innerHTML).to.equal 'S'

    it 'should use props.dayOfWeekNames if given', ->
      month = moment([2014, 11])
      dayOfWeekNames = [
        'Sun'
        'Mon'
        'Tue'
        'Wed'
        'Th'
        'Fri'
        'Sat'
      ]
      view = @render <Month value=month dayNames=dayOfWeekNames />

      daysOfWeekNames = view.getDOMNode().querySelector('.day-names').innerHTML
      expect(daysOfWeekNames).to.have.string 'Sun'
      expect(daysOfWeekNames).to.have.string 'Mon'
      expect(daysOfWeekNames).to.have.string 'Tue'
      expect(daysOfWeekNames).to.have.string 'Wed'
      expect(daysOfWeekNames).to.have.string 'Th'
      expect(daysOfWeekNames).to.have.string 'Fri'
      expect(daysOfWeekNames).to.have.string 'Sat'

    it 'should have selected dates as selected', ->
      month = moment([2014, 11])
      selected = [
        moment([2014, 11, 15])
        moment([2014, 11, 20])
      ]

      view = @render <Month value=month selected=selected />

      expect(@getByDay(1, view)).not.to.haveClass 'selected'
      expect(@getByDay(15, view)).to.haveClass 'selected'
      expect(@getByDay(20, view)).to.haveClass 'selected'

  describe 'Month.days', ->

    it 'should return a list of Moment objects for given month', ->
      month = moment([2012, 11])
      days = Month.days(month)

      expect(_.first(days).date()).to.equal 1
      expect(_.last(days).date()).to.equal 31
      expect(_.first(days).month()).to.equal 11
      expect(_.last(days).month()).to.equal 11
      expect(_.first(days).year()).to.equal 2012
      expect(_.last(days).year()).to.equal 2012

  describe 'Month.calendar', ->

    it 'should chunk days into lists of weeks', ->
      month = moment([2012, 11])
      days = Month.days(month)

      weeks = Month.calendar(days)

      expect(weeks[0][0]).to.be.undefined
      expect(weeks[0][5]).to.be.undefined
      # first day of Dec. 2012 is a Saturday
      expect(weeks[0][6]).not.to.be.undefined
      expect(weeks[0][6].day()).to.equal 6
      # Dec. 1st
      expect(weeks[0][6].date()).to.equal 1

      # Dec. 19th, 4th day of the fourth week
      expect(weeks[3][3].date()).to.equal 19

      # last week of Dec. 2012
      expect(weeks[5][0]).not.to.be.undefined
      expect(weeks[5][0].day()).to.equal 0
      expect(weeks[5][0].date()).to.equal 30
      expect(weeks[5][1].date()).to.equal 31

    it 'should handle 1st on Sunday', ->
      # March 2015
      days = Month.days(moment([2015, 2]))

      weeks = Month.calendar(days)

      expect(weeks[0][0]).not.to.be.undefined
      expect(weeks[0][0].day()).to.equal 0

    it 'should handle 1st on Monday', ->
      # June 2015
      days = Month.days(moment([2015, 5]))

      weeks = Month.calendar(days)

      expect(weeks[0][0]).to.be.undefined
      expect(weeks[0][1]).not.to.be.undefined
      expect(weeks[0][1].date()).to.equal 1
