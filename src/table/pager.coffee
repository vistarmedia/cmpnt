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
#           <Pager count=100 onRangeChange=@rangeChange />
#         </p>
#       </span>
React = require 'react'

Button = require '../form/button'


Item2 = React.createClass
  onClick: (e) ->
    e?.preventDefault()
    unless @props.disabled then @props.onClick()

  render: ->
    classes = []
    if @props.className then classes.push(@props.className)
    if @props.disabled then classes.push('disabled')
    if @props.active then classes.push('active')

    <li className={classes.join(' ')}>
      <a href="#" onClick=@onClick>
        {@props.label}
      </a>
    </li>


# Pager will accept a 'count' property and invoke an 'onRangeChange' callback
# that should take the starting and ending positions.
Pager = React.createClass
  name: 'Pager'

  propTypes:
    count:          React.PropTypes.number.isRequired
    itemsPerPage:   React.PropTypes.number
    onRangeChange:  React.PropTypes.func

  getDefaultProps: ->
    itemsPerPage: 10

  getInitialState: ->
    numPages: @_numPages()

  componentDidMount: ->
    @_setPage(0)

  render: ->
    hasPrevious = @state.page > 0
    hasNext     = true

    <div className='pager btn-group'>
      <Pager.Item key       = 'prev'
                  onClick   = @_setPage
                  page      = {@state.page-1}
                  disabled  = {not hasPrevious}>
        Previous
      </Pager.Item>

      <Pager.Item key       = 'next'
                  onClick   = @_setPage
                  page      = {@state.page+1}
                  disabled  = {not hasNext}>
        Next
      </Pager.Item>
    </div>

  _numPages: ->
    Math.ceil(@props.count / @props.itemsPerPage)

  _setPage: (page) ->
    start = page * @props.itemsPerPage
    end   = start + (@props.itemsPerPage - 1)
    @props.onRangeChange?(start, end)
    @setState(page: page)
  # getInitialState: ->
  #   maxVisible:   @props.maxVisible or 10
  #   itemsPerPage: @props.itemsPerPage or 10
  #   page:         0

  # componentWillReceiveProps: (props) ->
  #   if props.itemsPerPage? and  props.itemsPerPage isnt @state.itemsPerPage
  #     @setState(itemsPerPage: props.itemsPerPage)

  # numPages: ->
  #   Math.ceil(@props.count / @state.itemsPerPage)

  # setPage: (n) ->
  #   maxPage = @numPages() - 1
  #   if n < 0 then n = 0
  #   if n > maxPage then n = maxPage
  #   if n is @state.page then return

  #   @setState(page: n)
  #   start = n * @state.itemsPerPage
  #   end   = start + @state.itemsPerPage - 1

  #   @props.onChangePage?(n)
  #   @props.onChangeRange?(start, end)

  # pageSetter: (n) ->
  #   (e) =>
  #     e?.preventDefault()
  #     @setPage(n)

  # # Generate the numeric items to be rendered as options in the pager. The first
  # # and last pages will always be shown. If the logical number of page selectors
  # # to show exceeds maxPages, ellipsises will be inserted
  # visiblePages: ->
  #   logicalPages = @numPages()
  #   maxVisible   = @state.maxVisible
  #   maxPage      = logicalPages - 1

  #   if logicalPages <= maxVisible
  #     return [0..maxPage]

  #   page = @state.page
  #   pages = []
  #   pages.length = maxVisible
  #   lastPage = maxVisible - 1

  #   # The first and last visible pages will always be the first and last logical
  #   # pages.
  #   pages[0] = 0
  #   pages[lastPage] = maxPage

  #   # The active page should sit in the middle of the array. Err to the left
  #   middle = Math.floor(maxVisible / 2)

  #   # If it's positition relative to the start is to the left to the middle, the
  #   # left hand side needs to truncation. Fill to length-1
  #   if page <= middle
  #     # Account for left anchor, right anchor, and right ellipsis
  #     fillLen = maxVisible - 3
  #     pages.splice(1, fillLen, [1..fillLen]...)

  #   # If the page is within a mid-length to the last page, only truncate to the
  #   # left
  #   else if (maxPage - page) < middle
  #     fillLen = maxVisible - 3
  #     fill = [maxPage-fillLen..maxPage-1]
  #     pages.splice(2, fillLen, fill...)

  #   # Otherwise, throw it in the middle and truncate both sides
  #   else
  #     # 2 end anchors and 2 ellipsis
  #     len    = maxVisible - 4
  #     nLeft  = Math.ceil(len / 2) - 1
  #     nRight = Math.floor(len/ 2)
  #     pages.splice(2, len, [page-nLeft..page+nRight]...)

  #   pages

  # items: ->
  #   elipNo  = 0
  #   current = @state.page
  #   for i in @visiblePages()
  #     if i?
  #       <Pager.Item key=i
  #             active={i is current}
  #             onClick={@pageSetter(i)}
  #             label={i + 1} />
  #     else
  #       elipNo += 1
  #       <Pager.Item key={"elip-#{elipNo}"} disabled=true label='...' />

  # render: ->
  #   maxPage = @numPages() - 1
  #   page    = Math.min(@state.page, maxPage)
  #   empty   = maxPage < 0

  #   <div className='btn-group'>
  #     <ul className='pagination'>
  #       <Pager.Item key='previous'
  #             className='prev'
  #             disabled={page is 0 or empty}
  #             onClick={@pageSetter(page - 1)}
  #             label="Previous" />

  #       {@items(page, maxPage) unless empty}

  #       <Pager.Item key='next'
  #             className='next'
  #             disabled={page >= maxPage}
  #             onClick={@pageSetter(page + 1)}
  #             label="Next" />
  #     </ul>
  #   </div>


# Single item of a pager. May be 'previous', 'next', or some number indicating
# the current page number.
Pager.Item = React.createClass
  propTypes:
    disabled: React.PropTypes.bool
    onClick:  React.PropTypes.func
    page:     React.PropTypes.number.isRequired

  getDefaultProps: ->
    disabled: false

  onClick: ->
    @props.onClick?(@props.page)

  render: ->
    <Button onClick=@onClick disabled=@props.disabled>
      {@props.children}
    </Button>


module.exports = Pager
