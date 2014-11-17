require '../test_case'

React     = require 'react'
{expect}  = require 'chai'

RangeSelector = require '../../src/ui/range-selector'


options = [
  {id: 0, name: 'Sun'}
  {id: 1, name: 'Mon'}
  {id: 2, name: 'Tue'}
  {id: 3, name: 'Wed'}
  {id: 4, name: 'Thu'}
  {id: 5, name: 'Fri'}
  {id: 6, name: 'Sat'}
]

describe 'Range Selector', ->

    it 'should display the proper options', ->
      view = @render <RangeSelector options=options value=[1,3,4] />
      html = view.getDOMNode().innerHTML
      expect(html).to.contain 'Sun'
      expect(html).to.contain 'Mon'
      expect(html).to.contain 'Tue'
      expect(html).to.contain 'Wed'
      expect(html).to.contain 'Thu'
      expect(html).to.contain 'Fri'
      expect(html).to.contain 'Sat'

    describe 'firing the the onChange event', ->

      it 'should occur when selecting', (done) ->
        changed = -> done()
        view = @render <RangeSelector options=options onChange=changed />
        sections = @allByType view, RangeSelector.Section
        monday = sections[1]
        @simulate.mouseDown monday.getDOMNode()

      it 'should occur when deselecting', (done) ->
        changeCount = 0
        changed = ->
          changeCount++
          if changeCount is 2 then done()

        view = @render <RangeSelector options=options onChange=changed />
        sections = @allByType view, RangeSelector.Section
        monday = sections[1]
        @simulate.mouseDown monday.getDOMNode()
        @simulate.mouseUp monday.getDOMNode()
        @simulate.mouseDown monday.getDOMNode()

      it 'should occur when resetting', (done) ->
        changed = -> done()
        view = @render <RangeSelector options=options onChange=changed />
        sections = @allByType view, RangeSelector.Section
        refresh = view.getDOMNode().querySelector('.range-refresh i')
        @simulate.click refresh

    describe 'when clicking on a section', ->

      beforeEach ->
        @view = @render <RangeSelector options=options />
        @sections = @allByType @view, RangeSelector.Section

      it 'should activate selection on mouse down', ->
        expect(@view.state.active).to.be.false
        @simulate.mouseDown @sections[0].getDOMNode()
        expect(@view.state.active).to.be.true

      it 'should deactivate selection on mouse up', ->
        @simulate.mouseDown @sections[0].getDOMNode()
        expect(@view.state.active).to.be.true
        @simulate.mouseUp @sections[0].getDOMNode()
        expect(@view.state.active).to.be.false

      it 'should select a single section on mouse down', ->
        monday = @sections[1]
        expect(monday.props.selected).to.be.false
        @simulate.mouseDown monday.getDOMNode()
        expect(monday.props.selected).to.be.true

      it 'should deselect a selected section on mouse down', ->
        monday = @sections[1]
        expect(monday.props.selected).to.be.false
        @simulate.mouseDown monday.getDOMNode()
        @simulate.mouseUp monday.getDOMNode()
        expect(monday.props.selected).to.be.true
        @simulate.mouseDown monday.getDOMNode()
        expect(monday.props.selected).to.be.false

      it 'should select a section on mouse over while activated', ->
        monday  = @sections[1]
        tuesday = @sections[2]
        expect(monday.props.selected).to.be.false
        expect(tuesday.props.selected).to.be.false
        @simulate.mouseDown monday.getDOMNode()
        @simulate.mouseOver tuesday.getDOMNode()
        expect(monday.props.selected).to.be.true
        expect(tuesday.props.selected).to.be.true

      it 'should not select a section on mouse over after mouse up', ->
        monday  = @sections[1]
        tuesday = @sections[2]
        expect(monday.props.selected).to.be.false
        expect(tuesday.props.selected).to.be.false
        @simulate.mouseDown monday.getDOMNode()
        @simulate.mouseUp monday.getDOMNode()
        @simulate.mouseOver tuesday.getDOMNode()
        expect(monday.props.selected).to.be.true
        expect(tuesday.props.selected).to.be.false

      it 'should deselect going back while mouse is still down', ->
        monday  = @sections[1]
        tuesday = @sections[2]
        expect(monday.props.selected).to.be.false
        expect(tuesday.props.selected).to.be.false
        @simulate.mouseDown monday.getDOMNode()
        @simulate.mouseOver tuesday.getDOMNode()
        expect(monday.props.selected).to.be.true
        expect(tuesday.props.selected).to.be.true
        @simulate.mouseOver monday.getDOMNode()
        expect(tuesday.props.selected).to.be.false

      it 'should not select sections before the first', ->
        monday  = @sections[1]
        tuesday = @sections[2]
        expect(monday.props.selected).to.be.false
        expect(tuesday.props.selected).to.be.false
        @simulate.mouseDown tuesday.getDOMNode()
        @simulate.mouseOver monday.getDOMNode()
        expect(monday.props.selected).to.be.false
        expect(tuesday.props.selected).to.be.true

      it 'should handle missed events due to mouse speed', ->
        monday    = @sections[1]
        tuesday   = @sections[2]
        wednesday = @sections[3]
        expect(monday.props.selected).to.be.false
        expect(tuesday.props.selected).to.be.false
        expect(wednesday.props.selected).to.be.false
        @simulate.mouseDown monday.getDOMNode()
        @simulate.mouseOver wednesday.getDOMNode()
        expect(monday.props.selected).to.be.true
        expect(tuesday.props.selected).to.be.true
        expect(wednesday.props.selected).to.be.true

    describe 'when it has a selection', ->

      beforeEach ->
        @view = @render <RangeSelector options=options value=[1,3,4] />
        @sections = @allByType @view, RangeSelector.Section

      it 'should set initial selection from props', ->
        expect(@sections[0].props.selected).to.be.false
        expect(@sections[1].props.selected).to.be.true
        expect(@sections[2].props.selected).to.be.false
        expect(@sections[3].props.selected).to.be.true
        expect(@sections[4].props.selected).to.be.true
        expect(@sections[5].props.selected).to.be.false
        expect(@sections[6].props.selected).to.be.false

      it 'should reset the selection when reset is clicked', ->
        refresh = @view.getDOMNode().querySelector('.range-refresh i')
        @simulate.click refresh
        @sections.map (s) -> expect(s.props.selected).to.be.false

      it 'should not toggle on mouse over after deselect', ->
        monday  = @sections[1]
        tuesday = @sections[2]
        expect(monday.props.selected).to.be.true
        expect(tuesday.props.selected).to.be.false
        @simulate.mouseDown monday.getDOMNode()
        @simulate.mouseOver tuesday.getDOMNode()
        @simulate.mouseUp tuesday.getDOMNode()
        expect(monday.props.selected).to.be.false
        expect(tuesday.props.selected).to.be.false

      it 'should reset selected values when new props are passed', ->
        expect(@view.state.selected).to.have.length 3
        expect(@view.state.selected).to.have.members [1,3,4]
        @view.setProps value: [2,5]
        expect(@view.state.selected).to.have.length 2
        expect(@view.state.selected).to.have.members [2,5]

    it 'should handle a bogus value', ->
      view = @render <RangeSelector options=options value=[0,99,4] />
      monday = @allByType(view, RangeSelector.Section)[1]
      @simulate.mouseDown monday.getDOMNode()
      expect(view.state.selected).to.have.length 3
      expect(view.state.selected).to.have.members [0, 1, 4]
