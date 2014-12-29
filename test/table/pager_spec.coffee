require '../test_case'

React    = require 'react'
{expect} = require 'chai'

Pager = require '../../src/table/paging'


describe 'Pager Item', ->

  it 'should directly render children', ->
    item = @render <Pager.Item page=0><h1>Hi!</h1></Pager.Item>
    children = item.getDOMNode().childNodes
    expect(children).to.have.length 1
    expect(children[0]).to.have.tagName 'H1'
    expect(children[0]).to.have.innerHTML 'Hi!'

  it 'should invoke onClick with the page on click', (done) ->
    clicked = (page) ->
      expect(page).to.equal 666
      done()

    item = @render <Pager.Item onClick=clicked page=666>
      <h1>Hi!</h1>
    </Pager.Item>

    @simulate.click item.getDOMNode()

  it 'should not be active by default', ->
    el = @render(<Pager.Item page=0 />).getDOMNode()
    expect(el).to.not.haveClass 'active'

  it 'should indicate an active item', ->
    el = @render(<Pager.Item page=0 active=true />).getDOMNode()
    expect(el).to.haveClass 'active'


describe 'Pager.ItemsPerPageSelect', ->

  it 'should accept a perPageCount', ->
    select = @render <Pager.ItemsPerPageSelect perPage=25 />
    expect(select.props.perPage).to.equal 25

  it 'should accept a perPageOptions', ->
    select = @render(
      <Pager.ItemsPerPageSelect perPageOptions={[25, 50, 100]} />)
    expect(select.props.perPageOptions).to.eql [25, 50, 100]

  it 'should update perPage on select', ->
    select = @render <Pager.ItemsPerPageSelect />
    el     = select.getDOMNode()
    selectEl = el.getElementsByTagName('select')[0]
    selectEl.value = '5'
    @simulate.change(selectEl)
    expect(select.state.perPage).to.equal 5

  it 'should not notify if the count <= 0', ->
    onChange = -> fail()
    select = @render <Pager.ItemsPerPageSelect onChange=onChange />

    select.onChangeRecordsPerPage(target: {value: ''})


describe 'Pager', ->

  it 'should accept an item count', ->
    pager = @render <Pager count=666 />
    expect(pager.props.count).to.equal 666

  it 'should default to 10 items per page', ->
    pager = @render <Pager count=123 />
    expect(pager.props.itemsPerPage).to.equal 10

  it 'should accept items per page', ->
    pager = @render <Pager count=123 itemsPerPage=20 />
    expect(pager.props.itemsPerPage).to.equal 20

  it 'should know the number of pages', ->
    pager = @render <Pager count=100 itemsPerPage=10 />
    expect(pager.state.numPages).to.equal 10

  it 'should round up for number of pages', ->
    pager = @render <Pager count=101 itemsPerPage=10 />
    expect(pager.state.numPages).to.equal 11

  it 'should start on page 0', ->
    pager = @render <Pager count=123 />
    expect(pager.state.page).to.equal 0

  it 'should start with a "previous" button', ->
    pager    = @render <Pager count=123 />
    children = pager.getDOMNode().childNodes
    previous = children[0]

    expect(previous).to.have.innerHTML 'Previous'

  it 'should end with a "next" button', ->
    pager    = @render <Pager count=123 />
    children = pager.getDOMNode().childNodes
    next     = children[children.length - 1]

    expect(next).to.have.innerHTML 'Next'

  it 'should update range on mount', (done) ->
    mounted = false
    onRangeChange = (start, end) ->
      if not mounted
        fail('expected component to be mounted')
      expect(start).to.equal 0
      expect(end).to.equal 9
      done()

    cls = <Pager count=100 onRangeChange=onRangeChange />

    mounted = true
    pager = @render cls

  it 'should know the number of pages', ->
    pager = @render <Pager count=21 itemsPerPage=10 />
    expect(pager.state.numPages).to.equal 3

    pager = @render <Pager count=20 itemsPerPage=10 />
    expect(pager.state.numPages).to.equal 2

    pager = @render <Pager count=19 itemsPerPage=10 />
    expect(pager.state.numPages).to.equal 2


  it 'should advance the page when clicking "Next"', ->
    pager   = @render(<Pager count=21 />)
    pagerEl = pager.getDOMNode()

    nextButtons = pagerEl.querySelectorAll('[data-reactid$=".$next"]')
    expect(nextButtons).to.have.length 1

    expect(pager.state.page).to.equal 0
    @simulate.click nextButtons[0]
    expect(pager.state.page).to.equal 1

  it 'should disable the next button on the last page', ->
    el = @render(<Pager count=9 />).getDOMNode()
    next = el.querySelector('[data-reactid$=".$next"]')
    expect(next).to.haveClass 'disabled'

  it 'should not advance at the last page', ->
    pager   = @render(<Pager count=9 />)
    pagerEl = pager.getDOMNode()

    nextButton = pagerEl.querySelectorAll('[data-reactid$=".$next"]')

    expect(pager.state.numPages).to.equal 1
    expect(pager.state.page).to.equal 0
    @simulate.click(nextButton)
    expect(pager.state.page).to.equal 0

  it 'should display the page numbers', ->
    el = @render(<Pager count=50 />).getDOMNode()
    selectors = el.getElementsByTagName('button')

    # 5 pages + prev/next
    expect(selectors).to.have.length 5 + 2

  it 'should have one page selector active', ->
    el = @render(<Pager count=50 />).getDOMNode()
    firstPage  = el.querySelector('[data-reactid$=":$0"]')
    secondPage = el.querySelector('[data-reactid$=":$1"]')
    expect(firstPage).to.have.textContent '1'
    expect(secondPage).to.have.textContent '2'

    expect(firstPage).to.haveClass 'active'
    expect(secondPage).to.not.haveClass 'active'

  it 'should change the page # when clicking a selector', ->
    pager = @render <Pager count=50 />
    el    = pager.getDOMNode()

    secondPage = el.querySelector('[data-reactid$=":$1"]')
    expect(pager.state.page).to.equal 0
    @simulate.click(secondPage)
    expect(pager.state.page).to.equal 1

  describe 'when pages < maxVisible', ->
    it 'should show all pages', ->
      pager = @render(<Pager itemsPerPage=5 count=25 maxVisible=5 />)
      expect(pager.state.numPages).to.equal 5

      visible = pager.visiblePages()
      expect(visible).to.have.length 5
      expect(visible[0]).to.equal 0
      expect(visible[1]).to.equal 1
      expect(visible[2]).to.equal 2
      expect(visible[3]).to.equal 3
      expect(visible[4]).to.equal 4

  describe 'when truncating', ->

    beforeEach ->
      @pager = @render(<Pager itemsPerPage=1 count=25 maxVisible=7 />)

    it 'should only have maxPages items', ->
      expect(@pager.visiblePages()).to.have.length 7

    describe 'right items', ->
      beforeEach ->
        @pager.setState(page: 0)
        @visible = @pager.visiblePages()

      it 'should have 7 items', ->
        expect(@visible).to.have.length 7

      it 'should show the first page', ->
        expect(@visible[0]).to.equal 0

      it 'should show the last page', ->
        expect(@visible[6]).to.equal 24

      it 'should truncate at the last-1 position', ->
        expect(@visible[5]).to.not.exist

      it 'should fiddle to and past the middle', ->
        expect(@visible[1]).to.equal 1
        expect(@visible[2]).to.equal 2
        expect(@visible[3]).to.equal 3
        expect(@visible[4]).to.equal 4

    describe 'left items', ->
      beforeEach ->
        @pager.setState(page: 24)
        @visible = @pager.visiblePages()

      it 'should have 7 items', ->
        expect(@visible).to.have.length 7

      it 'should show the first page', ->
        expect(@visible[0]).to.equal 0

      it 'should show the last page', ->
        expect(@visible[6]).to.equal 24

      it 'should truncate at the 1 position', ->
        expect(@visible[1]).to.not.exist

      it 'should fill middle values', ->
        expect(@visible[2]).to.equal 20
        expect(@visible[3]).to.equal 21
        expect(@visible[4]).to.equal 22
        expect(@visible[5]).to.equal 23

    describe 'middle items', ->
      beforeEach ->
        @pager.setState(page: 11)
        @visible = @pager.visiblePages()

      it 'should have 7 items', ->
        expect(@visible).to.have.length 7

      it 'should show the first page', ->
        expect(@visible[0]).to.equal 0

      it 'should show the last page', ->
        expect(@visible[6]).to.equal 24

      it 'should truncate at the 1 position', ->
        expect(@visible[1]).to.not.exist

      it 'should truncate at the -2 position', ->
        expect(@visible[5]).to.not.exist

      it 'should fill in middle values', ->
        expect(@visible[2]).to.equal 10
        expect(@visible[3]).to.equal 11
        expect(@visible[4]).to.equal 12
