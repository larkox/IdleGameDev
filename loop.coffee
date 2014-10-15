class Loop
    constructor: (environment) ->
        @frame_time = 1000/32
    isReady: -> true
    clear: (environment) ->
    animate: (environment) ->
    draw: (environment) ->
    onKeyDown: (event, environment) ->
    onKeyUp: (event, environment) ->
    onMouseDown: (event, environment) ->
    onMouseUp: (event, environment) ->
    onMouseMove: (event, environment) ->

class GeneralGameScreenLoop extends Loop
    constructor: (environment, @state) ->
        super(environment)
        @selected = 0
        @dirty = true
        environment.layers[2].textBaseline = "top";
    animate: (environment) ->
        for key, value of @state.income
            value.left -= 1
            if value.left <= 0
                @state.money += value.income
                value.left = value.each
    draw: (environment) ->
        @state.draw(environment, 0)
    clear: (environment) ->
        if @dirty
            environment.clean()
            @dirty = false
        else
            @state.clear(environment)
