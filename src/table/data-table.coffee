# @name: Data Table
#
# @description: A data table which can display some columns for a collection of
# models.
#
# TODO: Document column object shape
# TODO: Document expected model shape
#
# @example: ->
#   class Model extends Backbone.Model
#
#   React.createClass
#
#     getInitialState: ->
#       models:   (new Model(id: i, name: "Model #{i+1}") for i in [0..499])
#       columns:  [
#         {field: 'id',   label: 'ID'},
#         {field: 'name', label: 'Name'}
#       ]
#
#     filterByName: (models, term) ->
#       m for m in models when m.get('name').indexOf(term) > -1
#
#     render: ->
#       <DataTable columns = @state.columns
#                  models  = @state.models
#                  filter  = @filterByName />
React       = require 'react'
{classSet}  = require('react/addons').addons

Pager = require './pager'

DataTable = React.createClass
  propTypes:
    striped:  React.PropTypes.bool
    hover:    React.PropTypes.bool
    compact:  React.PropTypes.bool
    filter:   React.PropTypes.func
    models:   React.PropTypes.arrayOf(React.PropTypes.object)
    columns:  React.PropTypes.arrayOf(React.PropTypes.object).isRequired

  getDefaultProps: ->
    striped:  false
    hover:    true
    compact:  false
    models:   []

  getInitialState: ->
    start:      0
    end:        0
    searchTerm: ''

  onRangeChange: (start, end) ->
    @setState(start: start, end: end)

  onUpdateFilter: (e) ->
    @setState(searchTerm: e.currentTarget.value)

  render: ->
    hasFilter = @props.filter?

    className = classSet
      'table':            true
      'table-responsive': true
      'table-striped':    @props.striped
      'table-hover':      @props.hover
      'table-condensed':  @props.compact

    models = if hasFilter
      @props.filter(@props.models, @state.searchTerm)
    else
      @props.models

    visible = models[@state.start..@state.end]

    <span>
      {@_filter() if hasFilter}
      <div className='row'>
        <table className={className}>
          {@_header(@props.columns)}
          {@_rows(visible)}
        </table>
      </div>
      <div className='row'>
        <Pager count         = models.length
               maxVisible    = 7
               onRangeChange = @onRangeChange />
        <p>
          Showing {@state.start+1} to {@state.end+1} of {@props.models.length}
        </p>
      </div>
    </span>

  _filter: ->
    <div className='row'>
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
