class Environment
    constructor: ->
        @loop = new GeneralGameScreenLoop(new State(this))
        @loading = true
        @constants = constants
        @keys = {}
        @data = {}
        @time = new Date()
        @sound_context = new AudioContext()
        @current = $("#buttons_incomes")[0].id
        document.onkeydown = (event) => @onKeyDown(event)
        document.onkeyup = (event) => @onKeyUp(event)
        document.onmousedown = (event) => @onMouseDown(event)
        document.onmouseup = (event) => @onMouseUp(event)
        document.onmousemove = (event) => @onMouseMove(event)
        @change_loop = false
        @loop_to_change = ->
        $("div#buttons div").click(@getClickFunction())
        $("div#buttons div").on("touch", @getClickFunction())
        @money_span = $("span#money")
        setTimeout((=> @tick()), @loop.frame_time)
    getClickFunction: ->
        ((environment) ->
            (->
                id = $(this)[0].id
                if id != environment.current
                    switch environment.current
                        when "buttons_incomes" then $("#incomes_frame").slideToggle(1000).queue()
                        when "buttons_staff" then $("#staff_frame").slideToggle(1000).queue()
                        when "buttons_marketing" then $("#marketing_frame").slideToggle(1000).queue()
                    switch id
                        when "buttons_incomes" then $("#incomes_frame").slideToggle(1000).queue()
                        when "buttons_staff" then $("#staff_frame").slideToggle(1000).queue()
                        when "buttons_marketing" then $("#marketing_frame").slideToggle(1000).queue()
                    environment.current = id
            )
        )(this)
    tick: ->
        if @loading
            @loading = !@loop.isReady()
            setTimeout((=> @tick()), @loop.frame_time)
        else
            delta = @time
            @time = new Date()
            delta = @time - delta
            $("#fps").text((1000 / delta).toFixed(2))
            @loop.animate(this, delta)
            if @change_loop
                @loop = @loop_to_change()
                @change_loop = false
            setTimeout((=> @tick()), @loop.frame_time - (new Date() - @time))
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
