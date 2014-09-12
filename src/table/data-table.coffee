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
#         {field: 'name', label: 'Name', format: (name) -> "#{name}!"}
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
React       = require 'react'
{classSet}  = require('react/addons').addons

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

    valid   = @getValid(@props.models)
    visible = @getVisibleOnPage(valid)

    <span>
      <div className='row'>
        {@_filter() if hasFilter}

        {if hasItemsPerPageSelect
          <div className='col-xs-6'>
            <Pager.ItemsPerPageSelect itemsPerPage = @state.itemsPerPage
                                      onChange     = @onChangeRecordsPerPage />
          </div>
        }


      </div>

      <table className={className}>
        {@_header(@props.columns)}
        <tbody>
          {@_row(model) for model in visible}
        </tbody>
      </table>

      <p>
        <Pager count         = valid.length
               maxVisible    = 7
               itemsPerPage  = @state.itemsPerPage
               onRangeChange = @onRangeChange />
        <p>
          Showing {@state.pageStart+1} to {@state.pageStart+@props.itemsPerPage} of {valid.length}
        </p>
      </p>
    </span>

  _filter: ->
    <div className='col-xs-6'>
      <input type='text'
             placeholder='Search...'
             onKeyUp=@onUpdateFilter />
    </div>

  _header: (columns) ->
    headings = for column in columns
      <th key={column.field}>{column.label or column.field}</th>

    <thead>
      <tr>{headings}</tr>
    </thead>

  _row: (model) ->
    @props.row key: "row-#{model.cid}", model: model, columns: @props.columns


DataTable.Row = Row


module.exports = DataTable
