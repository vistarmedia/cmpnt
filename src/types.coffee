# @name: Types
#
# @description:  A collection of custom prop types.


React      = require 'react'


idName = React.PropTypes.shape
  id:   React.PropTypes.any
  name: React.PropTypes.string


module.exports =
  idName:     idName
  idNameList: React.PropTypes.arrayOf(idName.isRequired)
