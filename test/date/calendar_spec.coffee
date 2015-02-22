require '../test_case'
require '../test_date'

React     = require 'react'
moment    = require 'moment'
{expect}  = require 'chai'

Calendar  = require '../../src/date/calendar'


describe 'Date.Calendar', ->

  it 'should default to the current month if no `month` prop', ->
    view = @render <Calendar />
    expectedYear  = moment().year()
    expectedMonth = moment().format('MMMM')

    expect(view.getDOMNode().innerHTML).to.have.string expectedYear
    expect(view.getDOMNode().innerHTML).to.have.string expectedMonth

  it 'should render the friendly month using Moment in `month` prop', ->
    month = moment([2014, 11])
    view = @render <Calendar month=month />

    expect(view.getDOMNode().innerHTML).to.have.string 'December'

  it 'should render the friendly year using Moment in `month` prop', ->
    month = moment([2014, 11])
    view = @render <Calendar month=month />

    expect(view.getDOMNode().innerHTML).to.have.string '2014'

  it 'should render the Month', ->
    month = moment([2014, 11])
    view = @render <Calendar month=month />

    expect(@daysByIndex(1, view)).to.deep.equal ['', '7', '14', '21', '28']
    expect(@daysByIndex(2, view)).to.deep.equal ['1', '8', '15', '22', '29']
    expect(@daysByIndex(3, view)).to.deep.equal ['2', '9', '16', '23', '30']
    expect(@daysByIndex(4, view)).to.deep.equal ['3', '10', '17', '24', '31']
    expect(@daysByIndex(5, view)).to.deep.equal ['4', '11', '18', '25']
    expect(@daysByIndex(6, view)).to.deep.equal ['5', '12', '19', '26']
    expect(@daysByIndex(7, view)).to.deep.equal ['6', '13', '20', '27']

  it 'should render `value` prop as having .selected class', ->
    month = moment([2014, 11])
    selected = [
      moment([2014, 11, 15])
    ]
    view = @render <Calendar month=month value=selected />

    selected = view.getDOMNode().querySelectorAll('.day.selected')
    expect(selected).to.have.length 1
    expect(selected[0]).to.have.innerHTML '15'

  context 'when month prop is a Moment that isnt exactly a month', ->

    it 'should set state.month to be the first day of that month', ->
      month = moment([2014, 11, 15])
      view = @render <Calendar month=month />

      expect(view.state.month.year()).to.equal 2014
      expect(view.state.month.month()).to.equal 11
      expect(view.state.month.date()).to.equal 1

  context 'when clicking a date', ->

    it 'should call onSelect with the selected Moment', (done) ->
      month = moment([2014, 11])
      onSelect = (date) ->
        expect(date.year()).to.equal 2014
        expect(date.month()).to.equal 11
        expect(date.date()).to.equal 11
        done()

      view = @render <Calendar month=month onSelect=onSelect />

      @simulate.click @getByDay(11, view)

  context 'when navigating months', ->

    it 'should advance to the next month and render it', ->
      month = moment([2014, 11])
      view = @render <Calendar month=month />

      @simulate.click view.getDOMNode().querySelector('.nav.next')

      expect(view.getDOMNode().querySelector('.header')
        .innerHTML).to.have.string 'January'
      expect(view.getDOMNode().querySelector('.header')
        .innerHTML).to.have.string '2015'

      expect(@daysByIndex(1, view)).to.deep.equal ['', '4', '11', '18', '25']
      expect(@daysByIndex(7, view)).to.deep.equal ['3', '10', '17', '24', '31']

    it 'should retreat to the previous month and render it', ->
      month = moment([2014, 11])
      view = @render <Calendar month=month />
      @simulate.click view.getDOMNode().querySelector('.nav.previous')

      expect(view.getDOMNode().querySelector('.header')
        .innerHTML).to.have.string 'November'
      expect(view.getDOMNode().querySelector('.header')
        .innerHTML).to.have.string '2014'

      expect(@daysByIndex(1, view))
        .to.deep.equal ['', '2', '9', '16', '23', '30']
      expect(@daysByIndex(7, view)).to.deep.equal ['1', '8', '15', '22', '29']

    it 'should call onChange with the newly displayed month, +', (done) ->
      onChange = (date) ->
        expect(date.year()).to.equal 2015
        expect(date.month()).to.equal 0
        expect(date.date()).to.equal 1
        done()
      month = moment([2014, 11])
      view = @render <Calendar month=month onChange=onChange />

      @simulate.click view.getDOMNode().querySelector('.nav.next')

    it 'should call onChange with the newly displayed month, -', (done) ->
      onChange = (date) ->
        expect(date.year()).to.equal 2014
        expect(date.month()).to.equal 10
        expect(date.date()).to.equal 1
        done()
      month = moment([2014, 11])
      view = @render <Calendar month=month onChange=onChange />

      @simulate.click view.getDOMNode().querySelector('.nav.previous')

    it 'should setState on increase', ->
      month = moment([2014, 11])
      view = @render <Calendar month=month />

      @simulate.click view.getDOMNode().querySelector('.nav.next')

      expect(view.state.month.year()).to.equal 2015
      expect(view.state.month.month()).to.equal 0
      expect(view.state.month.date()).to.equal 1

    it 'should setState on decrease', ->
      month = moment([2014, 11])
      view = @render <Calendar month=month />

      @simulate.click view.getDOMNode().querySelector('.nav.previous')

      expect(view.state.month.year()).to.equal 2014
      expect(view.state.month.month()).to.equal 10
      expect(view.state.month.date()).to.equal 1

    it 'should reset state to props if receiving new props', ->
      month = moment([2014, 11])
      view = @render <Calendar month=month />

      @simulate.click view.getDOMNode().querySelector('.nav.previous')

      expect(view.state.month.year()).to.equal 2014
      expect(view.state.month.month()).to.equal 10
      expect(view.state.month.date()).to.equal 1

      month = moment([2016, 5])
      view.setProps month: month

      expect(view.state.month.year()).to.equal 2016
      expect(view.state.month.month()).to.equal 5
      expect(view.state.month.date()).to.equal 1
