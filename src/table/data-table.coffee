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
    striped:      false
    hover:        true
    compact:      false
    models:       []

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
      <div className='row'>
        <table className={className}>
          {@_header(@props.columns)}
          {@_rows(visible)}
        </table>
      </div>
      <div className='row'>
        <Pager count         = valid.length
               maxVisible    = 7
               itemsPerPage  = @state.itemsPerPage
               onRangeChange = @onRangeChange />
        <p>
          Showing {@state.pageStart+1} to {@state.pageStart+@props.itemsPerPage} of {valid.length}
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
