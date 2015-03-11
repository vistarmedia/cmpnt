require '../test_case'

React    = require 'react'
{expect} = require 'chai'
sinon    = require 'sinon'

SelectList   = require '../../src/select/list'
SelectFilter = require '../../src/select/filter'
Multiselect  = require '../../src/select/multi'

SelectItem = SelectList.SelectItem
Input      = SelectFilter.Input

Pill       = require '../../src/ui/pill'


describe 'Multiselect', ->

  beforeEach ->
    @onChange = sinon.spy()
    @items = [
      {name: 'akon',          id: 'id-1'}
      {name: 'alizzz',        id: 'id-2'}
      {name: 'aesop rock',    id: 'id-3'}
      {name: 'adebisi shank', id: 'id-4'}
      {name: 'apparat',       id: 'id-5'}
      {name: 'armand hammer', id: 'id-6'}
      {name: 'baby huey',     id: 'id-7'}
      {name: 'baths',         id: 'id-8'}
      {name: 'billy paul',    id: 'id-9'}
    ]

  it 'should have an input', ->
    select = @render(<Multiselect options=@items />)
    input  = @findByTag select, 'input'

    expect(input).to.exist

  it 'should open the list when the input is focused', ->
    select = @render(<Multiselect options=@items />)
    input  = @findByTag select, 'input'

    listComponent = @findByType select, SelectFilter

    expect(listComponent.state.opened).to.be.false

    @simulate.focus(input)

    expect(listComponent.state.opened).to.be.true

  context 'when selecting an item in the list', ->

    it 'should add a pill to the input box', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      listComponent = @findByType select, SelectFilter
      itemComponents = @allByType listComponent, SelectItem
      apparatAnchor = @findByTag itemComponents[4], 'a'
      pills = => @allByType select, Pill

      expect(pills()).to.have.length 0

      @simulate.focus(input)
      @simulate.click(apparatAnchor)

      expect(pills()).to.have.length 1
      expect(pills()[0].getDOMNode().textContent).to.have.string 'apparat'

    it 'should be in state.value', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      listComponent = @findByType select, SelectFilter
      itemComponents = @allByType listComponent, SelectItem
      apparatAnchor = @findByTag itemComponents[4], 'a'

      @simulate.focus(input)
      @simulate.click(apparatAnchor)

      expect(select.state.value).to.have.length 1
      expect(select.state.value[0]).to.equal 'id-5'

    it 'should call onChange with selected item id', ->
      select = @render(<Multiselect options=@items onChange=@onChange />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      listComponent = @findByType select, SelectFilter
      itemComponents = @allByType listComponent, SelectItem
      apparatAnchor = @findByTag itemComponents[4], 'a'

      @simulate.focus(input)
      @simulate.click(apparatAnchor)

      expect(@onChange).to.have.been.calledWith(['id-5'])

    it 'should focus the input after a selection', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = @allByType listComponent, SelectItem
      apparatAnchor  = @findByTag itemComponents[4], 'a'

      expect(inputComponent.state.focused).to.be.false

      @simulate.focus(input)
      @simulate.click(apparatAnchor)

      expect(inputComponent.state.focused).to.be.true

    it 'should preselect items', ->
      select = @render(<Multiselect options=@items value={['id-8', 'id-3']} />)
      expect(select.state.value).to.have.length 2
      expect(select.state.value[0]).to.equal 'id-8'
      expect(select.state.value[1]).to.equal 'id-3'

    it 'should remove the item on backspace'

  context 'when selecting multiple items from the list', ->

    it 'should add them to state.value', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = @allByType listComponent, SelectItem
      apparatAnchor  = @findByTag itemComponents[4], 'a'
      bathsAnchor  = @findByTag itemComponents[7], 'a'

      @simulate.focus(input)
      @simulate.click(apparatAnchor)
      @simulate.click(bathsAnchor)

      expect(select.state.value).to.have.length 2

    it 'should add a pill for each', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = @allByType listComponent, SelectItem
      apparatAnchor  = @findByTag itemComponents[4], 'a'
      bathsAnchor  = @findByTag itemComponents[7], 'a'

      pills = => @allByType select, Pill

      @simulate.focus(input)
      @simulate.click(apparatAnchor)
      @simulate.click(bathsAnchor)

      expect(pills()).to.have.length 2

  context 'when deselecting an item in the list', ->

    it 'should not be selected in the list', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = => @allByType listComponent, SelectItem
      apparatAnchor  = @findByTag itemComponents()[4], 'a'
      bathsAnchor  = @findByTag itemComponents()[7], 'a'

      @simulate.focus(input)
      @simulate.click(apparatAnchor)
      @simulate.click(bathsAnchor)

      # deselect
      @simulate.click(bathsAnchor)

      selectedListElements = @allByClass select, 'selected'

      expect(selectedListElements).to.have.length 1

    it 'should not be in state.value', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = => @allByType listComponent, SelectItem
      apparatAnchor  = @findByTag itemComponents()[4], 'a'
      bathsAnchor  = @findByTag itemComponents()[7], 'a'

      @simulate.focus(input)
      @simulate.click(apparatAnchor)
      @simulate.click(bathsAnchor)

      # deselect
      @simulate.click(bathsAnchor)

      expect(select.state.value).to.have.length 1

    it 'should re-focus the input', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = => @allByType listComponent, SelectItem
      apparatAnchor  = @findByTag itemComponents()[4], 'a'

      @simulate.focus(input)
      @simulate.click(apparatAnchor)

      expect(inputComponent.state.focused).to.be.true

  context 'when deselecting a pill', ->

    it 'should not be value in the list', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = => @allByType listComponent, SelectItem
      apparatAnchor  = @findByTag itemComponents()[4], 'a'

      pills = => @allByType select, Pill

      @simulate.focus(input)
      @simulate.click(apparatAnchor)

      pillAnchor = @findByTag pills()[0], 'a'

      @simulate.click(pillAnchor)

      selectedListElements = @allByClass select, 'selected'
      expect(selectedListElements).to.have.length 0

    it 'should remove the pill', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = => @allByType listComponent, SelectItem
      apparatAnchor  = @findByTag itemComponents()[4], 'a'

      pills = => @allByType select, Pill

      @simulate.focus(input)
      @simulate.click(apparatAnchor)

      pillAnchor = @findByTag pills()[0], 'a'

      @simulate.click(pillAnchor)

      expect(pills()).to.have.length 0

    it 'should not be in state.selected', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = => @allByType listComponent, SelectItem
      apparatAnchor  = @findByTag itemComponents()[4], 'a'

      pills = => @allByType select, Pill

      @simulate.focus(input)
      @simulate.click(apparatAnchor)

      pillAnchor = @findByTag pills()[0], 'a'

      @simulate.click(pillAnchor)

    it 'should re-focus the input', ->
      select = @render(<Multiselect options=@items />)
      input  = @findByTag select, 'input'
      inputComponent = @findByType select, Input

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = => @allByType listComponent, SelectItem
      apparatAnchor  = @findByTag itemComponents()[4], 'a'

      pills = => @allByType select, Pill

      @simulate.focus(input)
      @simulate.click(apparatAnchor)

      pillAnchor = @findByTag pills()[0], 'a'

      @simulate.click(pillAnchor)

      expect(inputComponent.state.focused).to.be.true

  context 'when filtering items', ->

    it 'should clear the input if a selection is made from the list', ->
      select = @render(<Multiselect options=@items />)
      input  = @inputElement(select)

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = => @allByType listComponent, SelectItem

      @inputValue(input, 'appa')
      @simulate.keyUp(input, key: 'Enter')

      apparatAnchor  = @findByTag itemComponents()[0], 'a'

      @simulate.click(apparatAnchor)

      inputElement = @findByTag inputComponent, 'input'

      expect(inputElement.getDOMNode().value).to.equal ''

  context 'when receiving props', ->

    it 'should update state values', ->
      select = @render(<Multiselect options=@items value={['id-7']} />)
      expect(select.state.value).to.deep.equal ['id-7']

      p = select.getDOMNode().parentNode
      @render(<Multiselect options=@items value={['id-3']} />, p)
      expect(select.state.value).to.deep.equal ['id-3']


describe 'SelectFilter', ->

  beforeEach ->
    @items = [
      {content: 'grass',         id: 'id-1'}
      {content: 'grassy',        id: 'id-2'}
      {content: 'sun',           id: 'id-3'}
      {content: 'sky',           id: 'id-4'}
      {content: 'kenny dennis',  id: 'id-5'}
      {content: 'dogs',          id: 'id-6'}
      {content: 'meat',          id: 'id-7'}
      {content: 'meaty',         id: 'id-8'}
      {content: 'horses',        id: 'id-9'}
    ]

  it 'should include class names from className prop', ->
    select = @render(<SelectFilter className='DMX' options=@items />)
    expect(select.getDOMNode()).to.haveClass 'DMX'

  it 'should have btn-group class by default', ->
    select = @render(<SelectFilter options=@items />)
    expect(select.getDOMNode()).to.haveClass 'btn-group'

  it 'should have select-filter class by default', ->
    select = @render(<SelectFilter options=@items />)
    expect(select.getDOMNode()).to.haveClass 'select-filter'

  it 'should open the list when input receives focus', ->
    select = @render(<SelectFilter options=@items />)
    input  = @inputElement(select)

    listComponent = @findByType select, SelectList
    expect(listComponent.props.visible).to.be.false

    @simulate.focus(input)

    expect(listComponent.props.shouldFocus).to.be.false
    expect(listComponent.props.visible).to.be.true

  it 'should close the list on blur if relatedTarget is not a list item', ->
    select = @render(<SelectFilter options=@items />)
    input  = @inputElement(select)

    listComponent = @findByType select, SelectList
    expect(listComponent.props.visible).to.be.false

    @simulate.focus(input)

    expect(listComponent.props.visible).to.be.true

    @simulate.blur(input)

    expect(listComponent.props.visible).to.be.false

  it 'should set opened=false onBlur if e.relatedTarget not a list item', ->
    select = @render(<SelectFilter options=@items />)
    listComponent = @findByType select, SelectList
    ulElement = @findByTag listComponent, 'ul'
    input  = @inputElement(select)
    @simulate.focus(input)

    otherElement = window.document.createElement('div')

    @simulate.blur(ulElement, relatedTarget: otherElement)

    expect(listComponent.props.visible).to.be.false
    expect(listComponent.props.shouldFocus).to.be.false

  it 'should set opened=false onBlur if e.relatedTarget is null', ->
    select = @render(<SelectFilter options=@items />)
    listComponent = @findByType select, SelectList
    ulElement = @findByTag listComponent, 'ul'
    input  = @inputElement(select)
    @simulate.focus(input)

    otherElement = window.document.createElement('div')

    @simulate.blur(ulElement, relatedTarget: null)

    expect(listComponent.props.visible).to.be.false
    expect(listComponent.props.shouldFocus).to.be.false

  it 'should not set open to false if e.relatedTarget is a list item', ->
    select = @render(<SelectFilter options=@items />)
    listComponent = @findByType select, SelectList
    ulElement = @findByTag select, 'ul'
    input  = @inputElement(select)
    @simulate.focus(input)

    listElement = @allByClass(select, 'list-item')[2]

    expect(listElement).to.exist

    @simulate.blur(ulElement, relatedTarget: listElement.getDOMNode())

    expect(listComponent.props.visible).to.be.true

  it 'should not close the list on blur if list has focus', ->
    select = @render(<SelectFilter options=@items />)
    input  = @inputElement(select)

    listComponent = @findByType select, SelectList
    item          = @allByType(listComponent, SelectItem)[5]
    itemElement   = @findByTag item, 'a'

    expect(listComponent.props.visible).to.be.false

    @simulate.focus(input)
    @simulate.keyDown(input, key: 'Enter')

    expect(listComponent.props.visible).to.be.true

    @simulate.blur(input, relatedTarget: itemElement.getDOMNode())

    expect(listComponent.props.visible).to.be.true

  it 'should focus the list when input receives "Enter" key', ->
    select = @render(<SelectFilter options=@items />)
    input  = @inputElement(select)

    listComponent = @findByType select, SelectList
    expect(listComponent.props.shouldFocus).to.be.false

    @simulate.keyDown(input, key: 'Enter')

    expect(select.state.focusList).to.be.true
    expect(listComponent.props.shouldFocus).to.be.true

  it 'should focus the list when input receives "ArrowDown" key', ->
    select = @render(<SelectFilter options=@items />)
    input  = @inputElement(select)

    listComponent = @findByType select, SelectList
    expect(listComponent.props.shouldFocus).to.be.false

    @simulate.keyDown(input, key: 'ArrowDown')

    expect(select.state.focusList).to.be.true
    expect(listComponent.props.shouldFocus).to.be.true

  it 'should close the list after a selection is made', ->
    select = @render(<SelectFilter options=@items />)
    input  = @inputElement(select)

    @simulate.focus(input)

    listComponent = @findByType select, SelectList
    item          = @allByType(listComponent, SelectItem)[5]
    itemElement   = @findByTag item, 'a'

    @simulate.click(itemElement, target: itemElement)

    expect(listComponent.props.shouldFocus).to.be.false
    expect(listComponent.props.visible).to.be.false

  it 'should render list elements', ->
    select = @render(<SelectFilter options=@items />)
    input  = @inputElement(select)

    listComponent = @findByType select, SelectList
    listElements  = @allByTag  listComponent, 'li'
    expect(listElements).to.have.length 9

  it 'should call the props onChange each time a selection is made', ->
    selections = sinon.spy()
    select = @render(<SelectFilter options=@items onChange=selections />)
    input  = @inputElement(select)

    @simulate.focus(input)

    listComponent = @findByType select, SelectList
    item1         = @allByType(listComponent, SelectItem)[5]
    itemElement1  = @findByTag item1, 'a'
    item2         = @allByType(listComponent, SelectItem)[6]
    itemElement2  = @findByTag item2, 'a'

    @simulate.click(itemElement1, target: itemElement1)
    @simulate.click(itemElement2, target: itemElement1)

    expect(selections).to.have.callCount 2

  it 'should call the props onChange with selections', (done) ->
    selections = (selectedItems) ->
      expect(selectedItems).to.have.length 1
      done()

    select = @render(<SelectFilter options=@items onChange=selections />)
    input  = @inputElement(select)

    @simulate.focus(input)

    listComponent = @findByType select, SelectList
    item1          = @allByType(listComponent, SelectItem)[5]
    itemElement1   = @findByTag item1, 'a'

    @simulate.click(itemElement1, target: itemElement1)

  context 'when filtering', ->

    it 'should filter the list values on input keyUp', ->
      select = @render(<SelectFilter options=@items />)
      input  = @inputElement(select)

      listComponent = @findByType select, SelectList
      @inputValue(input, 'grass')
      @simulate.keyUp(input)

      listElements  = @allByTag  listComponent, 'li'
      expect(listElements).to.have.length 2

    it 'should focus if filtered to one item and then focus list', ->
      select = @render(<SelectFilter options=@items />)
      input  = @inputElement(select)

      listComponent = @findByType select, SelectList
      @inputValue(input, 'kenny dennis')
      @simulate.keyUp(input)

      listElements  = @allByTag  listComponent, 'li'
      expect(listElements).to.have.length 1

      @simulate.keyDown(input, key: 'Enter')

    context 'and length of results is 1', ->

      it 'should call onChange with the item and props.value', (done) ->
        values = [{content: 'dogs', value: 'id-6'}]
        onChange = (list) ->
          expect(list).to.have.length 2
          done()

        select = @render(<SelectFilter options=@items
          value = values
          onChange=onChange />
        )
        input  = @inputElement(select)

        listComponent = @findByType select, SelectList
        @inputValue(input, 'kenny dennis')
        @simulate.keyUp(input)

        @simulate.keyDown(input, key: 'Enter')

      it 'should close list', ->
        select = @render(<SelectFilter options=@items />)
        input  = @inputElement(select)

        listComponent = @findByType select, SelectList
        @inputValue(input, 'kenny dennis')
        @simulate.keyUp(input)

        @simulate.keyDown(input, key: 'Enter')

        expect(select.state.opened).to.be.false
        expect(listComponent.props.visible).to.be.false

    context 'and length of results is greater than one', ->

      it 'should focus list on input commit', ->
        select = @render(<SelectFilter options=@items />)
        input  = @inputElement(select)

        listComponent = @findByType select, SelectList
        @inputValue(input, 'a')
        @simulate.keyUp(input)

        @simulate.keyDown(input, key: 'Enter')

        expect(listComponent.props.shouldFocus).to.be.true

  context 'when filtering yields no results', ->

    it 'should display no results', ->
      select = @render(<SelectFilter options=@items />)
      input  = @inputElement(select)

      listComponent = @findByType select, SelectList
      @inputValue(input, 'there will be nothing to match this')
      @simulate.keyUp(input)

      listElements  = @allByTag  listComponent, 'li'
      expect(listElements).to.have.length 0

      @simulate.keyDown(input, key: 'Enter')

    it 'should reset results when input is cleared', ->
      select = @render(<SelectFilter options=@items />)
      input  = @inputElement(select)

      listComponent = @findByType select, SelectList
      @inputValue(input, 'there will be nothing to match this')
      @simulate.keyUp(input)

      listElements  = => @allByTag  listComponent, 'li'
      expect(listElements()).to.have.length 0

      @inputValue(input, '')
      @simulate.keyUp(input)

      expect(listElements()).to.have.length 9

  context 'using default filter function', ->

    it 'should throw when content is not string', ->
      items = [{content: <span><h1>one</h1><h2>two</h2></span>, id: 'id-111'}]
      select = @render(<SelectFilter options=items />)
      input  = @inputElement(select)

      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = => @allByType listComponent, SelectItem

      @inputValue(input, 'one')
      keyUpCall = => @simulate.keyUp(input, key: 'Enter')
      expect(keyUpCall).to.throw(/SelectFilter does not filter non-strings by default/)

  context 'given a filter function', ->
    it 'should call filter function with no term on render', ->
      items = [{content: <span><h1>one</h1><h2>two</h2></span>, id: 'id-111'}]
      filter = sinon.spy()

      select = @render(<SelectFilter options=items filter=filter />)
      expect(filter).to.have.been.calledWith items, undefined

    it 'should call filter function on keyUp', ->
      items = [{content: <span><h1>one</h1><h2>two</h2></span>, id: 'id-111'}]
      filter = sinon.spy()

      select = @render(<SelectFilter options=items filter=filter />)
      input  = @inputElement(select)
      inputComponent = @findByType select, Input
      listComponent  = @findByType select, SelectFilter
      itemComponents = => @allByType listComponent, SelectItem

      @inputValue(input, 'one')
      @simulate.keyUp(input, key: 'Enter')
      expect(filter).to.have.been.calledWith items, 'one'

describe 'SelectList.Input', ->

  it 'should pass defaultValue on down to the input', ->
    input = @render(<Input defaultValue='a real dark horse' />)
    inputElement = @findByTag input, 'input'
    expect(inputElement.getDOMNode()).to.have.value 'a real dark horse'

  it 'should pass placeholder on down to the input', ->
    input = @render(<Input placeholder='a real dark horse' />)
    inputElement = @findByTag input, 'input'
    expect(inputElement.getDOMNode().placeholder).to.equal 'a real dark horse'

  it 'should use value as the value if defined', ->
    input = @render <Input value        = 'a real, real dark horse'
                           defaultValue = 'a kind of non threatening horse'/>
    inputElement = @findByTag input, 'input'
    expect(inputElement.getDOMNode()).to.have.value 'a real, real dark horse'

  it 'should set focus state on focus', ->
    input = @render(<Input />)

    domElementFocus = sinon.spy()
    input._inputElement = -> { focus: domElementFocus }
    expect(input.state.focused).to.be.false

    input.focus()

    expect(input.state.focused).to.be.true
    expect(domElementFocus).to.have.been.called.once

  context 'on keyUp', ->

    it 'should call the onChange prop with the value of the input', (done) ->
      onChange = (val) ->
        expect(val).to.equal 'food'
        done()

      input = @render(<Input onChange=onChange />)

      @inputValue(input, 'food')
      @simulate.keyUp(@inputElement(input), key: 's')

  context 'on keyDown, with matching commitKey', ->

    it 'should call the onCommit prop with "Enter"', (done) ->
      onCommit = (val) ->
        expect(val).to.equal 'food'
        done()

      input = @render(<Input onCommit=onCommit />)

      @inputValue(input, 'food')
      @simulate.keyDown(@inputElement(input), key: 'Enter')

    it 'should call the onCommit prop with "ArrowDown"', (done) ->
      onCommit = (val) ->
        expect(val).to.equal 'food'
        done()

      input = @render(<Input onCommit=onCommit />)

      @inputValue(input, 'food')
      @simulate.keyDown(@inputElement(input), key: 'ArrowDown')

    it 'should call the onCommit prop on the correct keyCode', (done) ->
      onCommit = (val) ->
        expect(val).to.equal 'food'
        done()

      input = @render(<Input onCommit=onCommit commitKeyCodes=[188] />)

      @inputValue(input, 'food')
      @simulate.keyDown(@inputElement(input), keyCode: 188)

  context 'on focus', ->

    it 'should call the onFocus prop', (done) ->
      onFocus = -> done()

      input = @render(<Input onFocus=onFocus />)

      @simulate.focus(@inputElement(input))

  context 'on blur', ->

    it 'should call the onBlur prop', (done) ->
      onBlur = -> done()

      input = @render(<Input onBlur=onBlur />)

      @simulate.blur(@inputElement(input))


describe 'SelectList', ->

  beforeEach ->
    @items = [
      {content: 'custom made',        id: 'ani-1'}
      {content: 'custom paid',        id: 'ani-2'}
      {content: 'just custom fitted', id: 'ani-3'}
    ]

  it 'should be a ul element', ->
    select = @render(<SelectList options=@items />)

    expect(select.getDOMNode()).to.have.tagName 'UL'

  it 'should default state.focused to null', ->
    select = @render(<SelectList options=@items />)

    expect(select.state.focused).to.be.null

  it 'should not be visible by default', ->
    select = @render(<SelectList options=@items />)

    expect(select.props.visible).to.be.false
    expect(select.getDOMNode()).to.haveClass 'hidden'

  it 'should have the list, dropdown-menu and select classes', ->
    select = @render(<SelectList options=@items />)

    expect(select.getDOMNode()).to.haveClass 'list'
    expect(select.getDOMNode()).to.haveClass 'dropdown-menu'
    expect(select.getDOMNode()).to.haveClass 'select-list'

  it 'should render a list of the items', ->
    select  = @render(<SelectList options=@items />)
    element = select.getDOMNode()
    items   = element.querySelectorAll('li')

    expect(items).to.have.length 3

  it 'should render a list item as hovered if @state.focused == val', ->
    select  = @render(<SelectList options=@items />)
    select.setState(focused: 'ani-3')

    item = select.getDOMNode().querySelector('li.hover')

    expect(item).to.exist

  it 'should use the "value" prop as the source of value state', ->
    select  = @render(<SelectList options=@items />)
    expect(select.state.selected).to.have.length 0

    select.setState(selected: [{content: 'horses', id: 'id-77'}])

    select.setProps(value: [
      {content: 'a', id: '1'}
      {content: 'b', id: '2'}
    ])

    expect(select.state.selected).to.have.length 2
    expect(select.state.selected[0].content).to.equal 'a'
    expect(select.state.selected[1].content).to.equal 'b'

  it 'should render content containing renderable markup', ->
    items = [
      content: <span><h1>one</h1><h2>two</h2></span>, id: 'id-111'
    ]

    select = @render(<SelectList options=items />)

    span = @allByTag(select, 'span')
    expect(span).to.have.length 1
    expect(span[0].getDOMNode().textContent).to.contain 'one'
    expect(span[0].getDOMNode().textContent).to.contain 'two'

  it 'should call the onBlur prop if e.relatedTarget not a list item', ->
    onBlur = sinon.spy()

    select = @render(<SelectList options=@items onBlur=onBlur />)
    ulElement = @findByTag select, 'ul'

    otherElement = window.document.createElement('div')

    @simulate.blur(ulElement, relatedTarget: otherElement)

    expect(onBlur).to.have.been.called.once

  it 'should call the onBlur prop if e.relatedTarget is null', ->
    onBlur = sinon.spy()

    select = @render(<SelectList options=@items onBlur=onBlur />)
    ulElement = @findByTag select, 'ul'

    otherElement = window.document.createElement('div')

    @simulate.blur(ulElement, relatedTarget: null)

    expect(onBlur).to.have.been.called.once

  it 'should not call the onBlur prop if e.relatedTarget is a list item', ->
    onBlur = sinon.spy -> done()
    select = @render(<SelectList options=@items onBlur=onBlur />)
    ulElement = @findByTag select, 'ul'

    listElement = @allByClass(select, 'list-item')[2]
    expect(listElement).to.exist

    @simulate.blur(ulElement, relatedTarget: listElement.getDOMNode())

    expect(onBlur).not.to.have.been.called

  context 'when visible', ->

    beforeEach ->
      @getAnchor = (rootComponent, componentValue) ->
        item = @findFirstInTree rootComponent, (c) ->
          c.props.id is componentValue

        @findFirstInTree item, (c) ->
          c.tagName is 'A'

    it 'should preventDefault and stopPropagation on keydown'
      # TODO:  not sure how to test this

    it 'should preventDefault and stopPropagation on keyup'
      # TODO:  not sure how to test this

    it 'should not focus an element automatically when made visible', ->
      select = @render(<SelectList options=@items />)

      select.setProps visible: true

      expect(select.refs['ani-1'].state.hovered).to.be.false
      expect(select.refs['ani-2'].state.hovered).to.be.false
      expect(select.refs['ani-3'].state.hovered).to.be.false

    it 'should set state.focused to the selected element on click', ->
      select = @render(<SelectList options=@items visible=true />)

      middleItemAnchor = @getAnchor select, 'ani-2'

      @simulate.click(middleItemAnchor)

      expect(select.state.focused).to.equal 'ani-2'

    it 'should set state.focused to the selected element on Enter', ->
      select = @render(<SelectList options=@items visible=true />)

      middleItemAnchor = @getAnchor select, 'ani-2'

      @simulate.focus(middleItemAnchor)
      @simulate.keyPress(middleItemAnchor, key: 'Enter')

      expect(select.state.focused).to.equal 'ani-2'

    it 'should focus the next element on ArrowDown keydown', ->
      select = @render(<SelectList options=@items visible=true />)

      middleItemAnchor = @getAnchor select, 'ani-2'
      nextAnchor       = @getAnchor select, 'ani-3'

      @simulate.click(middleItemAnchor)

      expect(select.state.focused).to.equal 'ani-2'

      @simulate.keyPress(middleItemAnchor, key: 'ArrowDown')

      expect(select.state.focused).to.equal 'ani-3'

    it 'should focus the previous element on ArrowUp keydown', ->
      select = @render(<SelectList options=@items visible=true />)

      middleItemAnchor = @getAnchor select, 'ani-2'
      prevAnchor       = @getAnchor select, 'ani-1'

      @simulate.click(middleItemAnchor)

      expect(select.state.focused).to.equal 'ani-2'

      @simulate.keyDown(middleItemAnchor, key: 'ArrowUp')

      expect(select.state.focused).to.equal 'ani-1'

    it 'should select the focused element if enter is pressed', ->
      select = @render(<SelectList options=@items visible=true />)

      middleItemAnchor = @getAnchor select, 'ani-2'

      @simulate.keyDown(middleItemAnchor, key: 'Enter')

    it 'should retain focus on item if ArrowUp at beginning of list', ->
      select = @render(<SelectList options=@items visible=true />)

      anchor = @getAnchor select, 'ani-1'
      @simulate.click(anchor)

      @simulate.keyDown(anchor, key: 'ArrowUp')

    it 'should retain focus on item if ArrowDown at end of list', ->
      select = @render(<SelectList options=@items visible=true />)

      anchor = @getAnchor select, 'ani-3'

      @simulate.keyDown(anchor, key: 'ArrowDown')

    it 'should be notified on mouseover and set state.focused', ->
      select = @render(<SelectList options=@items visible=true />)
      middleItemAnchor = @getAnchor select, 'ani-2'
      @simulate.mouseOver(middleItemAnchor)

      expect(select.state.focused).to.equal 'ani-2'

    it 'should be notified on focus and set state.focused', ->
      select = @render(<SelectList options=@items visible=true />)
      middleItemAnchor = @getAnchor select, 'ani-2'
      @simulate.focus(middleItemAnchor)

      expect(select.state.focused).to.equal 'ani-2'

    it 'should set state.focused = null if receives shouldFocus=false prop', ->
      select = @render(
        <SelectList options=@items visible=true shouldFocus=true />
      )
      select.setState focused: 'ani-3'

      select.setProps shouldFocus: false

      expect(select.state.focused).to.be.null

  context 'with no previously selected items', ->

    it 'should not set an item as focused if shouldFocus prop is false', ->
      select = @render(<SelectList options=@items />)

      expect(select.refs['ani-1'].state.hovered).to.be.false
      expect(select.refs['ani-2'].state.hovered).to.be.false
      expect(select.refs['ani-3'].state.hovered).to.be.false

      # call setProps here as if parent component made us visible
      select.setProps visible: true, shouldFocus: false

      expect(select.refs['ani-1'].state.hovered).to.be.false
      expect(select.refs['ani-2'].state.hovered).to.be.false
      expect(select.refs['ani-3'].state.hovered).to.be.false

    it 'should select first item when shouldFocus and visible', ->
      select = @render(<SelectList options=@items />)

      expect(select.refs['ani-1'].state.hovered).to.be.false
      expect(select.refs['ani-2'].state.hovered).to.be.false
      expect(select.refs['ani-3'].state.hovered).to.be.false

      # call setProps here as if parent component made us visible
      # and set us to focus
      select.setProps visible: true, shouldFocus: true

      expect(select.state.focused).to.equal 'ani-1'
      expect(select.refs['ani-1'].state.hovered).to.be.true

  context 'with previously selected items', ->

    it 'should not remove previous selections', ->
      select = @render(<SelectList options=@items />)
      select.setProps visible: true, shouldFocus: true

      expect(select.refs['ani-1'].state.hovered).to.be.true

      # select first item
      firstItem  = select.getDOMNode().querySelector('li:nth-child(1) > a')
      @simulate.click(firstItem)

      middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')
      @simulate.click(middleItem)

      expect(select.refs['ani-2'].state.hovered).to.be.true

      select.setProps visible: true

      expect(select.refs['ani-2'].state.hovered).to.be.true

    it 'should focus the adjacent item if first item is selected', ->
      select = @render(<SelectList options=@items visible=true />)

      # select first item
      firstItem = select.getDOMNode().querySelector('li:nth-child(1) > a')
      @simulate.click(firstItem)
      expect(select.state.focused).to.equal 'ani-1'

      # set list to open and focus item automatically
      select.setProps shouldFocus: true, value: [
        {content: 'custom made', id: 'ani-1'}
      ]

      expect(select.state.focused).to.equal 'ani-2'
      expect(select.refs['ani-2'].state.hovered).to.be.true

  context 'when an item is selected', ->

    it 'should call onChange with props.value + selected item', (done) ->
      onChange = (contentValueList) ->
        expect(contentValueList).to.have.length 1
        expect(contentValueList[0].content).to.equal 'custom paid'
        expect(contentValueList[0].id).to.equal 'ani-2'
        done()

      select = @render(
        <SelectList options=@items onChange=onChange />
      )
      middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

      @simulate.click(middleItem)

    it 'should add selected class to item', ->
      select     = @render(<SelectList options=@items />)
      middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

      @simulate.click(middleItem)
      expect(select).to.haveElement 'li.selected'

    it 'should call the onChange prop with current state of value', (done) ->
      onChange = (list) ->
        expect(list).to.have.length 1
        expect(list[0].content).to.equal 'custom paid'
        expect(list[0].id).to.equal 'ani-2'
        done()

      select     = @render(<SelectList options=@items onChange=onChange />)
      middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

      @simulate.click(middleItem)

    it 'should append the selected item and mark as selected', ->
      select     = @render(<SelectList options=@items />)
      middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

      @simulate.click(middleItem)

      expect(middleItem.parentNode).to.haveClass 'selected'

      expect(select.state.selected).to.have.length 1
      expect(select.state.selected[0].id).to.equal 'ani-2'

    it 'should pick the first item on shouldFocus if no match in value', ->
      value = [
        {content: 'kaw', id: 'kw-1'}
      ]
      items = [
        {content: 'haw', id: 'hw-1'}
        {content: 'haw', id: 'hw-2'}
        {content: 'haw', id: 'hw-3'}
      ]
      select = @render(<SelectList options=items value=value />)

      select.setProps shouldFocus: true

      expect(select.state.focused).to.equal 'hw-1'

    context 'and then deselected', ->

      it 'should call onChange with value of props.value - item', (done)->
        callCount = 1
        change = (selections) ->
          if callCount is 1
            expect(selections).to.have.length(2)
          if callCount is 2
            expect(selections).to.have.length(1)
            done()
          callCount++

        value = [
          {content: 'Ghost', id: 'wallabees'}
        ]
        select = @render(
          <SelectList options=@items value=value onChange=change />
        )
        middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

        # select...
        @simulate.click(middleItem)

        # ...and deselect
        @simulate.click(middleItem)

      it 'should remove that item from selected array', ->
        select     = @render(<SelectList options=@items />)
        middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

        @simulate.click(middleItem)
        expect(select.state.selected).to.have.length 1
        expect(select.state.selected[0].id).to.equal 'ani-2'

        @simulate.click(middleItem)
        expect(select.state.selected).to.have.length 0

      it 'should no longer have the selected class', ->
        select     = @render(<SelectList options=@items />)
        middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

        @simulate.click(middleItem)
        expect(select).to.haveElement 'li.selected'

        @simulate.click(middleItem)
        expect(select).not.to.haveElement 'li.selected'

  context 'when @focused no longer matches an item in @props.options', ->

    it 'should set focused to first available option', ->
      otherItems = [
        {content: 'chester watson', id: 'rb-1'}
      ]
      select = @render(<SelectList options=@items />)
      firstItem = select.getDOMNode().querySelector('li:nth-child(1) > a')

      @simulate.click(firstItem)
      expect(select.state.focused).to.equal 'ani-1'

      select.setState(focused: 'doesnt exist')
      select.setProps(options: otherItems, shouldFocus: true)

      expect(select.state.focused).to.equal 'rb-1'


describe 'SelectItem', ->

  it 'should be an li element', ->
    item    = @render(<SelectItem content='Dog #1' id='dog-1' />)
    element = item.getDOMNode()
    expect(element).to.have.tagName 'LI'

  it 'should have the "item" class', ->
    item    = @render(<SelectItem content='Dog #1' id='dog-1' />)
    element = item.getDOMNode()
    expect(element).to.haveClass 'item'

  it 'should have selected class if selected prop is true', ->
    item    = @render(<SelectItem content='Dog #1' id='dog-1' selected=true />)
    element = item.getDOMNode()
    anchor  = element.querySelector('a')

    expect(element).to.haveClass 'selected'

  it 'should set href if given', ->
    item   = @render(<SelectItem content='Dog #1' id='dog-1' href='#example'/>)
    anchor = item.getDOMNode().querySelector('a')

    expect(anchor.getAttribute('href')).to.equal '#example'

  it 'should set "#" href by default', ->
    item   = @render(<SelectItem content='Dog #1' id='dog-1' />)
    anchor = item.getDOMNode().querySelector('a')

    expect(anchor.getAttribute('href')).to.equal '#'

  it 'should set tabIndex to -1 by default', ->
    item   = @render(<SelectItem content='Dog #1' id='dog-1' />)
    anchor = item.getDOMNode().querySelector('a')

    expect(anchor.getAttribute('tabindex')).to.equal '-1'

  describe '#setFocus', ->

    it 'should give DOM focus to the anchor element'
      # TODO:  not sure how to test this.
      # `document.activeElement` remains undefined

    it 'should have hover class if setFocus(true)', ->
      item    = @render(<SelectItem content='Dog #1' id='dog-1' />)
      element = item.getDOMNode()

      expect(element).not.to.haveClass 'hover'

      item.setFocus(true)
      expect(element).to.haveClass 'hover'

  context 'when not selected', ->

    it 'should call the onSelect function with content, id', (done) ->
      verify = (content, id) ->
        expect(content).to.equal 'Dog #1'
        expect(id).to.equal 'dog-1'
        done()

      item = @render(
        <SelectItem content='Dog #1' id='dog-1' onSelect={verify}/>
      )
      anchor = item.getDOMNode().querySelector('a')

      @simulate.click(anchor)

    it 'should set state to selected', ->
      item   = @render(<SelectItem content='Dog #1' id='dog-1' />)
      anchor = item.getDOMNode().querySelector('a')

      expect(item.state.selected).to.be.false

      @simulate.click(anchor)

      expect(item.state.selected).to.be.true

  context 'when previously selected', ->

    it 'should call the onDeselect function with content, id', ->
      item   = @render(<SelectItem content='Dog #1' id='dog-1' />)
      anchor = item.getDOMNode().querySelector('a')

      @simulate.click(anchor)
      expect(item.state.selected).to.be.true
      @simulate.click(anchor)
      expect(item.state.selected).to.be.false

    it 'should set selected state to false', ->
      item   = @render(<SelectItem content='Dog #1' id='dog-1' />)
      anchor = item.getDOMNode().querySelector('a')

      @simulate.click(anchor)
      expect(item.state.selected).to.be.true
      @simulate.click(anchor)
      expect(item.state.selected).to.be.false

  context 'when selected', ->

    it 'should toggle selected when Enter is pressed', ->
      item   = @render(<SelectItem content='Dog #1' id='dog-1' />)
      anchor = @findByTag(item, 'a')

      expect(item.state.selected).to.be.false

      @simulate.click(anchor)
      expect(item.state.selected).to.be.true

      @simulate.keyDown(anchor, key: 'Enter')

      expect(item.state.selected).to.be.false

    it 'should not toggle selected on ArrowDown press', ->
      item   = @render(<SelectItem content='Dog #1' id='dog-1' />)
      anchor = @findByTag(item, 'a')

      expect(item.state.selected).to.be.false

      @simulate.click(anchor)
      expect(item.state.hovered).to.be.true
      expect(item.state.selected).to.be.true

      @simulate.keyDown(anchor, key: 'ArrowDown')

      expect(item.state.selected).to.be.true
      expect(item.state.hovered).to.be.true

    it 'should not toggle selected on ArrowUp press', ->
      item   = @render(<SelectItem content='Dog #1' id='dog-1' />)
      anchor = @findByTag(item, 'a')

      expect(item.state.selected).to.be.false

      @simulate.click(anchor)
      expect(item.state.hovered).to.be.true
      expect(item.state.selected).to.be.true

      @simulate.keyDown(anchor, key: 'ArrowUp')

      expect(item.state.selected).to.be.true
      expect(item.state.hovered).to.be.true

  context 'when focused', ->

    it 'should become selected when Enter is pressed', ->
      item   = @render(<SelectItem content='Dog #1' id='dog-1' />)
      anchor = @findByTag(item, 'a')
      item.setHover(true)

      expect(item.state.selected).to.be.false

      @simulate.keyDown(anchor, key: 'Enter')

      expect(item.state.selected).to.be.true
