require '../test_case'

_        = require 'lodash'
{expect} = require 'chai'

projection = require '../../src/table/projection'


rows = _(_.range(26))
  .shuffle()
  .map (i) -> String.fromCharCode(i + 65)
  .map (name, id) -> {id: id, name: name}


describe '#define', ->

  beforeEach ->
    @rows = rows.value()

  it 'should return a function that will take list: [rows, metadata]' ,->
    func = projection.define 'moose', (rows) -> rows

    expect(func).to.have.length 1
    expect ->
      func([_([]), {}])
    .to.not.throw Error

  describe 'the returned function', ->

    it 'should update metadata object with filtered results length', ->
      ident = (rows) -> rows
      func = projection.define 'moose', ident

      [result, meta] = func([_(@rows), {}])
      expect(meta['moose']).to.equal 26

    it 'should return the filtered result', ->
      rangeOfFive = (rows) -> rows.range(5)
      func = projection.define 'range_of_five', rangeOfFive

      [result, meta] = func([_(@rows), {}])
      expect(meta['range_of_five']).to.equal 5


describe '#compose', ->

  beforeEach ->
    @rows = rows.value()

  it 'should take functions made by `projection.define`', ->
    takeFive  = projection.define 'five', (rows) -> rows.range(5)
    takeFour  = projection.define 'four', (rows) -> rows.range(4)
    takeThree = projection.define 'three', (rows) -> rows.range(3)

    expect ->
      projection.compose(takeFive, takeFour, takeThree)
    .to.not.throw Error

  it 'should return a function that accepts a lodash-wrapped "rows" arg', ->
    takeFive  = projection.define 'five', (rows) -> rows.range(5)
    func = projection.compose(takeFive)

    expect =>
      func(_(@rows))
    .not.to.throw Error

    expect =>
      func(@rows)
    .to.throw Error

  it 'should accumulate metadata and return it with plain JS list', ->
    takeFive  = projection.define 'five', (rows) -> rows.range(5)
    takeFour  = projection.define 'four', (rows) -> rows.range(4)
    takeThree = projection.define 'three', (rows) -> rows.range(3)

    func = projection.compose(takeFive, takeFour, takeThree)
    proj = func(_(@rows))

    expect(proj.value().meta.five).to.equal 5
    expect(proj.value().meta.four).to.equal 4
    expect(proj.value().meta.three).to.equal 3

  it 'should include original total in metadata', ->
    ident  = projection.define 'ident', (rows) -> rows

    func = projection.compose(ident)
    proj = func(_(@rows))

    expect(proj.value().meta.total).to.equal 26


describe 'Range Projection', ->

  beforeEach ->
    @rows = rows.value()

  context 'with no range', ->

    beforeEach ->
      @proj = projection.range(undefined, undefined, rows).value()

    it 'should give all rows', ->
      expect(@proj).to.have.length 26

    it 'should preserve order', ->
      expect(@proj[0]).to.equal @rows[0]
      expect(@proj[25]).to.equal @rows[25]

  context 'with a start index', ->

    beforeEach ->
      @proj = projection.range(10, undefined, rows).value()

    it 'should project the latter rows', ->
      expect(@proj).to.have.length 16
      expect(@proj[0]).to.equal @rows[10]
      expect(@proj[15]).to.equal @rows[25]

  context 'with an end index', ->

    beforeEach ->
      @proj = projection.range(undefined, 15, rows).value()

    it 'should project the former rows', ->
      expect(@proj).to.have.length 16

      expect(@proj[0]).to.equal @rows[0]
      expect(@proj[15]).to.equal @rows[15]
      expect(@proj[16]).to.not.exist

  context 'with a start and end index', ->

    beforeEach ->
      @proj = projection.range(10, 15, rows).value()

    it 'should project the intersecting rows', ->
      expect(@proj).to.have.length 6

      expect(@proj[0]).to.equal @rows[10]
      expect(@proj[5]).to.equal @rows[15]


describe 'Order Projection', ->

  beforeEach ->
    @rows = rows.value()

  context 'with ascending sort', ->

    beforeEach ->
      @proj = projection.order('name', true, rows).value()

    it 'should have small values first and large values last', ->
      expect(@proj[0].name).to.equal 'A'
      expect(@proj[25].name).to.equal 'Z'

  context 'with descending sort', ->

    beforeEach ->
      @proj = projection.order('name', false, rows).value()

    it 'should have large values first and small ones last', ->
      expect(@proj[0].name).to.equal 'Z'
      expect(@proj[25].name).to.equal 'A'

  context 'with an undefined order', ->

    beforeEach ->
      @proj = projection.order('name', undefined, rows).value()

    it 'should sort ascending', ->
      expect(@proj[0].name).to.equal 'A'
      expect(@proj[25].name).to.equal 'Z'

  context 'without a key', ->

    beforeEach ->
      @proj = projection.order(undefined, undefined, rows).value()

    it 'should not sort', ->
      expect(@proj[0]).to.equal @rows[0]
      expect(@proj[25]).to.equal @rows[25]


describe 'Filter Projection', ->

  beforeEach ->
    @rows = rows.value()

  context 'without a filter', ->

    beforeEach ->
      @proj = projection.filter(undefined, rows).value()

    it 'should give all rows', ->
      expect(@proj[0]).to.equal @rows[0]
      expect(@proj[25]).to.equal @rows[25]

  context 'with a filter', ->

    beforeEach ->
      onlyEvens = (row) -> row.id % 2 == 0
      @proj = projection.filter(onlyEvens, rows).value()

    it 'should give filtered rows', ->
      expect(@proj).to.have.length 13
