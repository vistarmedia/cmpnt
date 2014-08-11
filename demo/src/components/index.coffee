React = require 'react'


Component = React.createClass
  render: ->
    debugger
    <div className='row component'>
      <div className='col-md-8'>
        <h3>{@props.name}</h3>
        <p>{@props.description}</p>
      </div>
      <div className='col-md-4'>
        {@props.children}
      </div>
    </div>


module.exports = Component
