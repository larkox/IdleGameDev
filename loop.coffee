class Loop
    constructor: () ->
        @frame_time = 1000/32
    isReady: -> true
    animate: () ->
    onKeyDown: (event, environment) ->
    onKeyUp: (event, environment) ->
    onMouseDown: (event, environment) ->
    onMouseUp: (event, environment) ->
    onMouseMove: (event, environment) ->

class GeneralGameScreenLoop extends Loop
    constructor: (@state) ->
        super()
    animate: (environment, delta) ->
        @state.animate(environment, delta)
