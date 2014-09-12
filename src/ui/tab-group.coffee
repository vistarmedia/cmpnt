# @name: Tab Group
#
# @description: Show a header with tabs that can select between some number of
# child views. When a TabGroup lands on the DOM, all tabs will be rendered and
# remain on the DOM and hidden with CSS (so they should not be used for
# high-level navigation).
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
#
#         <TabGroup.Tab label="Forms">
#           <p>
#             Tabs remain on the page. Type something below, and navigate away
#             and back
#           </p>
#           <input type='text' />
#         </TabGroup.Tab>
#       </TabGroup>
React = require 'react'


TabGroup = React.createClass
  displayName: 'TabGroup'

  propTypes:
    active: React.PropTypes.string

  getInitialState: ->
    active: @props.active

  onChange: (label) ->
    @setState(active: label)

  render: ->
    children = (c for c in @props.children when c.props?.label?)
    labels   = (c.props.label for c in children)
    active   = @state.active or labels[0]

    tabs = for tab, i in children
      cls = ['tab-pane']
      if tab.props.label is active
        cls.push 'active'
      <div key=i className={cls.join(' ')}>{tab}</div>

    <span>
      <TabGroup.Header
        active   = active
        labels   = labels
        onChange = @onChange />
      <div className='tab-content'>
        {tabs}
      </div>
    </span>


# Header which renders the labels. When a tab is click, it will invoke the
# onClick handler with the current label
TabGroup.Header = React.createClass
  displayName: 'TabGroup.Header'

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
  displayName: 'TabGroup.Tab'

  propTypes:
    label: React.PropTypes.string.isRequired

  render: -> <span>{@props.children}</span>


module.exports = TabGroup
