require '../test_case'

{expect} = require 'chai'
sinon    = require 'sinon'

SelectList = require '../../src/select/list'

SelectItem = SelectList.SelectItem


describe 'SelectList', ->

  beforeEach ->
    @items = [
      {name: 'custom made',        value: 'ani-1'}
      {name: 'custom paid',        value: 'ani-2'}
      {name: 'just custom fitted', value: 'ani-3'}
    ]

  it 'should be a ul element', ->
    select = @render(<SelectList options=@items />)

    expect(select.getDOMNode()).to.have.tagName 'UL'

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

  context 'when visible', ->

    beforeEach ->
      @getAnchor = (rootComponent, componentValue) ->
        item = @findFirstInTree rootComponent, (c) ->
          c.props.value is componentValue

        @findFirstInTree item, (c) ->
          c.tagName is 'A'

    it 'should preventDefault and stopPropagation on keydown'
      # TODO:  not sure how to test this

    it 'should preventDefault and stopPropagation on keyup'
      # TODO:  not sure how to test this

    it 'should set state.focused to the selected element on click', ->
      select = @render(<SelectList options=@items visible=true />)

      middleItemAnchor = @getAnchor select, 'ani-2'

      @simulate.click(middleItemAnchor)

      expect(select.state.focused).to.equal 'ani-2'

    it 'should set state.focused to the selected element on Enter', ->
      select = @render(<SelectList options=@items visible=true />)

      middleItemAnchor = @getAnchor select, 'ani-2'

      @simulate.focus(middleItemAnchor)
      @simulate.keyDown(middleItemAnchor, key: 'Enter')

      expect(select.state.focused).to.equal 'ani-2'

    it 'should focus the next element on ArrowDown keydown', ->
      select = @render(<SelectList options=@items visible=true />)

      middleItemAnchor = @getAnchor select, 'ani-2'
      nextAnchor       = @getAnchor select, 'ani-3'

      @simulate.click(middleItemAnchor)

      expect(select.state.focused).to.equal 'ani-2'

      @simulate.keyDown(middleItemAnchor, key: 'ArrowDown')

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

  context 'with no previously selected items', ->

    it 'should select first item when made visible', ->
      select = @render(<SelectList options=@items />)

      expect(select.refs['ani-1'].state.hovered).to.be.false
      expect(select.refs['ani-2'].state.hovered).to.be.false
      expect(select.refs['ani-3'].state.hovered).to.be.false

      # call setProps here as if parent component made us visible
      select.setProps visible: true

      expect(select.refs['ani-1'].state.hovered).to.be.true

    it 'should default @state.focused to the value of the first item', ->
      select = @render(<SelectList options=@items />)
      expect(select.state.focused).to.equal 'ani-1'

  context 'with previously selected items', ->

    it 'should not remove selection', ->
      select = @render(<SelectList options=@items />)
      select.setProps visible: true

      expect(select.refs['ani-1'].state.hovered).to.be.true

      middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')
      @simulate.click(middleItem)

      expect(select.refs['ani-2'].state.hovered).to.be.true

      select.setProps visible: true

      expect(select.refs['ani-2'].state.hovered).to.be.true

  context 'when an item is selected', ->

    it 'should append the selected item and mark as selected', ->
      select     = @render(<SelectList options=@items />)
      middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

      @simulate.click(middleItem)

      expect(select.state.selected).to.include 'ani-2'
      expect(select.state.selected).to.have.length 1

    it 'should add selected class to item', ->
      select     = @render(<SelectList options=@items />)
      middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

      @simulate.click(middleItem)
      expect(select).to.haveElement 'li.selected'

    it 'should call the onChange prop with current state of selections', (done) ->
      onChange = (list) ->
        expect(list).to.have.length 1
        expect(list).to.include 'ani-2'
        done()

      select     = @render(<SelectList options=@items onChange=onChange />)
      middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

      @simulate.click(middleItem)

    context 'and then deselected', ->

      it 'should remove that item from selected array', ->
        select     = @render(<SelectList options=@items />)
        middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

        @simulate.click(middleItem)
        expect(select.state.selected).to.have.length 1
        expect(select.state.selected).to.include 'ani-2'

        @simulate.click(middleItem)
        expect(select.state.selected).to.have.length 0

      it 'should no longer have the selected class', ->
        select     = @render(<SelectList options=@items />)
        middleItem = select.getDOMNode().querySelector('li:nth-child(2) > a')

        @simulate.click(middleItem)
        expect(select).to.haveElement 'li.selected'

        @simulate.click(middleItem)
        expect(select).not.to.haveElement 'li.selected'


describe 'SelectItem', ->

  it 'should be an li element', ->
    item    = @render(<SelectItem name='Dog #1' value='dog-1' />)
    element = item.getDOMNode()
    expect(element).to.have.tagName 'LI'

  it 'should have the "item" class', ->
    item    = @render(<SelectItem name='Dog #1' value='dog-1' />)
    element = item.getDOMNode()
    expect(element).to.haveClass 'item'

  it 'should be selected when clicked', ->
    item   = @render(<SelectItem name='Dog #1' value='dog-1' />)
    anchor = item.getDOMNode().querySelector('a')
    expect(item.state.selected).to.be.false

    @simulate.click(anchor)

    expect(item.state.selected).to.be.true

  it 'should have selected class if selected', ->
    item    = @render(<SelectItem name='Dog #1' value='dog-1' />)
    element = item.getDOMNode()
    anchor  = element.querySelector('a')
    expect(element).not.to.haveClass 'selected'

    @simulate.click(anchor)

    expect(element).to.haveClass 'selected'

  it 'should set href if given', ->
    item   = @render(<SelectItem name='Dog #1' value='dog-1' href='#example'/>)
    anchor = item.getDOMNode().querySelector('a')

    expect(anchor.getAttribute('href')).to.equal '#example'

  it 'should set "#" href by default', ->
    item   = @render(<SelectItem name='Dog #1' value='dog-1' />)
    anchor = item.getDOMNode().querySelector('a')

    expect(anchor.getAttribute('href')).to.equal '#'

  it 'should set tabIndex to -1 by default', ->
    item   = @render(<SelectItem name='Dog #1' value='dog-1' />)
    anchor = item.getDOMNode().querySelector('a')

    expect(anchor.getAttribute('tabindex')).to.equal '-1'

  describe '#setFocus', ->

    it 'should give DOM focus to the anchor element'
      # TODO:  not sure how to test this.
      # `document.activeElement` remains undefined

    it 'should have hover class if setFocus(true)', ->
      item    = @render(<SelectItem name='Dog #1' value='dog-1' />)
      element = item.getDOMNode()

      expect(element).not.to.haveClass 'hover'

      item.setFocus(true)
      expect(element).to.haveClass 'hover'

  context 'when not selected', ->

    it 'should call the onSelect function with name, value', (done) ->
      verify = (name, value) ->
        expect(name).to.equal 'Dog #1'
        expect(value).to.equal 'dog-1'
        done()

      item = @render(
        <SelectItem name='Dog #1' value='dog-1' onSelect={verify}/>
      )
      anchor = item.getDOMNode().querySelector('a')

      @simulate.click(anchor)

    it 'should set state to selected', ->
      item   = @render(<SelectItem name='Dog #1' value='dog-1' />)
      anchor = item.getDOMNode().querySelector('a')

      expect(item.state.selected).to.be.false

      @simulate.click(anchor)

      expect(item.state.selected).to.be.true

  context 'when previously selected', ->

    it 'should call the onDeselect function with name, value', ->
      item   = @render(<SelectItem name='Dog #1' value='dog-1' />)
      anchor = item.getDOMNode().querySelector('a')

      @simulate.click(anchor)
      expect(item.state.selected).to.be.true
      @simulate.click(anchor)
      expect(item.state.selected).to.be.false

    it 'should set selected state to false', ->
      item   = @render(<SelectItem name='Dog #1' value='dog-1' />)
      anchor = item.getDOMNode().querySelector('a')

      @simulate.click(anchor)
      expect(item.state.selected).to.be.true
      @simulate.click(anchor)
      expect(item.state.selected).to.be.false

  context 'when selected', ->

    it 'should toggle selected when Enter is pressed', ->
      item   = @render(<SelectItem name='Dog #1' value='dog-1' />)
      anchor = @findByTag(item, 'a')

      expect(item.state.selected).to.be.false

      @simulate.click(anchor)
      expect(item.state.selected).to.be.true

      @simulate.keyDown(anchor, key: 'Enter')

      expect(item.state.selected).to.be.false

    it 'should not toggle selected on ArrowDown press', ->
      item   = @render(<SelectItem name='Dog #1' value='dog-1' />)
      anchor = @findByTag(item, 'a')

      expect(item.state.selected).to.be.false

      @simulate.click(anchor)
      expect(item.state.hovered).to.be.true
      expect(item.state.selected).to.be.true

      @simulate.keyDown(anchor, key: 'ArrowDown')

      expect(item.state.selected).to.be.true
      expect(item.state.hovered).to.be.true

    it 'should not toggle selected on ArrowUp press', ->
      item   = @render(<SelectItem name='Dog #1' value='dog-1' />)
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
      item   = @render(<SelectItem name='Dog #1' value='dog-1' />)
      anchor = @findByTag(item, 'a')
      item.setHover(true)

      expect(item.state.selected).to.be.false

      @simulate.keyDown(anchor, key: 'Enter')

      expect(item.state.selected).to.be.true