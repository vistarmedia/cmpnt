React = require 'react'

docs  = require './doc'


docsByGroup = ->
  byGroup = {}

  for doc in docs
    path = doc.path.split('/')
    group = path[0..path.length-2]
    byGroup[group] or= []
    byGroup[group].push(doc)
  byGroup


Component = React.createClass
  propTypes:
    component: React.PropTypes.object.isRequired

  render: ->
    comp = @props.component
    console.log comp

    <div className='row'>
      <div className='col-md-12'>
        <h2>{comp.name}</h2>
        <pre>{comp.path}</pre>
        <p>{comp.description}</p>
        <pre>{@props.component}</pre>
      </div>
    </div>

ComponentGroup = React.createClass
  propTypes:
    name:       React.PropTypes.string.isRequired
    components: React.PropTypes.array.isRequired

  render: ->
    <div className='component-group'>
      <div className='row'>
        <div className='col-md-4'>
          <a id=@props.name></a>
          <h1>{@props.name} Components</h1>
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
