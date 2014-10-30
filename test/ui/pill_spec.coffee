require '../test_case'

{expect} = require 'chai'

Pill = require '../../src/ui/pill'


describe 'Pill', ->

  it 'should have the pill class', ->
    pill = @render(<Pill>Hi!</Pill>)

    expect(pill.getDOMNode()).to.haveClass 'pill'

  it 'should have the label classes', ->
    pill = @render(<Pill>Hi!</Pill>)

    expect(pill.getDOMNode()).to.haveClass 'label'
    expect(pill.getDOMNode()).to.haveClass 'label-default'

  it 'should have a close icon if given a onClose function', ->
    f = ->
    pill = @render(<Pill onClose=f>Hi!</Pill>)

    expect(pill).to.haveElement '.close'

  it 'should not have a close icon if no onClose function', ->
    pill = @render(<Pill>Hi!</Pill>)

    expect(pill).not.to.haveElement '.close'

  it 'should render children', ->
    pill = @render(<Pill>children, nbd</Pill>)

    expect(pill.getDOMNode()).to.have.textContent 'children, nbd'

  it 'should initially hide if visible prop is false', ->
    pill = @render(<Pill visible=false>Hi!</Pill>)

    expect(pill.getDOMNode()).to.haveClass 'hidden'

  it 'should remove "hidden" class if visible is set to true', ->
    pill = @render(<Pill visible=false>Hi!</Pill>)
    pill.setState(visible: true)

    expect(pill.getDOMNode()).not.to.haveClass 'hidden'

  describe 'with an onClose function', ->

    it 'should call onClose with value', (done) ->
      onclose = (value) ->
        expect(value).to.equal 'goose'
        done()

      pill = @render(<Pill value='goose' onClose={onclose}>Hi!</Pill>)

      anchor = pill.getDOMNode().querySelector('a.close')
      @simulate.click(anchor)

    it 'should add hidden class', ->
      onclose = (value) ->

      pill = @render(<Pill value='goose' onClose={onclose}>Hi!</Pill>)

      anchor = pill.getDOMNode().querySelector('a.close')
      @simulate.click(anchor)

      expect(pill.getDOMNode()).to.haveClass 'hidden'
