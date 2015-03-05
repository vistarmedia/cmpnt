# @private:
_ = require 'lodash'


module.exports =
  # Gives a "slice" of some rows in the given range. If a "start" value is not
  # given, it will start at the the first value. If an "end" value is not given,
  # it will end at the last value.
  range: (start, end, rows) ->
    # We don't want to modify if undefined: _.slice assumes 'end of array'
    # if end is undefined, which is what we want
    unless end is undefined
      end = end + 1

    rows.slice(start, end)

  # Orders the rows by an option key and direction. If no key is given, it will
  # leave the rows unsorted. If `asc` is true, it will sort rows ascending with
  # respect to the key, otherwise descending.
  order: (key, asc, rows) ->
    return rows unless key?

    sorted = rows.sortBy(key)
    if asc is false then sorted.reverse() else sorted

  # Filters each row by some function, if given.
  filter: (func, rows) ->
    return rows unless func?

    rows.filter(func)

  define: (name, func) ->
    (r) ->
      [rows, meta] = r
      out = func(rows)
      meta[name] = out.size().value()
      [out, meta]

  compose: ->
    start = (rows) ->
      [rows, {total: rows.size().value()}]

    finalize = (r) ->
      [rows, meta] = r
      rows = rows.value()
      rows.meta = meta
      rows

    _.compose(finalize, arguments..., start)
