require '../test_case'

React    = require 'react'
{expect} = require 'chai'
sinon    = require 'sinon'

SelectList   = require '../../src/select/list'
SelectFilter = require '../../src/select/filter'

SelectItem = SelectList.SelectItem
Input      = SelectFilter.Input


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


describe 'SelectFilter.Input', ->

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
