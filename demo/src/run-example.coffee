Backbone  = require 'backbone'
React     = require 'react'
_         = require 'lodash'

DownloadLink = require '../../src/download-link'

LineChart = require '../../src/chart/line'

Button     = require '../../src/form/button'
FilePicker = require '../../src/form/file_picker'

LoginLayout = require '../../src/layout/login'

Icon      = require '../../src/ui/icon'
Pill      = require '../../src/ui/pill'
PillGroup = require '../../src/ui/pill/group'
TabGroup  = require '../../src/ui/tab-group'

Multiselect  = require '../../src/select/multi'
SelectFilter = require '../../src/select/filter'
SelectList   = require '../../src/select/list'

CollapsibleListPanel  = require '../../src/ui/collapsible-list-panel'
RangeSelector         = require '../../src/ui/range-selector'

DataTable   = require '../../src/table/data-table'
ObjectTable = require '../../src/table/object-table'
Pager       = require '../../src/table/paging'
Table       = require '../../src/table'

SourceSink = require '../../src/views/source_sink'

Login = require '../../src/login'


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
        <pre className='code'>
          <code className='coffeescript'>
            {@props.code}
          </code>
        </pre>
      </div>
      <div className='col-xs-6 col-md-6'>
        <h4>Example</h4>
        <div className='example'>
          <div className='inner'>{@state.component}</div>
        </div>
      </div>
    </div>


module.exports = RunExample
