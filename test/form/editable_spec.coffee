require '../test_case'

_        = require 'lodash'
React    = require 'react'
{expect} = require 'chai'
sinon    = require 'sinon'

Editable = require '../../src/form/editable'


describe 'Editable.Element', ->

  it 'should not show icon by default', ->
    view = @render <Editable.Element>Hello world!</Editable.Element>
    el = view.getDOMNode()
    expect(view.state.hovering).to.equal false
    expect(el.querySelectorAll('i')).to.have.length 0

  it 'should show edit icon on mouse over', ->
    view = @render <Editable.Element>Hello world!</Editable.Element>
    el   = view.getDOMNode()
    @simulate.mouseOver el
    expect(view.state.hovering).to.equal true
    expect(el.querySelectorAll('i')).to.have.length 1

  it 'should continue to edit on mouse over child', ->
    view = @render <Editable.Element><div>Hello world!</div></Editable.Element>
    el   = view.getDOMNode()
    @simulate.mouseOver el
    expect(view.state.hovering).to.equal true

    @simulate.mouseOut el, relatedTarget: el.querySelector('div')

    expect(view.state.hovering).to.equal true
    expect(el.querySelectorAll('i')).to.have.length 1

  it 'should remove icon on mouse out', ->
    view = @render <Editable.Element>Hello world!</Editable.Element>
    el = view.getDOMNode()
    view.setState hovering: true
    @simulate.mouseOut el

    expect(view.state.hovering).to.equal false
    expect(el.querySelectorAll('i')).to.have.length 0

  it 'should not remove icon on mouse out if props.active', ->
    view = @render <Editable.Element>Hello world!</Editable.Element>
    el = view.getDOMNode()
    view.setState hovering: true
    view.setProps active:   true
    @simulate.mouseOut el

    expect(el.querySelectorAll('i')).to.have.length 1

  it 'should not trigger focus before hovering', ->
    onFocus = sinon.spy()
    view = @render <Editable.Element onFocus=onFocus>
      Hello world!
    </Editable.Element>

    @simulate.focus view.getDOMNode()

    expect(onFocus).to.not.have.been.called

  it 'should trigger onClick event', ->
    onClick = sinon.spy()
    view = @render <Editable.Element onClick=onClick>
      Hello world!
    </Editable.Element>
    view.setState hovering: true

    @simulate.click view.getDOMNode()

    expect(onClick).to.have.been.called


describe 'Editable', ->

  it 'should have "viewing" class initially', ->
    element = @render(<Editable>
      <input defaultValue='Dennehy' />
    </Editable>)

    expect(@findByClass(element, 'viewing')).to.exist

  it 'should have any passed in classes', ->
    element = @render(<Editable className='custom-class' />)

    expect(@findByClass(element, 'custom-class')).to.exist

  it 'should set editing=true when Editable.Element is clicked', ->
    element = @render(<Editable>
      <input defaultValue='Dennehy' />
    </Editable>)

    @simulate.click(@findByClass(element, 'editable-element'))
    expect(element.state.editing).to.be.true

  it 'should have "editing" class when Editable receives focus', ->
    element = @render(<Editable>
      <input defaultValue='Dennehy' />
    </Editable>)

    @simulate.click(@findByClass(element, 'editable-element'))

    expect(@findByClass(element, 'editing')).to.exist

  it 'should set state.lastOpenedAt when transitioning to state.editing', ->
    now   = 1421360442500
    clock = sinon.useFakeTimers(now)

    element = @render(<Editable>
      <input defaultValue='Dennehy' />
    </Editable>)

    @simulate.click(@findByClass(element, 'editable-element'))

    expect(element.state.lastOpenedAt).to.equal now
    clock.restore()

  it 'should not set state.lastOpenedAt when currently editing', ->
    now   = 1421360442500
    clock = sinon.useFakeTimers(now)

    element = @render(<Editable>
      <input defaultValue='Dennehy' />
    </Editable>)

    @simulate.click(@findByClass(element, 'editable-element'))

    expect(element.state.editing).to.be.true
    clock.tick(500)

    @simulate.click(@findByClass(element, 'editable-element'))

    expect(element.state.lastOpenedAt).to.equal now
    clock.restore()

  it 'should have "viewing" class when blurred after editing', ->
    element = @render(<Editable>
      <input defaultValue='Dennehy' />
    </Editable>)

    @simulate.click(@findByClass(element, 'editable-element'))

    expect(element.state.editing).to.be.true
    expect(@findByClass(element, 'editing')).to.exist

    @simulate.blur(@findByTag(element, 'input'))

    expect(element.state.editing).to.be.false
    expect(@findByClass(element, 'viewing')).to.exist

  it 'should activate/deactivate when using a "select" element', ->
    element = @render(<Editable>
      <select defaultValue='Dennehy'>
        <option value='Dennehy'>Dennehy</option>
        <option value='Butkus'>Butkus</option>
        <option value='Berenger'>Berenger</option>
      </select>
    </Editable>)

    @simulate.click(@findByClass(element, 'editable-element'))

    expect(element.state.editing).to.be.true
    expect(@findByClass(element, 'editing')).to.exist

    select = @findByTag element, 'select'
    @simulate.blur(select)

    expect(element.state.editing).to.be.false
    expect(@findByClass(element, 'viewing')).to.exist

  describe '#handleChange', ->

    beforeEach ->
      now   = 1421360000000
      @clock = sinon.useFakeTimers(now)
      @onChange = sinon.spy()
      @element = @render(<Editable onChange=@onChange>
        <input defaultValue='Dennehy' />
      </Editable>)

    afterEach ->
      @clock.restore()

    it 'should only call props.onChange once per 250ms', ->
      input = @findByTag @element, 'input'
      @simulate.keyDown input, key: 'Enter'
      @clock.tick(10)
      @simulate.blur input
      @clock.tick(25)

      expect(@onChange).to.have.been.calledOnce

    it 'should call props.onChange again after 250ms have passed', ->
      input = @findByTag @element, 'input'
      @simulate.keyDown input, key: 'Enter'
      @clock.tick(250)
      @simulate.blur input

      expect(@onChange).to.have.been.calledTwice

  context 'when focused', ->

    context 'wrapping input element', ->

      beforeEach ->
        @onChange = sinon.spy()
        @input = @render(<Editable onChange = @onChange>
          <input defaultValue='Dennehy' />
          <button>Yo Kenny</button>
        </Editable>)
        element = @findByTag @input, 'input'
        @simulate.focus(element)

      it 'should call onChange w/event on "enter" press', ->
        element = @findByTag @input, 'input'
        @inputValue @input, 'Physically a horse.'
        @simulate.keyPress element, key: 'Enter'

        calledWith = @onChange.lastCall.args
        event = calledWith[0]
        expect(event.key).to.equal 'Enter'

      it 'should preventDefault and stopPropagation on enter', ->
        # doing this incase we're using this in a form
        event =
          stopPropagation:  sinon.spy()
          preventDefault:   sinon.spy()
          key:              'Enter'

        element = @findByTag @input, 'input'
        @simulate.keyPress element, event

        expect(event.stopPropagation).to.have.been.called
        expect(event.preventDefault).to.have.been.called

      it 'should no call onChange if not enter key', ->
        element = @findByTag @input, 'input'
        @simulate.keyPress element, key: 'Unidentified'

        expect(@onChange).not.to.have.been.called

      it 'should call onChange on blur if e.relatedTarget is a not child', ->
        element = @findByTag @input, 'input'
        @inputValue @input, 'Physically a horse.'
        @simulate.blur element,
          target: element.getDOMNode()

        expect(@onChange).to.have.been.called

      it 'should call onChange on blur if e.relatedTarget is null', ->
        element = @findByTag @input, 'input'
        @inputValue @input, 'Physically a horse.'
        @simulate.blur element,
          target: element.getDOMNode()
          relatedTarget: null

        expect(@onChange).to.have.been.called

      it '''
      should not call handleChange if currentTarget contains relatedTarget
      ''', ->
        currentTarget = @input.getDOMNode().querySelector('span.input')
        handleChange = sinon.spy(@input, 'handleChange')
        element = @findByTag @input, 'input'
        button  = @findByTag @input, 'button'
        @inputValue @input, 'Physically a horse.'
        @simulate.blur element,
          currentTarget: currentTarget
          relatedTarget: button.getDOMNode()

        expect(handleChange).not.to.have.been.called
        expect(@onChange).not.to.have.been.called
        handleChange.restore()
