class Loop
    constructor: (environment) ->
        @frame_time = 1000/32
    isReady: -> true
    animate: (environment) ->
    onKeyDown: (event, environment) ->
    onKeyUp: (event, environment) ->
    onMouseDown: (event, environment) ->
    onMouseUp: (event, environment) ->
    onMouseMove: (event, environment) ->

class GeneralGameScreenLoop extends Loop
    constructor: (environment, @state) ->
        super(environment)
    animate: (environment) ->
        for key, value of @state.income
            value.left -= 1
            if value.left <= 0
                @state.money += value.income
                value.left = value.each
        $("#money").text(@state.money.toFixed(2))
