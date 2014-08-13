React = require 'react'

Dashboard = require './dashboard'


init = () ->
  window.React = React
  React.renderComponent(<Dashboard />, document.body)


module.exports = init()
