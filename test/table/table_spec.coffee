require '../test_case'

React     = require 'react'
_         = require 'lodash'
sinon     = require 'sinon'
{expect}  = require 'chai'

Table  = require '../../src/table'
Header = Table.Header


describe 'A Table', ->

  beforeEach ->
    # Generate an array of rows in the format.
    #   [{id:9, name: 'AAA'}, {id:42, name: 'BBB'}, ...]
    # Note that the order is randomized, but the ids are monotonic.
    @rows = _(_.range(26))
      .shuffle()
      .map (i) -> String.fromCharCode(i + 65)
      .map (c) -> c + c + c
      .map (name, id) -> {id: id, name: name}
      .value()

    @columns = [
      {field: 'id',     label: 'ID', comparator: null},
      {field: 'name',   label: 'Name'},
      {field: 'other',  label: 'Other', comparator: 'passthis' }
    ]

    @table = @render <Table columns=@columns rows=@rows />

  it 'should call props.onSort when clicking th element', ->
    spy = sinon.spy()
    @table.setProps(onSort: spy)

    headerItems = @allByType @table, Header.Item
    @simulate.click(@findByTag headerItems[1], 'th')

    expect(spy).to.have.been.calledWith 'name', true, undefined

  it 'should pass the comparator if specified', ->
    spy = sinon.spy()
    @table.setProps(onSort: spy)

    headerItems = @allByType @table, Header.Item
    @simulate.click(@findByTag headerItems[2], 'th')

    expect(spy).to.have.been.calledWith 'other', true, 'passthis'

