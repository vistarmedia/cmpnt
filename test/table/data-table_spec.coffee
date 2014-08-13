require '../test_case'

React     = require 'react'
Backbone  = require 'backbone'
{expect}  = require 'chai'

DataTable = require '../../src/table/data-table'


class Model extends Backbone.Model


describe 'Data Table', ->

  beforeEach ->
    @models = for i in [0..499]
      new Model(id: i, name: "Model #{i+1}")

    @columns = [
      {field: 'id',   label: 'ID'},
      {field: 'name', label: 'Name'},
    ]

    @_filterImpl = (models, term) -> models
    filter = (models, term) => @_filterImpl(models, term)

    @table = @render <DataTable columns=@columns models=@models filter=filter />

  it 'should render formatted column headers', ->
    el = @render(<DataTable columns=@columns />).getDOMNode()
    headers = el.querySelectorAll('thead > tr > th')
    expect(headers).to.have.length 2

    expect(headers[0]).to.have.textContent 'ID'
    expect(headers[1]).to.have.textContent 'Name'

  # Right now, this defaults to whatever the page defaults to, which is 10
  it 'should limit the number of rendered rows', ->
    el = @table.getDOMNode()
    rows = el.querySelectorAll('tbody > tr')
    expect(rows).to.have.length 10

  it 'should filter rows', ->
    el = @table.getDOMNode()
    @_filterImpl = (models, term) ->
      m for m in models when m.get('name').indexOf(term) > -1

    filterEl = el.querySelector('input[type="text"]')
    filterEl.value = 'Model 10'
    @simulate.keyUp(filterEl)

    rows = el.querySelectorAll('tbody > tr')
    expect(rows).to.have.length 10
    for row in rows
      [idCol, nameCol] = row.childNodes
      name = nameCol.textContent
      expect(name).to.contain 'Model 10'
