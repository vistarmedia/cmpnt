require '../test_case'

React    = require 'react'
{expect} = require 'chai'

Pill      = require '../../src/ui/pill'
PillGroup = require '../../src/ui/pill/group'


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


describe 'Pill.Group', ->

  it 'should render all items in props.options', ->
    items = [
      {node: 'Shawon Dunston', id: 'SS'}
      {node: 'Hawk Dawson',    id: 'RF'}
    ]

    group   = @render(<PillGroup options=items />)
    element = group.getDOMNode()

    expect(@allByType(group, Pill)).to.have.length 2
    expect(element.querySelector('.pill:nth-child(1)').textContent)
      .to.have.string 'Shawon Dunston'
    expect(element.querySelector('.pill:nth-child(2)').textContent)
      .to.have.string 'Hawk Dawson'

  it 'should call onChange with props.options minus what was closed', (done) ->
    items = [
      {node: 'Shawon Dunston', id: 'SS'}
      {node: 'Hawk Dawson',    id: 'RF'}
    ]

    onChange = (list) ->
      expect(list).to.have.length 1
      expect(list[0].node).to.equal  'Hawk Dawson'
      expect(list[0].id).to.equal 'RF'
      done()

    group  = @render(<PillGroup options=items onChange=onChange />)
    pill   = @allByType(group, Pill)[0]
    anchor = @findFirstInTree pill, (c) ->
      c.tagName is 'A'

    expect(anchor).to.exist
    @simulate.click(anchor)

  it 'should render node containing renderable markup', ->
    items = [
      {node: <h3>Fergie Jenkins</h3>, id: 'SP'}
    ]

    group   = @render(<PillGroup options=items />)

    pills = @allByType(group, Pill)
    expect(pills).to.have.length 1

    h3 = @allByTag(pills[0], 'h3')
    expect(h3).to.have.length 1

    expect(h3[0].getDOMNode().textContent).to.equal 'Fergie Jenkins'
