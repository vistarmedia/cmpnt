require '../test_case'

React    = require 'react'
{expect} = require 'chai'
sinon    = require 'sinon'

Editable = require '../../src/form/editable'


describe 'Editable', ->
  it 'should not show icon by default', ->
    view = @render <Editable>Hello world!</Editable>
    el = view.getDOMNode()
    expect(view.state.hovering).to.equal false
    expect(el.querySelectorAll('i')).to.have.length 0

  it 'should show edit icon on mouse over', ->
    view = @render <Editable>Hello world!</Editable>
    el   = view.getDOMNode()
    @simulate.mouseOver el
    expect(view.state.hovering).to.equal true
    expect(el.querySelectorAll('i')).to.have.length 1

  it 'should continue to edit on mouse over child', ->
    view = @render <Editable><div>Hello world!</div></Editable>
    el   = view.getDOMNode()
    @simulate.mouseOver el
    expect(view.state.hovering).to.equal true

    @simulate.mouseOut el, relatedTarget: el.querySelector('div')

    expect(view.state.hovering).to.equal true
    expect(el.querySelectorAll('i')).to.have.length 1

  it 'should remove icon on mouse out', ->
    view = @render <Editable>Hello world!</Editable>
    el = view.getDOMNode()
    view.setState hovering: true
    @simulate.mouseOut el

    expect(view.state.hovering).to.equal false
    expect(el.querySelectorAll('i')).to.have.length 0

  it 'should not trigger click before hovering', ->
    onClick = sinon.spy()
    view = @render <Editable onClick=onClick>Hello world!</Editable>

    @simulate.click view.getDOMNode()

    expect(onClick).to.not.have.been.called

  it 'should trigger click event', ->
    onClick = sinon.spy()
    view = @render <Editable onClick=onClick>Hello world!</Editable>
    view.setState hovering: true

    @simulate.click view.getDOMNode()

    expect(onClick).to.have.been.called
