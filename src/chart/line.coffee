# @name: LineChart
#
# @description: Creates a line chart of the given series.
#
# @example: ->
#   React.createClass
#     render: ->
#       data =
#         labels: ["January", "February", "March",
#                  "April", "May", "June", "July"],
#         datasets: [
#             {
#                 data: [65, 59, 80, 81, 56, 55, 40]
#             },
#             {
#                 data: [28, 48, 40, 19, 86, 27, 90]
#             }
#         ]
#
#       <LineChart data={data} width=500 height=300 />
React       = require 'react'

Chart = require 'chart.js/Chart'
_     = require 'lodash'


LineChart = React.createClass
  displayName: 'LineChart'

  getDefaultProps: ->
    width: 600
    height: 300
    data: []

  dataDefaults:
    fillColor: "rgba(151,187,205,0.2)"
    strokeColor: "rgba(151,187,205,1)"
    pointColor: "rgba(151,187,205,1)"
    pointStrokeColor: "#fff"
    pointHighlightFill: "#fff"
    pointHighlightStroke: "rgba(151,187,205,1)"

  propTypes:
    width:  React.PropTypes.number
    height: React.PropTypes.number
    data:   React.PropTypes.object

  componentDidMount: ->
    ctx = @refs.chart.getDOMNode().getContext("2d")
    @chart = new Chart(ctx).Line @_chartData(), { bezierCurve: false }

  componentWillUnmount: ->
    @chart.destroy()

  render: ->
    <div className="line-chart">
      <canvas ref="chart" width={@props.width} height={@props.height} />
    </div>

  _chartData: ->
    mergedDatasets = for dataset in @props.data.datasets
      _.defaults dataset, @dataDefaults

    _.extend @props.data, { datasets: mergedDatasets }


module.exports =
  LineChart:  LineChart
