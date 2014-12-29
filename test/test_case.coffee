require './test_dom'

require('chai')
  .use(require('./matchers'))
  .use(require('sinon-chai'))

beforeEach ->
  # We make it so that any warning in a test causes the test to fail
  @_consoleWarn = console.warn
  console.warn = (msg, args...) ->
    console.log(msg, args...)
    throw new Error(msg, args...)

afterEach ->
  console.warn = @_consoleWarn
