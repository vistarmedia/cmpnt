beforeEach ->
  @daysByIndex = (i, view) ->
    days = view.getDOMNode().querySelectorAll(".week .day:nth-child(#{i})")
    (e.innerHTML for e in days)

  @getByDay = (day, view) ->
    view.getDOMNode().querySelector(".day:contains(#{day})")
