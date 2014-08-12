properties = ['innerHTML', 'textContent', 'tagName', 'className']

module.exports = (chai, utils) ->
  inspect = utils.inspect
  flag    = utils.flag

  _matchProperty = (name) ->
    chai.Assertion.addMethod name, (expected) ->
      value = flag(this, 'object')[name]
      @assert value is expected,
        "expected \#{this} to have #{name}, but got \#{act}",
        "expected \#{this} not have have #{name} \#{exp}",
        expected, value
  _matchProperty(prop) for prop in properties


  chai.Assertion.addMethod 'haveClass', (expected) ->
    classes = flag(this, 'object').className.split /\s+/
    @assert expected in classes,
      "expected \#{this} to have class #{expected}, but got \#{act}",
      "expected \#{this} not have have class #{expected}, found \#{act}",
      expected, classes
