# @name: Object Table
#
# @description: A table complete with a "per page" selector, numbered paging
# controls, and filtering.
#
# Takes a list of rows, with rows in the form of objects with "id" and "name"
# keys.
#
# Your filter function will be called for each row in the rows array; if the
# return value is true, that row is a match.  Your function should take two
# arguments:  "term", which will be the value of the search input element, and
# "row" which will be the row.
#
# @example: ->
#
#   React.createClass
#
#     getInitialState: ->
#       rows:     ({id: i, name: "Model #{i+1}"} for i in [0..299])
#       columns:  [
#         {field: 'id',   label: 'ID'},
#         {
#           field: 'name'
#           label: 'Name'
#           width: '100%'
#           format: ((name) -> "#{name}!")
#         }
#       ]
#
#     filterByName: (term, row) ->
#       row.name?.match(///#{term}///i)
#
#     render: ->
#       <ObjectTable columns  = @state.columns
#                    rows     = @state.rows
#                    filter   = @filterByName />
#


React      = require 'react'
{classSet} = require('react/addons').addons
_          = require 'lodash'

projection         = require './projection'
Table              = require './index'
ItemsPerPageSelect = require './paging/items-per-page-select'

Button = require '../form/button'

ColumnType  = React.PropTypes.object
ColumnsType = React.PropTypes.arrayOf(ColumnType)
RowType     = React.PropTypes.object
RowsType    = React.PropTypes.arrayOf(RowType)


RangeInfo = React.createClass
  displayName: 'ObjectTable.RangeInfo'

  propTypes:
    start:          React.PropTypes.number.isRequired
    end:            React.PropTypes.number.isRequired
    perPage:        React.PropTypes.number.isRequired
    total:          React.PropTypes.number.isRequired

  render: ->
    <div className=@_rangeClasses()>
      Showing
        <span className='start'> {@_indexToFriendly(@start())} </span>
        to<span className='end'> {@_indexToFriendly(@end())} </span>
        of<span className='total'> {@props.total} </span>
      entries
    </div>

  start: ->
    if @props.total is 0 then -1 else @props.start

  end: ->
    if @props.end < (@props.perPage - 1) or @props.end > @props.total
      @props.total - 1
    else
      @props.end

  _indexToFriendly: (index) -> index + 1

  _rangeClasses: ->
    classSet
      'col-sm-6': true
      'range':    true


Footer = React.createClass
  displayName: 'ObjectTable.Footer'

  propTypes:
    start:         React.PropTypes.number.isRequired
    end:           React.PropTypes.number.isRequired
    perPage:       React.PropTypes.number.isRequired
    total:         React.PropTypes.number.isRequired
    onPageChange:  React.PropTypes.func

  render: ->
    <div className='row'>
      {React.createElement(RangeInfo,  @props)}
      {React.createElement(
        Pager, _.assign(_.clone(@props), onChange: @props.onPageChange))}
    </div>


Header = React.createClass
  displayName: 'ObjectTable.Header'

  propTypes:
    perPage:         React.PropTypes.number.isRequired
    onPerPageChange: React.PropTypes.func
    onTermChange:    React.PropTypes.func

  handleTermChange: (e) ->
    @props.onTermChange?(e.currentTarget.value)

  handlePerPageChange: (numPerPage) ->
    @props.onPerPageChange?(numPerPage)

  render: ->
    <div className='row'>
      <div className='col-sm-6'>
        <ItemsPerPageSelect
          perPage  = @props.perPage
          onChange = @handlePerPageChange />
      </div>
      <div className='col-sm-6 pull-right'>
        <input
          type        = 'text'
          placeholder = 'Filter'
          onChange    = @handleTermChange />
      </div>
    </div>


Pager = React.createClass
  displayName: 'ObjectTable.Pager'

  propTypes:
    # start is rows displayed, zero indexed
    start:          React.PropTypes.number.isRequired

    # number of items to be displayed per page
    perPage:        React.PropTypes.number
    # total is the total number of rows displayed
    total:          React.PropTypes.number.isRequired
    # maxVisible is the max number of numbered and/or ellipsis'd elements to
    # display.  so "7" would result in a pager that looked like
    # [1] [...] [8] [9] [10] [...] [30]
    # when on the 9th page out of 30
    maxVisible:     React.PropTypes.number
    # called with start, end
    onRangeChange:  React.PropTypes.func
    onChange:       React.PropTypes.func

  getDefaultProps: ->
    perPage:     10
    maxVisible:  10
    start:       0

  pageNumberToRange: (pageNum) ->
    # return the range covered by the given pageNum.  begins at zero
    start      = pageNum * @props.perPage
    logicalEnd = start + (@props.perPage - 1)
    end        = Math.min(logicalEnd, Math.max(1, @props.total) - 1)

    [start, end]

  pageNumberFromRange: (start, end) ->
    for num in [0..@lastPageIndex()]
      [pageStart, pageEnd] = @pageNumberToRange(num)
      if start >= pageStart and end <= pageEnd
        return num

  end: ->
    @props.start + (@props.perPage - 1)

  currentPage: ->
    end = Math.min(@end(), @props.total - 1)
    @pageNumberFromRange(@props.start, end)

  totalPageCount: ->
    Math.max(1, Math.ceil(@props.total / @props.perPage))

  lastPageIndex: -> Math.max(0, @totalPageCount() - 1)

  handlePageChange: (page) ->
    @props.onChange?(@pageNumberToRange(page)...)

  render: ->
    currentPage = @currentPage()
    hasPrevious = currentPage > 0
    hasNext     = currentPage < @totalPageCount() - 1

    <div className='pager btn-group'>
      <Pager.Item key       = 'prev'
                  onClick   = @handlePageChange
                  page      = {currentPage - 1}
                  disabled  = {not hasPrevious}>
        Previous
      </Pager.Item>

      {@_items()}

      <Pager.Item key       = 'next'
                  onClick   = @handlePageChange
                  page      = {currentPage + 1}
                  disabled  = {not hasNext}>
        Next
      </Pager.Item>
    </div>

  # Generate the numeric items to be rendered as options in the pager. The first
  # and last pages will always be shown. If the logical number of page selectors
  # to show exceeds maxVisible, ellipsises will be inserted
  visiblePages: ->
    logicalPages = @totalPageCount()
    maxVisible   = @props.maxVisible
    maxPage      = @lastPageIndex()

    if logicalPages <= maxVisible
      return [0..maxPage]

    page = @currentPage()
    pages = []
    pages.length = maxVisible
    lastPage = maxVisible - 1

    # The first and last visible pages will always be the first and last logical
    # pages.
    pages[0] = 0
    pages[lastPage] = maxPage

    # The active page should sit in the middle of the array. Err to the left
    middle = Math.floor(maxVisible / 2)

    # If it's positition relative to the start is to the left to the middle, the
    # left hand side needs to truncation. Fill to length-1
    if page <= middle
      # Account for left anchor, right anchor, and right ellipsis
      fillLen = maxVisible - 3
      pages.splice(1, fillLen, [1..fillLen]...)

    # If the page is within a mid-length to the last page, only truncate to the
    # left
    else if (maxPage - page) < middle
      fillLen = maxVisible - 3
      fill = [maxPage-fillLen..maxPage-1]
      pages.splice(2, fillLen, fill...)

    # Otherwise, throw it in the middle and truncate both sides
    else
      # 2 end anchors and 2 ellipsis
      len    = maxVisible - 4
      nLeft  = Math.ceil(len / 2) - 1
      nRight = Math.floor(len/ 2)
      pages.splice(2, len, [page-nLeft..page+nRight]...)

    pages

  _items: ->
    elipNo  = 0
    current = @currentPage()
    for i in @visiblePages()
      if i?
        <Pager.Item key     = i
                    onClick = @handlePageChange
                    active  = {i is current}
                    page    = i>
          {i+1}
        </Pager.Item>
      else
        elipNo += 1
        key    = "elip-#{elipNo}"
        <Pager.Item key=key disabled=on>...</Pager.Item>


# Single item of a pager. May be 'previous', 'next', or some number indicating
# the current page number.
Pager.Item = React.createClass
  displayName: 'Pager.Item'

  propTypes:
    disabled: React.PropTypes.bool
    active:   React.PropTypes.bool
    onClick:  React.PropTypes.func
    page:     React.PropTypes.number

  getDefaultProps: ->
    disabled: false
    active:   false

  onClick: ->
    @props.onClick?(@props.page)

  render: ->
    className = if @props.active then 'active'

    <Button onClick   = @onClick
            disabled  = @props.disabled
            className = className>
      {@props.children}
    </Button>


ObjectTable = React.createClass

  propTypes:
    columns:    ColumnsType.isRequired
    rows:       RowsType.isRequired
    keyField:   React.PropTypes.string

    # start and end are rows, index 0
    start:      React.PropTypes.number
    end:        React.PropTypes.number

    sortKey:    React.PropTypes.string
    sortAsc:    React.PropTypes.bool

    filter:     React.PropTypes.func
    className:  React.PropTypes.string
    rowClass:   React.PropTypes.func

  getDefaultProps: ->
    perPage:    10
    start:      0
    sortAsc:    true
    className:  ''

  getInitialState: ->
    perPage: @props.perPage
    start:   @props.start
    sortKey: @props.sortKey
    sortAsc: @props.sortAsc

  componentWillReceiveProps: (nextProps) ->
    @setState(
      perPage: nextProps.perPage
      start:   nextProps.start)

  handlePerPageChange: (perPage) ->
    @setState(perPage: perPage)

  handleTermChange: (term) ->
    start = if @state.start isnt 0 then 0 else @state.start
    @setState(term: term, start: start)

  handleRangeChange: (start, end) ->
    @setState(start: start)

  handleSortChange: (field, isSortAsc, comparator) ->
    @setState
      comparator: comparator
      sortKey:    field
      sortAsc:    isSortAsc

  end: ->
    @state.start + (@state.perPage - 1)

  rows: (initial) ->
    filter = if @state.term and @props.filter?
      # have to specify the arity here incase we're passing in a function
      # defined on a React class, which as a value will be a function with arity
      # 0, which _.curry would end up executing instead of currying
      _.curry(@props.filter, 2)(@state.term)

    comparator = @state.comparator or @state.sortKey

    range  = projection.define 'range',
      _.curry(projection.range)(@state.start, @end())
    order  = projection.define 'order',
      _.curry(projection.order)(comparator, @state.sortAsc)
    filter = projection.define 'filter', _.curry(projection.filter)(filter)

    project = projection.compose range, order, filter

    rows = _(initial)
    project(rows).value()

  render: ->
    rows = @rows(@props.rows)
    tableProps =
      start:    @state.start
      perPage:  @state.perPage
      sortKey:  @state.sortKey
      sortAsc:  @state.sortAsc
      end:      @end()
      rows:     rows
      onSort:   @handleSortChange

    <span className=@_classes()>

      <Header
        perPage         = @state.perPage
        onPerPageChange = @handlePerPageChange
        onTermChange    = @handleTermChange />

      {React.createElement(Table, _.assign(_.clone(@props), tableProps))}

      <Footer
        start         = @state.start
        end           = @end()
        perPage       = @state.perPage
        onPageChange  = @handleRangeChange
        perPage       = @state.perPage
        total         = rows.meta.filter />

    </span>

  _classes: ->
    classes =
      'object-table':         true
    classes[@props.className] = true
    classSet classes


ObjectTable.Header = Header
ObjectTable.Footer = Footer
ObjectTable.Pager  = Pager

module.exports = ObjectTable
