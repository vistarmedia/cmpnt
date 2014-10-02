Backbone  = require 'backbone'
React     = require 'react'

DownloadLink = require '../../src/download-link'

LineChart = require '../../src/chart/line'

Button     = require '../../src/form/button'
FilePicker = require '../../src/form/file_picker'

Icon      = require '../../src/ui/icon'
TabGroup  = require '../../src/ui/tab-group'

DataTable = require '../../src/table/data-table'
Pager     = require '../../src/table/paging'


RunExample = React.createClass
  displayName: 'RunExample'

  propTypes:
    code: React.PropTypes.string.isRequired
    func: React.PropTypes.string

  getInitialState: ->
    factory = eval(@props.func)()
    unless factory? then return {}

    component: factory()

  render: ->
    <div className='row'>
      <div className='col-xs-6 col-md-6'>
        <h4>Source</h4>
        <pre className='code'>{@props.code}</pre>
      </div>
      <div className='col-xs-6 col-md-6'>
        <h4>Example</h4>
        <div className='example'>
          <div className='inner'>{@state.component}</div>
        </div>
      </div>
    </div>


module.exports = RunExample
