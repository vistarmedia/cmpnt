# @private:
_ = require 'lodash'


module.exports =
  # Gives a "slice" of some rows in the given range. If a "start" value is not
  # given, it will start at the the first value. If an "end" value is not given,
  # it will end at the last value.
  range: (start, end, rows) ->
    idx        = start or 0
    rangeStart = rows.rest(idx)

    if end?
      rangeStart.first(end - idx + 1)
    else
      rangeStart

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
      meta[name] = out.size()
      [out, meta]

  compose: ->
    start = (rows) ->
      [rows, {total: rows.size()}]

    finalize = (r) ->
      [rows, meta] = r
      rows.value().meta = meta
      rows

    _.compose(finalize, arguments..., start)
