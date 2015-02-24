require '../test_case'

React     = require 'react'
sinon     = require 'sinon'
{expect}  = require 'chai'

FilePicker = require '../../src/form/file_picker'
Button     = require '../../src/form/button'


describe 'File Picker', ->
  it 'should invoke its onChange handler', ->
    onChange = sinon.spy()
    picker   = @render <FilePicker onChange=onChange />
    @simulate.change(picker.refs.fileInput.getDOMNode())

    expect(onChange).to.have.been.called

  it 'should pass through btnType', ->
    picker = @render <FilePicker btnType='success' />
    button = @findByType(picker, Button).getDOMNode()
    expect(button.className).to.include 'btn-success'
    expect(button.className).to.not.include 'btn-default'
