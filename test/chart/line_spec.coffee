require '../test_case'

React     = require 'react'
_         = require 'lodash'
sinon     = require 'sinon'
{expect}  = require 'chai'

LineChart = require '../../src/chart/line'


describe 'LineChart', ->

  beforeEach ->
    @labels = ['January', 'February', 'March', 'April', 'May', 'June', 'July']
    @datasets = [{
      label: 'Rides'
      data: [65, 59, 80, 81, 56, 55, 40]
    }, {
      label: 'Runs'
      data: [28, 48, 40, 19, 86, 27, 90]
    }]

    @renderChart = =>
      @render <LineChart labels=@labels datasets=@datasets />

  describe 'render', ->

    # Testing this may be tricky, as I don't think domino provides canvas
    # contexts, and the chart won't render without one. A big TODO!
    it.skip 'should test things', ->
