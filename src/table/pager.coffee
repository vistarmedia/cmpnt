# @name: Pager
#
# @description: Given a 'count' parameter, this will manage and render some
# number of "pages." The number of items per page can be over-ridden with the
# 'itemsPerPage' property. The default is 10. The maximum number of visible
# pages to click defaults to 10, but can be over-ridden with the 'maxVisible'
# property.
#
# @example: ->
#   React.createClass
#
#     getInitialState: ->
#       start: undefined
#       end:   undefined
#
#     rangeChange: (start, end) ->
#       @setState(start: start, end: end)
#
#     render: ->
#       <span>
#         <p>Range: {@state.start}-{@state.end}</p>
#         <p>
#           <Pager count=42 onRangeChange=@rangeChange />
#         </p>
#       </span>
React = require 'react'

Button = require '../form/button'



# Pager will accept a 'count' property and invoke an 'onRangeChange' callback
# that should take the starting and ending positions.
Pager = React.createClass
  displayName: 'Pager'

  propTypes:
    count:          React.PropTypes.number.isRequired
    itemsPerPage:   React.PropTypes.number
    maxVisible:     React.PropTypes.number
    onRangeChange:  React.PropTypes.func

  getDefaultProps: ->
    itemsPerPage: 10
    maxVisible:   10

  getInitialState: ->
    page:     0
    numPages: @_numPages(@props)

  componentDidMount: ->
    @_setPage(0)

  componentWillReceiveProps: (props) ->
    numPages = @_numPages(props)
    page     = Math.min(@state.page, numPages-1)

    @setState(numPages: numPages)

  render: ->
    hasPrevious = @state.page > 0
    hasNext     = @state.page < @state.numPages - 1

    <div className='pager btn-group'>
      <Pager.Item key       = 'prev'
                  onClick   = @_setPage
                  page      = {@state.page-1}
                  disabled  = {not hasPrevious}>
        Previous
      </Pager.Item>

      {@_items()}

      <Pager.Item key       = 'next'
                  onClick   = @_setPage
                  page      = {@state.page+1}
                  disabled  = {not hasNext}>
        Next
      </Pager.Item>
    </div>

  _numPages: (props) ->
    Math.ceil(props.count / props.itemsPerPage)

  _setPage: (page) ->
    start      = page * @props.itemsPerPage
    logicalEnd = start + (@props.itemsPerPage - 1)
    end        = Math.min(logicalEnd, @props.count-1)

    @props.onRangeChange?(start, end)
    @setState(page: Math.min(page, @state.numPages))

  # Generate the numeric items to be rendered as options in the pager. The first
  # and last pages will always be shown. If the logical number of page selectors
  # to show exceeds maxPages, ellipsises will be inserted
  visiblePages: ->
    logicalPages = @state.numPages
    maxVisible   = @props.maxVisible
    maxPage      = logicalPages - 1

    if logicalPages <= maxVisible
      return [0..maxPage]

    page = @state.page
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
    current = @state.page
    for i in @visiblePages()
      if i?
        <Pager.Item key     = i
                    onClick = @_setPage
                    active  = {i is @state.page}
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


module.exports = Pager
