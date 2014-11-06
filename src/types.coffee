# @name: Types
#
# @description:  A collection of custom prop types.


React      = require 'react'


nameValue = React.PropTypes.shape
  name:   React.PropTypes.string
  value:  React.PropTypes.string


module.exports =
  nameValue:      nameValue
  nameValueList:  React.PropTypes.arrayOf(nameValue.isRequired)
