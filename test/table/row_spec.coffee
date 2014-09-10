require '../test_case'
{expect}  = require 'chai'
sinon     = require 'sinon'

Backbone  = require 'backbone'
React     = require 'react'

Row = require '../../src/table/row'


class Model extends Backbone.Model


describe 'DataTable Row', ->

  beforeEach ->
    @model1  = new Model id: 'model-1', name: 'Fredsled Montgomery', age: 45
    @model2  = new Model id: 'model-2', name: 'Fredsled Jenkins', age: 43
    @columns = [
      {field: 'id'},
      {field: 'name'},
      {field: 'age'},
    ]
    @table = @render(
      <table>
        <tbody>
          <Row model   = @model1
               columns = @columns />
          <Row model   = @model2
               columns = @columns />
        </tbody>
      </table>)
    @tableEl = @table.getDOMNode()

  it 'should render the given columns using model properties', ->
    id   = @tableEl.querySelector('td:nth-child(1)').innerHTML
    name = @tableEl.querySelector('td:nth-child(2)').innerHTML
    age  = @tableEl.querySelector('td:nth-child(3)').innerHTML

    expect(id).to.contain   'model-1'
    expect(name).to.contain 'Fredsled Montgomery'
    expect(age).to.contain  '45'

  context 'when using formatters', ->

    it 'should format using formatting function', ->
      @columns[0].format = (id) ->
        <a href="/#/model/#{id}">{id}</a>

      tableWithFormat = @render(
        <table>
          <tbody>
            <Row model=@model1 columns=@columns />
          </tbody>
        </table>)

      link = tableWithFormat.getDOMNode()
        .querySelector('a[href="/#/model/model-1"]')

      expect(link).to.exist

  context 'when clicked', ->

    it 'should call the onClick prop function with the event and the model', ->
      firstRowOnClick  = sinon.spy()
      secondRowOnClick = sinon.spy()
      table = @render(
        <table>
          <tbody>
            <Row model   = @model1
                 columns = @columns
                 onClick = firstRowOnClick />
            <Row model   = @model2
                 columns = @columns
                 onClick = secondRowOnClick />
          </tbody>
        </table>)
      tableEl = table.getDOMNode()

      firstRow  = tableEl.querySelector('tr:nth-child(1)')
      secondRow = tableEl.querySelector('tr:nth-child(2)')

      @simulate.click firstRow
      @simulate.click secondRow

      anEvent = {}
      expect(firstRowOnClick).to.have.been.calledWithMatch anEvent, @model1
      expect(secondRowOnClick).to.have.been.calledWithMatch anEvent, @model2
