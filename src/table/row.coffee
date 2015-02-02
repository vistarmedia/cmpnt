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
#   sicklinkify = (name, model) ->
#     <a href="http://i.imgur.com/zmGibj5.jpg" target="_blank">{name}</a>
#
#   React.createClass
#     getDefaultProps: ->
#       columns:  [
#         {field: 'id'},
#         {field: 'name', format: sicklinkify}
#       ]
#
#     rowClicked: (e, model) ->
#       alert "whoa! clicked racer #{model.get('name')}"
#
#     getInitialState: ->
#       models:   (new Model(id: i, name: "Fred ##{i+1}") for i in [0..10])
#
#     render: ->
#       rows = for model in @state.models
#         <DataTable.Row key=model.cid
#              model    = model
#              columns  = @props.columns
#              onClick  = @rowClicked />
#
#       <table>
#         <tbody>{rows}</tbody>
#       </table>
React = require 'react'


Row = React.createClass
  displayName: 'DataTable.Row'

  propTypes:
    columns:  React.PropTypes.array.isRequired
    model:    React.PropTypes.object.isRequired
    onClick:  React.PropTypes.func

  _clicked: (event) ->
    @props.onClick?(event, @props.model)

  render: ->
    model = @props.model

    columns = for column in @props.columns
      value  = model.get(column.field)
      format = column.format
      label  = if format? then format(value, model) else value

      <td key=column.field>{label}</td>

    <tr key=model.cid onClick=@_clicked>{columns}</tr>


module.exports = Row
