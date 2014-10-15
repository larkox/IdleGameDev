class State
    constructor: (environment) ->
        @money = 0
        @income = {}
        for income_name, income_def of constants.INCOMES
            @income[income_name] = {}
            for attribute_name, attribute of income_def
                @income[income_name][attribute_name] = attribute
    clear: (environment) ->
        environment.clearForeground({
            "x": 0,
            "y": 0,
            "w": environment.width,
            "h": environment.height,
        })
    draw: (environment, screen) ->
        @drawUI(environment)
        @drawContent(environment, screen)
    drawUI: (environment) ->
        environment.drawText(
            @money.toFixed(2),
            constants.UI.money.x,
            constants.UI.money.y
        )
    drawContent: (environment, screen) ->
        switch screen
            when 0
                @drawGeneral(environment)
    drawGeneral: (environment) ->
        {"x": x0, "y": y0} = constants.GENERAL.start
        {w, h} = constants.GENERAL.dimensions
        l = constants.GENERAL.line_height
        x = x0
        y = y0
        for key, value of @income
            environment.drawText(key, x, y)
            environment.drawText("Level: " + value.level, x, y + l)
            environment.drawText("Income: " + value.income, x, y + 2 * l)
            environment.drawText("Each: " + value.each + "s", x, y + 3 * l)
            x += w
            if (x + w) > environment.width
                x = x0
                y = y + h
