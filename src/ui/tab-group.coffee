# @name: Tab Group
#
# @description: Show a header with tabs that can select between some number of
# child views.
#
# @example: ->
#   React.createClass
#     render: ->
#       <TabGroup>
#         <TabGroup.Tab label="Fish">
#           <h2>Fish are cool</h2>
#         </TabGroup.Tab>
#
#         <TabGroup.Tab label="Dogs">
#           <h2>Dogs are cool</h2>
#         </TabGroup.Tab>
#       </TabGroup>
React = require 'react'


TabGroup = React.createClass

  propTypes:
    active: React.PropTypes.string

  getInitialState: ->
    tabs       = (c for c in @props.children when c.props?.label?)
    labels     = (t.props.label for t in tabs)

    tabs:       tabs
    labels:     labels
    active:     @props.active or labels[0]

  onChange: (label) ->
    @setState(active: label)

  render: ->
    tabs = for tab, i in @state.tabs
      cls = ['tab-pane']
      if tab.props.label is @state.active
        cls.push 'active'
      <div key=i className={cls.join(' ')}>{tab}</div>

    <span>
      <TabGroup.Header
        active   = @state.active
        labels   = @state.labels
        onChange = @onChange />
      <div className='tab-content'>
        {tabs}
      </div>
    </span>


# Header which renders the labels. When a tab is click, it will invoke the
# onClick handler with the current label
TabGroup.Header = React.createClass
  propTypes:
    onChange: React.PropTypes.func
    labels:   React.PropTypes.arrayOf(React.PropTypes.string).isRequired
    active:   React.PropTypes.string.isRequired

  componentDidMount: ->
    @props.onChange?(@props.active)

  updateActive: (label) ->
    return if @props.active is label
    @props.onChange?(label)

  render: ->
    labelTabs = for label in @props.labels
      do (label) =>
        clickHandler = (e) =>
          e.preventDefault()
          @updateActive(label)

        <li key={label} className={if label is @props.active then 'active'}>
          <a href="#" onClick=clickHandler>{label}</a>
        </li>
    <ul className='nav nav-tabs'>{labelTabs}</ul>



TabGroup.Tab = React.createClass
  propTypes:
    label: React.PropTypes.string.isRequired

  render: -> <span>{@props.children}</span>


module.exports = TabGroup
