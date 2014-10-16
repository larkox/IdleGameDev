class Environment
    constructor: ->
        @loop = new GeneralGameScreenLoop(this, new State(this))
        @loading = true
        @constants = constants
        @keys = {}
        @data = {}
        @sound_context = new AudioContext()
        document.onkeydown = (event) => @onKeyDown(event)
        document.onkeyup = (event) => @onKeyUp(event)
        document.onmousedown = (event) => @onMouseDown(event)
        document.onmouseup = (event) => @onMouseUp(event)
        document.onmousemove = (event) => @onMouseMove(event)
        setTimeout((=> @tick()), @loop.frame_time)
        @change_loop = false
        @loop_to_change = ->
    tick: ->
        if @loading
            @loading = !@loop.isReady()
            setTimeout((=> @tick()), @loop.frame_time)
        else
            @loop.animate(this)
            if @change_loop
                @loop = @loop_to_change()
                @change_loop = false
            setTimeout((=> @tick()), @loop.frame_time)
    onKeyDown: (event) ->
        if !@loading
            @keys[event.keyCode] = true
            @loop.onKeyDown(event, this)
    onKeyUp: (event) ->
        if !@loading
            @keys[event.keyCode] = false
            @loop.onKeyUp(event, this)
    onMouseDown: (event) ->
        if !@loading
            @loop.onMouseDown(event, this)
    onMouseUp: (event) ->
        if !@loading
            @loop.onMouseUp(event, this)
    onMouseMove: (event) ->
        if !@loading
            @loop.onMouseMove(event, this)
