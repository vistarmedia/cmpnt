# @name: Row
#
# @description:  Represents a row within a table.  Might be used within a
# Datatable, shown here used in a regular <table> for example's sake.
#
# The array given to the 'columns' property is an array of model attributes that
# will be rendered, one per cell.
#
# The function given to the 'onClick' property will be called with two
# arguments:  first argument is the triggered event, second argument will be the
# underlying model for that row.
#
# The "format" property can be given an object containing functions to do
# formatting inside each <td> element, keyed by model attribute name.  In our
# example we want each name to link to a cool pix in a new window.
#
# @example: ->
#   class Model extends Backbone.Model
#
#   React.createClass
#     getDefaultProps: ->
#       columns:  ['id', 'name']
#       format:
#         name: (model) ->
#           <a href="http://i.imgur.com/zmGibj5.jpg" target="_blank">
#             {model.get('name')}
#           </a>
#
#     rowClicked: (e, model) ->
#       alert "whoa! clicked racer #{model.get('name')}"
#
#     getInitialState: ->
#       models:   (new Model(id: i, name: "Fred ##{i+1}") for i in [0..10])
#
#     render: ->
#       rows = for model in @state.models
#         <DataTable.Row model = model
#              columns         = @props.columns
#              onClick         = @rowClicked
#              format          = @props.format />
#
#       <table>
#         <tbody>{rows}</tbody>
#       </table>
React = require 'react'


Row = React.createClass
  displayName: 'DataTable::Row'

  propTypes:
    columns: React.PropTypes.array.isRequired
    model:   React.PropTypes.object
    format:  React.PropTypes.object

  getDefaultProps: ->
    format: {}

  _clicked: (event) ->
    @props.onClick?(event, @props.model)

  _formatColumn: (column) ->
    @props.format[column]?(@props.model) or @props.model.get(column)

  render: ->
    columns = for column in @props.columns
      <td key=column>{@_formatColumn(column)}</td>

    <tr key=@props.model.cid onClick=@_clicked>{columns}</tr>


module.exports = Row
