require '../test_case'
{expect} = require 'chai'
sinon    = require 'sinon'
_        = require 'lodash'
React    = require 'react'


ObjectTable = require '../../src/table/object-table'
ItemsPerPageSelect  = require '../../src/table/paging/items-per-page-select'
Table  = require '../../src/table'
Footer = ObjectTable.Footer
Header = ObjectTable.Header
Pager  = ObjectTable.Pager


describe 'ObjectTable.Footer', ->

  it 'should display range start, end, and total', ->
    footer = @render <Footer total         = 99
                             start         = 10
                             perPage       = 10
                             end           = 19 />

    element = @findByClass(footer, 'range').getDOMNode()

    expect(element).to.have.textContent 'Showing 11 to 20 of 99 entries'
    expect(element.querySelector('.range .start')).to.have.textContent ' 11 '
    expect(element.querySelector('.range .end')).to.have.textContent ' 20 '
    expect(element.querySelector('.range .total')).to.have.textContent ' 99 '

  it 'should have a pager', ->
    footer = @render <Footer total         = 99
                             start         = 10
                             perPage       = 10
                             end           = 19 />

    pager = @findByClass(footer, 'pager')

    expect(pager).to.exist

  it 'should pass the onPageChange function to Pager onChange', ->
    f = ->
    footer = @render <Footer total         = 99
                             start         = 10
                             end           = 19
                             perPage       = 10
                             onPageChange = f
                             />
    pager = @findByType(footer, Pager)
    expect(pager.props.onChange).to.equal f

  it 'should pass start, perPage, and total to Pager', ->
    footer = @render <Footer total         = 99
                             start         = 10
                             perPage       = 7
                             end           = 19
                             />

    pager = @findByType(footer, Pager)
    expect(pager.props.start).to.equal 10
    expect(pager.props.perPage).to.equal 7
    expect(pager.props.total).to.equal 99

  it 'should use total as end if end > total', ->
    footer = @render <Footer total         = 17
                             start         = 10
                             perPage       = 7
                             end           = 19
                             />

    element = @findByClass(footer, 'range').getDOMNode()
    expect(element.querySelector('.range .end')).to.have.textContent ' 17 '

  it 'should use total as end if end < perPage - 1', ->
    footer = @render <Footer total         = 6
                             start         = 0
                             perPage       = 7
                             end           = 5
                             />

    element = @findByClass(footer, 'range').getDOMNode()
    expect(element.querySelector('.range .end')).to.have.textContent ' 6 '


describe 'Object Table', ->

  beforeEach ->
    @columns = [
      {field: 'id', label: 'ID'}
      {field: 'name', label: 'Name', format: (name) -> name.toUpperCase()}
      {field: 'other', label: 'Other', comparator: (v) -> v[1] }
    ]

    @rows = ({id: i, name: "thing #{i + 1}", other: ['a', i]} for i in [0..299])

  it 'should have object-table class', ->
    table = @render <ObjectTable columns   = @columns
                                 rows      = @rows />
    found = @findByClass(table, 'object-table')

    expect(found).to.exist

  it 'should be able to set class using className prop', ->
    table = @render <ObjectTable columns   = @columns
                                 className = 'hawk dawson'
                                 rows      = @rows />
    found = @findByClass(table, 'hawk dawson')

    expect(found).to.exist

  it 'should default to showing 10 rows', ->
    table = @render <ObjectTable columns = @columns
                                 rows    = @rows />

    rows = table.getDOMNode().querySelectorAll('tbody tr')

    expect(rows).to.have.length 10

  it 'should show only the number of rows per page given', ->
    table = @render <ObjectTable columns = @columns
                                 rows    = @rows />

    table.setState(perPage: 20)
    rows = table.getDOMNode().querySelectorAll('tbody tr')

    expect(rows).to.have.length 20

  context 'when changing perPage selector', ->

    it 'should update the number of rows displayed', ->
      table = @render <ObjectTable columns = @columns
                                   rows    = @rows />

      table.setState perPage: 5
      rows = table.getDOMNode().querySelectorAll('tbody tr')

      expect(rows).to.have.length 5

    it 'should update the row count in the footer', ->
      table = @render <ObjectTable columns = @columns
                                   rows    = @rows />

      footer = @findByClass table, 'range'

      expect(footer.getDOMNode())
        .to.have.textContent 'Showing 1 to 10 of 300 entries'

      table.setState perPage: 5

      expect(footer.getDOMNode())
        .to.have.textContent 'Showing 1 to 5 of 300 entries'

  context 'when paging', ->

    beforeEach ->
      @pagedTable = @render <ObjectTable columns = @columns
                                         rows    = @rows />

      pagerItems = @allByType @pagedTable, Pager.Item
      @pagerButton = (index) =>
        pagerItem = pagerItems[index]
        @findByTag pagerItem, 'button'

    it 'should display only the contents of that particular page', ->
      button = @pagerButton(3)
      @simulate.click(button)

      rows = @pagedTable.getDOMNode().querySelectorAll('tbody tr')
      expect(rows).to.have.length 10
      expect(rows[0].querySelector('[data-reactid$=".$name"]'))
        .to.have.textContent 'THING 21'

    it 'should update the footer info display', ->
      button = @pagerButton(3)
      @simulate.click(button)
      element = @findByClass(@pagedTable, 'range').getDOMNode()

      expect(element).to.have.textContent 'Showing 21 to 30 of 300 entries'

  context 'when sorting', ->

    beforeEach ->
      @sortingTable = @render <ObjectTable columns = @columns
                                           rows    = @rows />

      @columnHeaders = @allByType @sortingTable, Table.Header.Item

    it 'should be undefined and true by default', ->
      expect(@sortingTable.state.sortKey).to.be.undefined
      expect(@sortingTable.state.sortAsc).to.be.true

    it 'should store sorting state', ->
      @simulate.click(@columnHeaders[1].getDOMNode())

      expect(@sortingTable.state.sortKey).to.equal 'name'
      expect(@sortingTable.state.sortAsc).to.be.true
      expect(@sortingTable.state.comparator).to.be.undefined

      @simulate.click(@columnHeaders[1].getDOMNode())

      expect(@sortingTable.state.sortKey).to.equal 'name'
      expect(@sortingTable.state.sortAsc).to.be.false
      expect(@sortingTable.state.comparator).to.be.undefined

      @simulate.click(@columnHeaders[2].getDOMNode())

      expect(@sortingTable.state.sortKey).to.equal 'other'
      expect(@sortingTable.state.sortAsc).to.be.true
      expect(@sortingTable.state.comparator).to.be.defined

  context 'when filtering', ->

    beforeEach ->
      filter = (term, row) ->
        row.name.match(///#{term}///i)

      @filteredTable = @render <ObjectTable filter  = filter
                                            columns = @columns
                                            rows    = @rows />

      header       = @findByType @filteredTable, Header
      @searchInput = @findByTag header, 'input'
      @searchFor = (term) =>
        @searchInput.getDOMNode().value = term
        @simulate.change(@searchInput)

    it 'should set the input value as state.term', ->
      @searchFor('thing 21')

      expect(@filteredTable.state.term).to.equal 'thing 21'

    it 'should update the row count in the footer', ->
      @searchFor('thing 21')
      element = => @findByClass(@filteredTable, 'range').getDOMNode()

      expect(element()).to.have.textContent 'Showing 1 to 10 of 11 entries'

      @searchFor('thing 2')

      expect(element()).to.have.textContent 'Showing 1 to 10 of 111 entries'

    it 'should only display matching rows', ->
      @searchFor('thing 21')

      rows = @filteredTable.getDOMNode().querySelectorAll('tbody tr')
      expect(rows).to.have.length 10
      expect(rows[0].querySelector('[data-reactid$=".$name"]'))
        .to.have.textContent 'THING 21'

    it 'should update the pager', ->
      @searchFor('thing 21')
      pager = @findByClass(@filteredTable, 'pager').getDOMNode()

      buttons =  pager.querySelectorAll('button')
      # at 10 per page, we should only have two pages worth of results,
      # so pager should be [Previous] [1] [2] [Next]
      expect(buttons).to.have.length 4

    context 'and on a page that isnt the first page', ->
      beforeEach ->
        @filteredTable.setState(start: 11)

      it 'should navigate back to the first page', ->
        @searchFor('thing 21')
        expect(@filteredTable.state.start).to.equal 0

    context 'and using a filter function defined as a react method', ->

      beforeEach ->
        this.TestComponent = React.createClass
          filter: (term, row) ->
            row.name is term

          render: ->
            <ObjectTable filter  = @filter
                         columns = @props.columns
                         rows    = @props.rows />

      it 'should filter using that function', ->
        component    = @render <this.TestComponent rows    = @rows
                                                   columns = @columns />
        header       = @findByType component, Header
        searchInput  = @findByTag header, 'input'
        searchInput.getDOMNode().value = 'thing 21'
        @simulate.change(searchInput.getDOMNode())

        rows = component.getDOMNode().querySelectorAll('tbody tr')
        expect(rows).to.have.length 1
        expect(rows[0].querySelector('[data-reactid$=".$name"]'))
          .to.have.textContent 'THING 21'

  describe '#rows', ->

    beforeEach ->
      @rows = _(_.range(26))
        .shuffle()
        .map (i) -> String.fromCharCode(i + 65)
        .map (c) -> c + c + c
        .map (name, id) -> {id: id, name: name, other: ['a', id]}
        .value()

      @columns = [
        {field: 'id',   label: 'ID', comparator: null},
        {field: 'name', label: 'Name'},
      ]

      @table = @render <ObjectTable perPage = 100
                                    columns = @columns
                                    rows    = @rows />

    context 'with a range', ->

      beforeEach ->
        @table.setState
          start:    10
          perPage:  3
        @proj = @table.rows(@rows)

      it 'should project project a slice of the rows', ->
        expect(@proj).to.have.length 3

        expect(@proj[0].id).to.equal 10
        expect(@proj[1].id).to.equal 11
        expect(@proj[2].id).to.equal 12

    context 'with a sort key', ->

      beforeEach ->
        @table.setState
          sortAsc:  true
          sortKey:  'name'
        @proj = @table.rows(@rows)

      it 'should project the same number of rows', ->
        expect(@proj).to.have.length 26

      it 'should project sorted rows', ->
        expect(@proj[0].name).to.equal 'AAA'
        expect(@proj[25].name).to.equal 'ZZZ'

    context 'with a sort key and range', ->

      beforeEach ->
        @table.state.start   = 0
        @table.state.perPage = 2
        @table.state.sortKey = 'name'
        @table.state.sortAsc = true
        @proj = @table.rows(@rows)

      # If these operations are done in the wrong order, you'll get very strange
      # results -- like, the first row may not be name: AAA
      it 'should sort before taking the range', ->
        expect(@proj).to.have.length 2
        expect(@proj[0].name).to.equal 'AAA'
        expect(@proj[1].name).to.equal 'BBB'

    context 'with a comparator', ->
      beforeEach ->
        @table.setState
          sortAsc:    false
          sortKey:    'other'
          comparator: (v) -> v[1]
        @proj = @table.rows(@rows)

      it 'should project rows sorted by the comparator', ->
        expect(@proj[0].other).to.have.members ['a', 25]
        expect(@proj[25].other).to.have.members ['a', 0]

    context 'with a filter', ->

      beforeEach ->
        @filterRows = _(_.range(26))
          .shuffle()
          .map (i) -> String.fromCharCode(i + 65, 66, 67)
          .map (name, id) -> {id: id, name: name}
          .value()

      it 'should contain only matching results', ->
        filter = (term, row) ->
          row.name is term
        @table.setProps filter: filter
        @table.setState term:   'NBC'
        proj = @table.rows(@filterRows)

        expect(proj).to.have.length 1
        expect(proj[0].name).to.equal 'NBC'

      context 'and a sort key', ->

        beforeEach ->
          @table.state.sortKey = 'name'
          @table.state.sortAsc = true

        it 'should sort filtered results', ->
          @filterRows.push({id: 30, name: 'non matching'})
          filter = (term, row) ->
            row.name.match(/BC/)
          @table.setProps filter: filter
          @table.setState term:   'BC'
          proj = @table.rows(@filterRows)

          expect(proj[0].name).to.equal 'ABC'
          expect(proj[1].name).to.equal 'BBC'
          expect(proj[2].name).to.equal 'CBC'
          expect(proj).to.have.length 26

  describe 'Pager', ->

    describe '#totalPageCount', ->

      it 'should be total number of pages', ->
        pager = @render <Pager perPage = 10
                               total   = 100 />

        pageCount = pager.totalPageCount()
        expect(pageCount).to.equal 10

      it 'should round up for number of pages', ->
        pager = @render <Pager perPage = 7
                               total   = 100 />

        pageCount = pager.totalPageCount()
        expect(pageCount).to.equal 15

    describe '#pageNumberToRange', ->

      it 'should return a range approriate for perPage number', ->
        pager = @render <Pager perPage = 10
                               total   = 100 />

        [start, end] = pager.pageNumberToRange(5)

        expect(start).to.equal 50
        expect(end).to.equal 59

      it 'should return a match w/1 per page', ->
        pager = @render <Pager perPage = 1
                               total   = 25 />

        [start, end] = pager.pageNumberToRange(7)
        expect(start).to.equal 7
        expect(end).to.equal 7

    describe '#pageNumberFromRange', ->

      it 'should take a start/end and return which page it\'d be on', ->
        pager = @render <Pager perPage = 10
                               total   = 100 />

        page = pager.pageNumberFromRange(10, 19)
        expect(page).to.equal 1

      it 'should give the correct page if the range is within a page', ->
        pager = @render <Pager perPage = 10
                               total   = 100 />

        page = pager.pageNumberFromRange(23, 25)
        expect(page).to.equal 2

      it 'should give the correct page if start == end', ->
        pager = @render <Pager perPage = 1
                               total   = 100 />

        page = pager.pageNumberFromRange(23, 23)
        expect(page).to.equal 23

    describe '#currentPage', ->

      it 'should return the page number for props.start and props.end', ->
        pager = @render <Pager start   = 20
                               perPage = 10
                               total   = 100 />

        expect(pager.currentPage()).to.equal 2

      it 'should not be undefined', ->
        pager = @render <Pager start   = 0
                               perPage = 1
                               total   = 100 />

        expect(pager.currentPage()).not.to.be.undefined
        expect(pager.currentPage()).to.equal 0

    it 'should accept a total count for all items', ->
      pager = @render <Pager total=666 />
      expect(pager.props.total).to.equal 666

    it 'should default to 10 items per page', ->
      pager = @render <Pager total=123 />
      expect(pager.props.perPage).to.equal 10

    it 'should accept items per page', ->
      pager = @render <Pager total=123 perPage=20 />
      expect(pager.props.perPage).to.equal 20

    it 'should start on page 0', ->
      pager = @render <Pager total=123 />
      expect(pager.currentPage()).to.equal 0

    it 'should start with a "previous" button', ->
      pager    = @render <Pager total=123 />
      children = pager.getDOMNode().childNodes
      previous = children[0]

      expect(previous).to.have.innerHTML 'Previous'

    it 'should end with a "next" button', ->
      pager    = @render <Pager total=123 />
      children = pager.getDOMNode().childNodes
      next     = children[children.length - 1]

      expect(next).to.have.innerHTML 'Next'

    it 'should call onChange with range when clicking "next"', ->
      spy = sinon.spy()

      pager   = @render(<Pager total=21 onChange=spy />)
      pagerEl = pager.getDOMNode()

      nextButtons = pagerEl.querySelectorAll('[data-reactid$=".$next"]')
      expect(nextButtons).to.have.length 1

      @simulate.click nextButtons[0]

      expect(spy).to.have.been.calledWith 10, 19

    it 'should disable the next button on the last page', ->
      el = @render(<Pager total=9 />).getDOMNode()
      next = el.querySelector('[data-reactid$=".$next"]')
      expect(next).to.haveClass 'disabled'

    it 'should not call onChange on click if at last page', ->
      spy     = sinon.spy()
      pager   = @render(<Pager total=9 onChange=spy />)
      pagerEl = pager.getDOMNode()

      nextButton = pagerEl.querySelectorAll('[data-reactid$=".$next"]')

      expect(pager.totalPageCount()).to.equal 1
      @simulate.click(nextButton)

      expect(spy).not.to.have.been.called

    it 'should display the page numbers', ->
      el = @render(<Pager total=50 />).getDOMNode()
      selectors = el.getElementsByTagName('button')

      # 5 pages + prev/next
      expect(selectors).to.have.length 5 + 2

    it 'should have one page selector active', ->
      el = @render(<Pager total=50 />).getDOMNode()
      firstPage  = el.querySelector('[data-reactid$=":$0"]')
      secondPage = el.querySelector('[data-reactid$=":$1"]')
      expect(firstPage).to.have.textContent '1'
      expect(secondPage).to.have.textContent '2'

      expect(firstPage).to.haveClass 'active'
      expect(secondPage).to.not.haveClass 'active'

    it 'should call onChange with the range when a page number is clicked', ->
      spy = sinon.spy()
      pager = @render <Pager perPage=10 total=50 onChange=spy />
      el    = pager.getDOMNode()

      secondPage = el.querySelector('[data-reactid$=":$1"]')
      @simulate.click(secondPage)

      expect(spy).to.have.been.calledWith 10, 19

    describe 'when pages < maxVisible', ->

      it 'should show all pages', ->
        pager = @render(<Pager perPage=5 total=25 maxVisible=5 />)
        expect(pager.totalPageCount()).to.equal 5

        visible = pager.visiblePages()
        expect(visible).to.have.length 5
        expect(visible[0]).to.equal 0
        expect(visible[1]).to.equal 1
        expect(visible[2]).to.equal 2
        expect(visible[3]).to.equal 3
        expect(visible[4]).to.equal 4

    describe 'when truncating', ->

      beforeEach ->
        @pager = @render <Pager perPage    = 1
                                start      = 0
                                total      = 25
                                maxVisible = 7 />

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
          @pager.setProps(start: 24)
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
          @pager.setProps(start: 11)
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
