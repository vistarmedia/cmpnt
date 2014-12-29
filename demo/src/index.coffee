React = require 'react'

Dashboard = require './dashboard'


console.warn = (msg) ->
  console.log(msg)
  console.trace()

init = () ->
  window.React = React
  React.render(<Dashboard />, document.body)


module.exports = init()
