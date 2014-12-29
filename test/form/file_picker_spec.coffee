require '../test_case'

React     = require 'react'
sinon     = require 'sinon'
{expect}  = require 'chai'

FilePicker = require '../../src/form/file_picker'


describe 'File Picker', ->
  it 'should invoke its onChange handler', ->
    onChange = sinon.spy()
    picker   = @render <FilePicker onChange=onChange />
    @simulate.change(picker.refs.fileInput.getDOMNode())

    expect(onChange).to.have.been.called
