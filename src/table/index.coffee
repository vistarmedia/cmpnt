# @name: table
# @private:


React      = require 'react'
_          = require 'lodash'
{classSet} = require('react/addons').addons

Icon       = require '../ui/icon'


ColumnType  = React.PropTypes.object
ColumnsType = React.PropTypes.arrayOf(ColumnType)
RowType     = React.PropTypes.object
RowsType    = React.PropTypes.arrayOf(RowType)


HeaderItem = React.createClass
  displayName: 'HeaderItem'

  propTypes:
    column:   ColumnType.isRequired
    onClick:  React.PropTypes.func
    sortAsc:  React.PropTypes.bool

  handleClick: (e) ->
    e.preventDefault()
    @props.onClick?(@props.column)

  render: ->
    sortable    = @props.column.comparator != null
    label       = @props.column.label or @props.column.field
    className   = classSet(sortable: sortable)
    handleClick = if sortable then @handleClick
    style = if @props.column.width?
      {width: @props.column.width, maxWidth: @props.column.width}

    icon = if @props.sortAsc?
      name = if @props.sortAsc then 'sort-asc' else 'sort-desc'
      <div className='pull-right'><Icon name=name /></div>

    <th className=className onClick=handleClick style=style>
      {label}{icon}
    </th>


Header = React.createClass
  displayName: 'Header'

  propTypes:
    columns: ColumnsType.isRequired
    onClick: React.PropTypes.func
    sortKey: React.PropTypes.string
    sortAsc: React.PropTypes.bool

  getDefaultProps: ->
    sortAsc: true

  render: ->
    heads = for col, i in @props.columns
      sortAsc = if col.field is @props.sortKey then @props.sortAsc
      <HeaderItem key=i column=col onClick=@props.onClick sortAsc=sortAsc />

    <thead className='table-header'>
      <tr>{heads}</tr>
    </thead>


Row = React.createClass
  displayName: 'Row'

  propTypes:
    columns:     ColumnsType.isRequired
    row:         RowType.isRequired
    isSelected:  React.PropTypes.bool

  render: ->
    row = @props.row

    cells = for col in @props.columns
      value = row[col.field]
      label = if col.format? then col.format(value, row) else value
      <td key=col.field>{label}</td>

    classes = classSet({
      'table-row':  true
      'selected':   @props.isSelected
    })

    <tr className=classes>{cells}</tr>


Body = React.createClass
  displayName: 'Body'

  propTypes:
    columns:       ColumnsType.isRequired
    rows:          RowsType.isRequired
    keyField:      React.PropTypes.string.isRequired
    rowClass:      React.PropTypes.func
    selectedRows:  React.PropTypes.array

  getDefaultProps: ->
    rowClass: Row

  render: ->
    key     = @props.keyField
    columns = @props.columns

    rows = for row in @props.rows
      rowId = row[key]
      React.createElement @props.rowClass,
        key:         rowId
        columns:     columns
        row:         row
        isSelected:  rowId in @props.selectedRows if @props.selectedRows

    <tbody className='table-body'>{rows}</tbody>


Table = React.createClass
  displayName: 'Table'

  propTypes:
    columns:       ColumnsType.isRequired
    rows:          RowsType.isRequired
    keyField:      React.PropTypes.string
    rowClass:      React.PropTypes.func
    selectedRows:  React.PropTypes.array

    start:    React.PropTypes.number
    end:      React.PropTypes.number

    sortKey:  React.PropTypes.string
    sortAsc:  React.PropTypes.bool

    filter:   React.PropTypes.func
    onSort:   React.PropTypes.func

  getDefaultProps: ->
    keyField: 'id'
    start:    0
    sortAsc:  true

  handleClickHeader: (col) ->
    asc = not (@props.sortKey is col.field and @props.sortAsc)
    @props.onSort?(col.field, asc, col.comparator)

  render: ->
    <table className='table data-table'>
      <Header
        columns = @props.columns
        onClick = @handleClickHeader
        sortKey = @props.sortKey
        sortAsc = @props.sortAsc />
      <Body
        columns      = @props.columns
        rows         = @props.rows
        keyField     = @props.keyField
        rowClass     = @props.rowClass
        selectedRows = @props.selectedRows />
    </table>


Header.Item  = HeaderItem
Table.Body   = Body
Table.Header = Header

module.exports = Table
