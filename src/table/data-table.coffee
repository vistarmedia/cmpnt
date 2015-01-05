# @name: Data Table
#
# @description: A data table which can display some columns for a collection of
# models.
#
# If given a "filter" property, an input allowing the user to filter all rows
# will be displayed.
#
# If given an "itemsPerPage" property, a select will be rendered which will
# allow the user to select how many items per page they'd like to see.  If
# omitted, this select will not be rendered.
#
# The "row" property may optionally be a ReactComponent class.  This allows you
# to customize the appearance and content of each row.  It will be given the
# columns property from DataTable and the model for the row.
#
# TODO: Document column object shape
#
# TODO: Document expected model shape
#
# @example: ->
#   class Model extends Backbone.Model
#
#   React.createClass
#
#     getDefaultProps: ->
#       row:  DataTable.Row
#
#     getInitialState: ->
#       models:   (new Model(id: i, name: "Model #{i+1}") for i in [0..299])
#       columns:  [
#         {field: 'id',   label: 'ID'},
#         {
#           field: 'name',
#           label: 'Name',
#           format: ((name) -> "#{name}!"),
#           width: '90%'
#         }
#       ]
#
#     filterByName: (models, term) ->
#       m for m in models when m.get('name').indexOf(term) > -1
#
#     render: ->
#       <DataTable columns      = @state.columns
#                  models       = @state.models
#                  filter       = @filterByName
#                  row          = @props.row
#                  itemsPerPage = 10 />
_           = require 'lodash'
React       = require 'react'
{classSet}  = require('react/addons').addons

Icon  = require '../ui/icon'
Pager = require './paging'
Row   = require './row'


DataTable = React.createClass
  displayName: 'DataTable'

  propTypes:
    columns:         React.PropTypes.arrayOf(React.PropTypes.object).isRequired
    compact:         React.PropTypes.bool
    filter:          React.PropTypes.func
    hover:           React.PropTypes.bool
    itemsPerPage:    React.PropTypes.number
    models:          React.PropTypes.arrayOf(React.PropTypes.object)
    row:             React.PropTypes.func
    striped:         React.PropTypes.bool

  getDefaultProps: ->
    striped:  false
    hover:    true
    compact:  false
    models:   []
    row:      Row

  getInitialState: ->
    pageStart:       0
    itemsPerPage:    @props.itemsPerPage
    sort:            null

  # Sorts by a field name on model and a direction (1 - asc, -1 - desc)
  setSort: (field, dir) ->
    @setState({ sort: [field, dir] })

  onToggleSort: (e) ->
    e.preventDefault()
    field = e.currentTarget.getAttribute('name')
    dir = 1

    if @state.sort? and @state.sort[0] is field
      # switch direction if we were already on this field
      dir = @state.sort[1] * -1

    @setSort field, dir

  onUpdateFilter: (e) ->
    @setState(filterTerm: e.currentTarget.value)

  onRangeChange: (start, end) ->
    @setState(pageStart: start)

  getValid: (models) ->
    if @props.filter? and @state.filterTerm?
      @props.filter(@props.models, @state.filterTerm)
    else
      @props.models

  getVisibleOnPage: (models) ->
    if @props.itemsPerPage?
      start = @state.pageStart
      end   = @state.itemsPerPage + start - 1
      models[start..end]
    else
      models

  getSorted: (models) ->
    if @state.sort?
      sorted = _.clone(models)
      [field, dir] = @state.sort

      sorted.sort (first, second) ->
        if first.get(field) > second.get(field)
          # switch the sign for descending
          1 * dir
        else if first.get(field) < second.get(field)
          -1 * dir
        else
          0

      sorted
    else
      models

  onChangeRecordsPerPage: (count) ->
    @setState(itemsPerPage: count, start: 0)

  render: ->
    hasFilter             = @props.filter?
    hasItemsPerPageSelect = @props.itemsPerPage?

    className = classSet
      'table':            true
      'table-responsive': true
      'table-striped':    @props.striped
      'table-hover':      @props.hover
      'table-condensed':  @props.compact

    valid       = @getValid(@props.models)
    sorted      = @getSorted(valid)
    visible     = @getVisibleOnPage(sorted)
    maxVisible  = 7
    showPager   = valid.length > maxVisible

    <span className='data-table'>
      <div className='row'>
        {@_filter() if hasFilter}

        {if showPager and hasItemsPerPageSelect
          <div className='col-xs-6'>
            <Pager.ItemsPerPageSelect itemsPerPage = @state.itemsPerPage
                                      onChange     = @onChangeRecordsPerPage />
          </div>
        }


      </div>

      <table className={className}>
        {@_header(@props.columns, @state.sort)}
        <tbody>
          {@_row(model) for model in visible}
        </tbody>
      </table>

      {if showPager
        <div>
          <p>
            <Pager count         = valid.length
                   maxVisible    = maxVisible
                   itemsPerPage  = @state.itemsPerPage
                   onRangeChange = @onRangeChange />
          </p>
          <p>
            Showing {@state.pageStart+1} to {@state.pageStart+@props.itemsPerPage} of {valid.length}
          </p>
        </div>
      }
    </span>

  _filter: ->
    <div className='col-xs-6'>
      <input type='text'
             placeholder='Search...'
             onKeyUp=@onUpdateFilter />
    </div>

  _header: (columns, sort) ->
    [sortCol, sortDir] = sort if sort?

    headings = for column in columns
      sortIcon = if sortCol is column.field
        switch sortDir
          when 1 then <Icon name='sort-desc' />
          else <Icon name='sort-asc' />

      style = if column.width?
        {width: column.width, maxWidth: column.width}
      else
        null

      <th onClick   = @onToggleSort
          name      = {column.field}
          key       = {column.field}
          style     = style
          className = 'sortable'>
        {column.label or column.field} {sortIcon}
      </th>

    <thead>
      <tr>{headings}</tr>
    </thead>

  _row: (model) ->
    React.createElement(
      @props.row,
      {
        key: "row-#{model.cid}"
        model: model
        columns: @props.columns })


DataTable.Row = Row


module.exports = DataTable
