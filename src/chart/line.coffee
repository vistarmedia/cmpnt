# @name: LineChart
#
# @description: Creates a line chart of the given series.
#
# @example: ->
#   React.createClass
#     render: ->
#       data =
#         labels: ['January', 'February', 'March',
#                  'April', 'May', 'June', 'July']
#         datasets: [
#           {
#             label: 'Rides'
#             data: [65, 59, 80, 81, 56, 55, 40]
#           },
#           {
#             label: 'Runs'
#             data: [28, 48, 40, 19, 86, 27, 90]
#           }
#         ]
#
#       <LineChart data={data} width=500 height=300 />

Chart = require 'chart.js/Chart'
React = require 'react'
_     = require 'lodash'


labelType   = React.PropTypes.node
datasetType = React.PropTypes.shape
  data: React.PropTypes.arrayOf(React.PropTypes.number.isRequired).isRequired
  label:                React.PropTypes.string
  fillColor:            React.PropTypes.string
  strokeColor:          React.PropTypes.string
  pointColor:           React.PropTypes.string
  pointStrokeColor:     React.PropTypes.string
  pointHighlightFill:   React.PropTypes.string
  pointHighlightStroke: React.PropTypes.string

dataType = React.PropTypes.shape
  datasets: React.PropTypes.arrayOf(datasetType.isRequired).isRequired
  labels:   React.PropTypes.arrayOf(labelType.isRequired).isRequired


LineChart = React.createClass
  displayName: 'LineChart'

  propTypes:
    width:    React.PropTypes.number
    height:   React.PropTypes.number
    data:     dataType.isRequired

  getDefaultProps: ->
    width:  600
    height: 300

  dataDefaults:
    fillColor:            'rgba(151,187,205,0.2)'
    strokeColor:          'rgba(151,187,205,1)'
    pointColor:           'rgba(151,187,205,1)'
    pointStrokeColor:     '#fff'
    pointHighlightFill:   '#fff'
    pointHighlightStroke: 'rgba(151,187,205,1)'

  componentDidMount: ->
    # Expand the canvas to the full width of its parent before giving it to
    # the Chart.
    @refs.canvas.getDOMNode().width = @getDOMNode().clientWidth
    @_initChart(@props)

  componentWillUnmount: ->
    @chart?.destroy()

  componentWillReceiveProps: (nextProps) ->
    return if _.isEqual(nextProps.data, @props.data)

    @_initChart(nextProps)
    if @chart?
      for dataset, i in nextProps.data.datasets
        for point, j in dataset.data
          @chart.datasets[i].points[j].value = point
      @chart.update()

  render: ->
    <div className='line-chart'>
      <canvas
        ref    = 'canvas'
        width  = @props.width
        height = @props.height />
    </div>

  # We do all this trickery to hold off on instantiating the chart because
  # chart.js throws errors rendering a line chart without at least one
  # dataset, and we don't want to force that same restriction on users of
  # this component.
  _initChart: (props) ->
    if not @chart? and props.data.datasets.length > 0
      ctx = @refs.canvas.getDOMNode().getContext?('2d')
      if ctx?
        @chart = new Chart(ctx).Line(@_chartData(props), {
          bezierCurve: false
          # Keep height at prop setting.
          maintainAspectRatio: false
          # We actually want to adapt to width changes, but as of 1.0.1 of
          # chart.js, the responsive flag doesn't work with browserify. See
          # https://github.com/nnnick/Chart.js/pull/889 .
          responsive: false
        })
    @chart

  _chartData: (props) ->
    mergedDatasets = for dataset in props.data.datasets
      _.defaults dataset, @dataDefaults

    _.extend { labels: props.data.labels }, { datasets: mergedDatasets }


module.exports = LineChart
