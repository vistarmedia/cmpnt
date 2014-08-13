require '../test_case'

React    = require 'react'
{expect} = require 'chai'

Pager = require '../../src/table/pager'


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


#   it 'should know the number of pages', ->
#     pager = @render(<Pager count=21 itemsPerPage=10 />)
#     expect(pager.numPages()).to.equal 3
# 
#     pager = @render(<Pager count=20 itemsPerPage=10 />)
#     expect(pager.numPages()).to.equal 2
# 
#     pager = @render(<Pager count=19 itemsPerPage=10 />)
#     expect(pager.numPages()).to.equal 2
# 
#   it 'should render previous and next items', ->
#     el = @render(<Pager count=21 itemsPerPage=10 />).getDOMNode()
# 
#     previous = el.getElementsByClassName('prev')[0]
#     expect(previous).to.have.textContent 'Previous'
# 
#     next = el.getElementsByClassName('next')[0]
#     expect(next).to.have.textContent 'Next'
# 
#   it 'should advance the page when clicking "Next"', ->
#     pager   = @render(<Pager count=21 />)
#     pagerEl = pager.getDOMNode()
# 
#     expect(pager.state.page).to.equal 0
#     next = pagerEl.getElementsByClassName('next')[0]
#     link = next.getElementsByTagName('A')[0]
#     @simulate.click(link)
#     expect(pager.state.page).to.equal 1
# 
#   it 'should not advance at the last page', ->
#     pager   = @render(<Pager count=9 />)
#     pagerEl = pager.getDOMNode()
# 
#     next = pagerEl.getElementsByClassName('next')[0]
#     link = next.getElementsByTagName('A')[0]
#     @simulate.click(link)
#     expect(pager.state.page).to.equal 0
# 
#   it 'should display the page numbers', ->
#     pager   = @render(<Pager count=50 />)
#     pagerEl = pager.getDOMNode()
# 
#     selectors = pagerEl.getElementsByTagName('li')
#     # 5 pages + prev/next
#     expect(selectors).to.have.length 5 + 2
# 
#   it 'should change the page # when clicking a selector', ->
#     pager = @render(<Pager count=50 />)
# 
#     sel4 = pager.getDOMNode().getElementsByTagName('li')[4]
#     link = sel4.getElementsByTagName('A')[0]
# 
#     expect(pager.state.page).to.equal 0
#     @simulate.click(link)
#     expect(pager.state.page).to.equal 3
# 
#   describe 'when pages < maxVisible', ->
#     it 'should show all pages', ->
#       pager = @render(<Pager itemsPerPage=5 count=25 maxVisible=5 />)
#       expect(pager.numPages()).to.equal 5
# 
#       visible = pager.visiblePages()
#       expect(visible).to.have.length 5
#       expect(visible[0]).to.equal 0
#       expect(visible[1]).to.equal 1
#       expect(visible[2]).to.equal 2
#       expect(visible[3]).to.equal 3
#       expect(visible[4]).to.equal 4
# 
#   describe 'when truncating truncating', ->
#     beforeEach ->
#       @pager = @render(<Pager itemsPerPage=1 count=25 maxVisible=7 />)
# 
#     it 'should only have maxPages items', ->
#       expect(@pager.visiblePages()).to.have.length 7
# 
#     describe 'right items', ->
#       beforeEach ->
#         @pager.setState(page: 0)
#         @visible = @pager.visiblePages()
# 
#       it 'should have 7 items', ->
#         expect(@visible).to.have.length 7
# 
#       it 'should show the first page', ->
#         expect(@visible[0]).to.equal 0
# 
#       it 'should show the last page', ->
#         expect(@visible[6]).to.equal 24
# 
#       it 'should truncate at the last-1 position', ->
#         expect(@visible[5]).to.not.exist
# 
#       it 'should fiddle to and past the middle', ->
#         expect(@visible[1]).to.equal 1
#         expect(@visible[2]).to.equal 2
#         expect(@visible[3]).to.equal 3
#         expect(@visible[4]).to.equal 4
# 
#     describe 'left items', ->
#       beforeEach ->
#         @pager.setState(page: 24)
#         @visible = @pager.visiblePages()
# 
#       it 'should have 7 items', ->
#         expect(@visible).to.have.length 7
# 
#       it 'should show the first page', ->
#         expect(@visible[0]).to.equal 0
# 
#       it 'should show the last page', ->
#         expect(@visible[6]).to.equal 24
# 
#       it 'should truncate at the 1 position', ->
#         expect(@visible[1]).to.not.exist
# 
#       it 'should fill middle values', ->
#         expect(@visible[2]).to.equal 20
#         expect(@visible[3]).to.equal 21
#         expect(@visible[4]).to.equal 22
#         expect(@visible[5]).to.equal 23
# 
#     describe 'middle items', ->
#       beforeEach ->
#         @pager.setState(page: 11)
#         @visible = @pager.visiblePages()
# 
#       it 'should have 7 items', ->
#         expect(@visible).to.have.length 7
# 
#       it 'should show the first page', ->
#         expect(@visible[0]).to.equal 0
# 
#       it 'should show the last page', ->
#         expect(@visible[6]).to.equal 24
# 
#       it 'should truncate at the 1 position', ->
#         expect(@visible[1]).to.not.exist
# 
#       it 'should truncate at the -2 position', ->
#         expect(@visible[5]).to.not.exist
# 
#       it 'should fill in middle values', ->
#         expect(@visible[2]).to.equal 10
#         expect(@visible[3]).to.equal 11
#         expect(@visible[4]).to.equal 12
# 
# 
# 
#   # it 'should truncate the maximum number of items', ->
#   #   items = @render(<Pager count=50 />).items()
#   #   expect(items).to.have.length 5
# 
# 
#   #   items = @render(<Pager count=50 maxPages=3 />).items()
#   #   expect(items).to.have.length 4
# 
#   #   expect(@render(items[0]).getDOMNode()).to.have.textContent '1'
#   #   expect(@render(items[1]).getDOMNode()).to.have.textContent '2'
#   #   expect(@render(items[2]).getDOMNode()).to.have.textContent '...'
#   #   expect(@render(items[3]).getDOMNode()).to.have.textContent '5'
