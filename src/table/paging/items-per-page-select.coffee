# @name: Pager.ItemsPerPageSelect
#
# @description: a <select> element that allows the user to select how many items
# they'd like to display per page.  The numbers they can select may be passed to
# the perPageOptions property as an array of integers, and the "perPage"
# property is the default number per page.  The function passed to the
# "onChange" property will be called with the integer the user selects.
#
# @example: ->
#   React.createClass
#     getDefaultProps: ->
#       perPageSelectOptions: [5, 10, 15, 20, 25]
#
#     getInitialState: ->
#       itemsPerPageCount: 10
#
#     onChange: (selectedCount) ->
#       alert "#{selectedCount} items per page is *juuuuuust* about right!"
#       @setState(itemsPerPageCount: selectedCount)
#
#     render: ->
#        <Pager.ItemsPerPageSelect onChange       = @onChange
#                                  perPage        = 10
#                                  perPageOptions = @props.perPageSelectOptions
#                                  />


React = require 'react'


ItemsPerPageSelect = React.createClass
  displayName: 'Pager.ItemsPerPageSelect'

  propTypes:
    onChange:        React.PropTypes.func
    perPage:         React.PropTypes.number
    perPageOptions:  React.PropTypes.arrayOf(React.PropTypes.number)

  getDefaultProps: ->
    perPage:         10
    perPageOptions:  [5, 10, 25]

  getInitialState: ->
    perPage: @props.perPage

  onChangeRecordsPerPage: (e) ->
    val = parseInt(e.target.value, 10)
    @setState
      perPage:  val
    @props.onChange?(val)

  render: ->
    options = for i in @props.perPageOptions
      <option key=i value=i>{i}</option>

    <div className='dataTables_length'>
      <label>
        <select onChange=@onChangeRecordsPerPage
                defaultValue=@state.perPage>
          {options}
        </select>
        &nbsp;records per page
      </label>
    </div>


module.exports = ItemsPerPageSelect
