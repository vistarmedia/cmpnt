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



