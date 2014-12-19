# @name: Types
#
# @description:  A collection of custom prop types.


React      = require 'react'


idNode = React.PropTypes.shape
  id:   React.PropTypes.any
  # With react 0.12, renderable will be renamed to "node"
  node: React.PropTypes.renderable


module.exports =
  idNode:     idNode
  idNodeList: React.PropTypes.arrayOf(idNode.isRequired)
