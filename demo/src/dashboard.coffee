React = require 'react'

TabGroup = require '../../src/ui/tab-group'

RunExample = require './run-example'
docs       = require './doc'


docsByGroup = ->
  byGroup = {}

  for doc in docs
    path = doc.path.split('/')
    group = path[0..path.length-2]
    byGroup[group] or= []
    byGroup[group].push(doc)
  byGroup


View = React.createClass
  propTypes:
    view: React.PropTypes.object.isRequired

  render: ->
    rows = for k, v of @props.view.propTypes
      <tr key=k>
        <td>{k}</td>
        <td>{v}</td>
      </tr>

    <div className='col-xs-6 col-md-4'>
      <div className='view'>
        <h4>{@props.view.name} <small>props</small></h4>
        <table className='table'>
          {rows}
        </table>
      </div>
    </div>

Component = React.createClass
  propTypes:
    component: React.PropTypes.object.isRequired

  render: ->
    comp = @props.component

    <span>
      <div className='row'>
        <div className='col-md-12'>
          <h2>{comp.name} <small>{comp.path}</small></h2>
          <p>{comp.description}</p>
        </div>
      </div>

      <div className='row'>
        {<View key=v.name view=v /> for v in comp.views}
      </div>

      <div className='row'>
        <div className='col-md-12'>
          <TabGroup>
            <TabGroup.Tab label='Example'>
              <RunExample code=comp.example func=comp.example_compiled />
            </TabGroup.Tab>
            <TabGroup.Tab label='Source'>
              <p><pre>{comp.source}</pre></p>
            </TabGroup.Tab>
          </TabGroup>
        </div>
      </div>
    </span>

ComponentGroup = React.createClass
  propTypes:
    name:       React.PropTypes.string.isRequired
    components: React.PropTypes.array.isRequired

  render: ->
    <div className='component-group'>
      <div className='row'>
        <div className='col-xs-6 col-md-4'>
          <a id=@props.name></a>
          <h1>{@props.name}</h1>
        </div>
      </div>
      {<Component key=c.path component=c /> for c in @props.components}
    </div>

Dashboard = React.createClass
  getInitialState: ->
    docsByGroup: docsByGroup()

  render: ->
    keys = Object.keys(@state.docsByGroup)
    keys.sort()

    groups = for key in keys
      name       = key
      components = @state.docsByGroup[key]

      <ComponentGroup key=name name=name components=components />

    <div className='container content'>
      {groups}
    </div>


module.exports = Dashboard
