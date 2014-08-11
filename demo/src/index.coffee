React = require 'react'

Dashboard = require './dashboard'


init = () ->
  React.renderComponent(<Dashboard />, document.body)


module.exports = init()
