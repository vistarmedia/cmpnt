React = require 'react'

BaseComponents = require './components/base'


Dashboard = React.createClass

  render: ->
    <span>
      <div className='navbar navbar-inverse navbar-fixed-top' role='navigation'>
        <div className='container'>
          <div className='navbar-header'>
            <a className='navbar-brand' href='#'>UI Components</a>
          </div>

          <div className='collapse navbar-collapse'>
            <ul className='nav navbar-nav'>
              <li><a href='#Base'>Base</a></li>
              <li><a href='#Form'>Form</a></li>
              <li><a href='#Table'>Table</a></li>
            </ul>
          </div>
        </div>
      </div>

      <div className='container content'>
        {@components('Base', BaseComponents)}
      </div>
    </span>

  components: (name, cs) ->
    <div className='components'>
      <div className='row'>
        <div className='col-md-12'>
          <a id=name> </a>
          <h1>{name} Components</h1>
        </div>
      </div>
      {c({key: "#{name}-#{i}"}) for c, i in cs}
    </div>

  component: (c) ->




module.exports = Dashboard
