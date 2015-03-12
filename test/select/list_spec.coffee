require '../test_case'

React    = require 'react'
{expect} = require 'chai'
sinon    = require 'sinon'

SelectList = require '../../src/select/list'
SelectItem = SelectList.SelectItem


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

    it 'should preventDefault/stopPropagation on keydown ArrowUp', ->
      select = @render(<SelectList options=@items visible=true />)

      middleItemAnchor = @getAnchor select, 'ani-2'
      # click this guy to give us a "selected" state
      @simulate.click middleItemAnchor

      event =
        key: 'ArrowUp'
        stopPropagation: sinon.spy()
        preventDefault: sinon.spy()
      @simulate.keyDown middleItemAnchor, event

      expect(event.stopPropagation).to.have.been.called.once
      expect(event.preventDefault).to.have.been.called.once

    it 'should preventDefault/stopPropagation on keydown ArrowDown', ->
      select = @render(<SelectList options=@items visible=true />)

      middleItemAnchor = @getAnchor select, 'ani-2'
      # click this guy to give us a "selected" state
      @simulate.click middleItemAnchor

      event =
        key: 'ArrowDown'
        stopPropagation: sinon.spy()
        preventDefault: sinon.spy()
      @simulate.keyDown middleItemAnchor, event

      expect(event.stopPropagation).to.have.been.called.once
      expect(event.preventDefault).to.have.been.called.once

    it 'should preventDefault and stopPropagation on keyup', ->
      select = @render(<SelectList options=@items visible=true />)

      middleItemAnchor = @getAnchor select, 'ani-2'
      ## click this guy to give us a "selected" state
      @simulate.click middleItemAnchor

      event =
        key: 'ArrowDown'
        stopPropagation: sinon.spy()
        preventDefault: sinon.spy()
      @simulate.keyUp middleItemAnchor, event

      expect(event.stopPropagation).to.have.been.called.once
      expect(event.preventDefault).to.have.been.called.once

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
