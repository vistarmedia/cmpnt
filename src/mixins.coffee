# @name: Mixins
#
# @description:  A collection of shared mixins.


_ = require 'lodash'


DebouncedChange =
  # sets a @debouncedChange var that is the debounced version of props.onChange

  componentDidMount: ->
    # we're using lodash's `runInContext` here so our tests using sinon's fake
    # timers work correctly
    _ = _.runInContext 'Date': Date
    if @props.onChange
      @debouncedChange = _.debounce @props.onChange, 250,
        leading: true, trailing: false


OnOutsideBlur =
  # expects a `_onOutsideBlur` function to be implemented in the component,  It
  # will only be called if a blur event occurs outside of our branch of the DOM
  # example:
  # OurComponent = React.createClass
  #   render: ->
  #     <div onBlur=@handleOutsideBlur>
  #       Honk
  #     </div>
  #
  #   _onOutsideBlur: (e) ->
  #     # only called if blurred outside branch

  handleOutsideBlur: (e) ->
    if not @_onOutsideBlur
      throw new Error('expected _onOutsideBlur to be implemented')
    if not e.currentTarget.contains(e.relatedTarget)
      @_onOutsideBlur(e)

module.exports = {
  DebouncedChange
  OnOutsideBlur
}
