React = require 'react'

Icon     = require '../../src/ui/icon'
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
  displayName: 'View'

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
  displayName: 'Component'

  propTypes:
    component: React.PropTypes.object.isRequired

  render: ->
    comp = @props.component
    description = (<p key=i>{d}</p> for d, i in comp.description.split('\n\n'))
    tabs = []

    if comp.example?
      tabs.push(
        <TabGroup.Tab key='example' label='Example'>
          <RunExample code=comp.example func=comp.example_compiled />
        </TabGroup.Tab>)

    if comp.style?
      tabs.push(
        <TabGroup.Tab key='style' label='Style'>
          <p><pre className='code'>{comp.style}</pre></p>
        </TabGroup.Tab>)

    if comp.source?
      tabs.push(
        <TabGroup.Tab key='source' label='Source'>
          <p><pre className='code'>{comp.source}</pre></p>
        </TabGroup.Tab>)

    <span>
      <div className='row'>
        <div className='col-md-12'>
          <h2>
            <Icon name='cube' />
            {comp.name}
            <small>{comp.path}</small>
          </h2>
          {description}
        </div>
      </div>

      <div className='row'>
        {<View key=v.name view=v /> for v in comp.views}
      </div>

      <div className='row'>
        <div className='col-md-12'>
          <TabGroup>{tabs}</TabGroup>
        </div>
      </div>
    </span>


ComponentGroup = React.createClass
  displayName: 'ComponentGroup'

  propTypes:
    name:       React.PropTypes.string.isRequired
    components: React.PropTypes.array.isRequired

  render: ->
    <div className='component-group'>
      <div className='row'>
        <div className='col-xs-6 col-md-6'>
          <a id=@props.name></a>
          <h1>
            {@props.name}
            <Icon name='cubes' />
          </h1>
        </div>
      </div>
      {<Component key=c.path component=c /> for c in @props.components}
    </div>


Dashboard = React.createClass
  displayName: 'Dashboard'

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
