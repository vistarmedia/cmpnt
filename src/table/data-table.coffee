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
# TODO: Document column object shape
#
# TODO: Document expected model shape
#
# @example: ->
#   class Model extends Backbone.Model
#
#   React.createClass
#
#     getInitialState: ->
#       models:   (new Model(id: i, name: "Model #{i+1}") for i in [0..299])
#       columns:  [
#         {field: 'id',   label: 'ID'},
#         {field: 'name', label: 'Name'}
#       ]
#
#     filterByName: (models, term) ->
#       m for m in models when m.get('name').indexOf(term) > -1
#
#     render: ->
#       <DataTable columns      = @state.columns
#                  models       = @state.models
#                  filter       = @filterByName
#                  itemsPerPage = 10 />
React       = require 'react'
{classSet}  = require('react/addons').addons

Pager = require './paging'


DataTable = React.createClass
  displayName: 'DataTable'

  propTypes:
    striped:         React.PropTypes.bool
    hover:           React.PropTypes.bool
    compact:         React.PropTypes.bool
    itemsPerPage:    React.PropTypes.number
    filter:          React.PropTypes.func
    models:          React.PropTypes.arrayOf(React.PropTypes.object)
    columns:         React.PropTypes.arrayOf(React.PropTypes.object).isRequired

  getDefaultProps: ->
    striped:  false
    hover:    true
    compact:  false
    models:   []

  getInitialState: ->
    start:           0
    end:             0
    itemsPerPage:    @props.itemsPerPage
    filteredModels:  @props.models

  onRangeChange: (start, end) ->
    @setState(start: start, end: end)

  getVisibleOnPage: (models) ->
    models[@state.start..@state.end]

  onUpdateFilter: (e) ->
    term     = e.currentTarget.value
    filtered = @props.filter(@props.models, term)
    # TODO: Move to page 0?
    if term is @state.filter then return
    @setState(filteredModels: filtered, filter: term)

  onChangeRecordsPerPage: (count) ->
    @setState
      itemsPerPage:  count
      start:         0
      end:           count - 1

  render: ->
    hasFilter             = @props.filter?
    hasItemsPerPageSelect = @props.itemsPerPage?

    className = classSet
      'table':            true
      'table-responsive': true
      'table-striped':    @props.striped
      'table-hover':      @props.hover
      'table-condensed':  @props.compact

    visible = @getVisibleOnPage(@state.filteredModels)

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
      <div className='row'>
        <table className={className}>
          {@_header(@props.columns)}
          {@_rows(visible)}
        </table>
      </div>
      <div className='row'>
        <Pager count         = @state.filteredModels.length
               maxVisible    = 7
               itemsPerPage  = @state.itemsPerPage
               onRangeChange = @onRangeChange />
        <p>
          Showing {@state.start+1} to {@state.end+1} of {@state.filteredModels.length}
        </p>
      </div>
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

  _rows: (models) ->
    columns = (c.field for c in @props.columns)

    <tbody>
      {@_row(model, columns) for model in models}
    </tbody>

  _row: (model, columns) ->
    columns = for column in columns
      <td key=column>{model.get(column)}</td>
    <tr key=model.cid>{columns}</tr>


module.exports = DataTable
