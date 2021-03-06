require '../test_case'

React     = require 'react'
_         = require 'lodash'
sinon     = require 'sinon'
{expect}  = require 'chai'

SourceSink         = require '../../src/views/source_sink'
OptionList         = SourceSink.OptionList
FilteredOptionList = SourceSink.FilteredOptionList


describe 'Source Sink View', ->
  beforeEach ->
    @options = for i in [1..5]
      name: "Option #{i}"
      id: "#{i}"

    @comparator = (a, b) ->
      if a.id < b.id then -1
      else if a.id > b.id then 1
      else 0

    @format = (m) -> m.name

  describe 'Option List', ->
    beforeEach ->
      @onSelect = sinon.spy()
      @list = @render <OptionList
        options=@options
        onSelect=@onSelect
        format=@format
        selected=[]
        comparator=@comparator />

    it 'should trigger change event', ->
      opt = @list.getDOMNode().querySelectorAll('option')[0]
      opt.selected = true
      @simulate.change @list.getDOMNode()
      expect(@onSelect).to.have.been.calledWith([id: '1', name: 'Option 1'])

  describe 'Filtered Option List', ->
    it 'should only include filtered values', ->
      list = @render <FilteredOptionList
        options=@options
        format=@format
        selected=[]
        onSelect={->} />
      list.getDOMNode().querySelector('input[type="text"]').value = '2'
      @simulate.change(list.getDOMNode().querySelector('input[type="text"]'))

      options = list.getDOMNode().querySelectorAll('option')

      expect(options.length).to.equal 1
      expect(options[0].getAttribute('value')).to.equal '2'

  describe 'Source Sink View', ->
    beforeEach ->
      @format = (m) -> m.name
      @onChange = sinon.spy()

      @sourceSink = @render <SourceSink options=@options
        name='Test Source Sink' format=@format onChange=@onChange />

    it 'should add to selected state on click', ->
      selected = [@options[4].id]

      sourceSink = @render <SourceSink options=@options value=selected
        format=@format />
      el = sourceSink.getDOMNode()
      expect(el.querySelectorAll('.source-container option')).
        to.have.length 4
      expect(el.querySelectorAll('.sink-container option')).
        to.have.length 1

      sourceEl = el.querySelector('.source-container')
      sourceEl.querySelectorAll('option')[1].selected = true
      @simulate.change(sourceEl.querySelector('select'))

      expect(sourceSink.state.sourceSelected).to.contain
        id: '2'
        name: 'Option 2'

      sinkEl = el.querySelector('.sink-container select')
      sinkEl.querySelectorAll('option')[0].selected = true

      @simulate.change(sinkEl)

      expect(sourceSink.state.sinkSelected).to.contain
        id: '5'
        name: 'Option 5'

    it 'should reset state on re-render', ->
      selected = [@options[4].id]
      sourceSink = @render <SourceSink options=@options value=selected
        format=@format />

      expect(sourceSink.state.sourceOptions).to.have.length 4
      expect(sourceSink.state.sinkOptions).to.have.length 1
      expect(sourceSink.state.sinkOptions).to.contain
        id: '5'
        name: 'Option 5'

      # re-render with equal-but-different option instances
      sourceSink.setProps
        options: @options.map (o) -> _.clone(o)
        value: [@options[2].id]
      expect(sourceSink.state.sourceOptions).to.have.length 4
      expect(sourceSink.state.sinkOptions).to.have.length 1
      expect(sourceSink.state.sinkOptions).to.contain
        id: '3'
        name: 'Option 3'

    it 'should enable and disable buttons depending on selection', ->
      tosink = @sourceSink.getDOMNode().querySelector('.tosink')
      tosource = @sourceSink.getDOMNode().querySelector('.tosource')
      expect(tosink.classList.contains('disabled')).to.equal true
      expect(tosource.classList.contains('disabled')).to.equal true

      @sourceSink.setState
        sourceSelected: [@options[0]]

      expect(tosink.classList.contains('disabled')).to.equal false
      expect(tosource.classList.contains('disabled')).to.equal true

      @sourceSink.setState
        sourceSelected: []
        sourceOptions: [@options[1], @options[2]]
        sinkOptions: [@options[0], @options[3]]
        sinkSelected: [@options[0]]

      expect(tosink.classList.contains('disabled')).to.equal true
      expect(tosource.classList.contains('disabld')).to.equal false

    it 'should move selected values to sink and back', ->
      @sourceSink.setState
        sourceSelected: [@options[0], @options[1]]

      @simulate.click @sourceSink.getDOMNode().querySelector('.tosink')

      expect(@onChange).to.have.been.calledWith [@options[0].id, @options[1].id]

      expect(@sourceSink.state.sourceSelected).to.deep.equal []
      expect(@sourceSink.state.sinkOptions).to.contain @options[0]
      expect(@sourceSink.state.sinkOptions).to.contain @options[1]
      expect(@sourceSink.state.sourceOptions).to.contain @options[2]
      expect(@sourceSink.state.sourceOptions).to.contain @options[3]
      expect(@sourceSink.state.sourceOptions).to.contain @options[4]

      @sourceSink.setState
        sinkSelected: [@options[1]]

      @simulate.click @sourceSink.getDOMNode().querySelector('.tosource')

      expect(@onChange).to.have.been.calledWith [@options[0].id]

      expect(@sourceSink.state.sinkSelected).to.deep.equal []
      expect(@sourceSink.state.sinkOptions).to.have.length 1
      expect(@sourceSink.state.sinkOptions).to.contain @options[0]
      expect(@sourceSink.state.sourceOptions).to.have.length 4
      expect(@sourceSink.state.sourceOptions).to.contain @options[2]
      expect(@sourceSink.state.sourceOptions).to.contain @options[3]
      expect(@sourceSink.state.sourceOptions).to.contain @options[4]
      expect(@sourceSink.state.sourceOptions).to.contain @options[1]

    it 'should reset on clear', ->
      selected = [@options[4]]

      sourceSink = @render <SourceSink options=@options selected=selected
        format=@format onChange=@onChange />
      @simulate.click sourceSink.getDOMNode().querySelector('.clearall')

      expect(@onChange).to.have.been.calledWith []
      expect(sourceSink.state.sourceOptions).to.have.length 5
      expect(sourceSink.state.sinkOptions).to.have.length 0

    it 'should render with non-string ids', ->
      options = for i in [1..5]
        name: "Option #{i}"
        id: i
      selected = [options[4].id]
      sourceSink = @render <SourceSink options=options value=selected
        format=@format />
