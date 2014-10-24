class State
    constructor: ->
        if localStorage.money?
            @money = JSON.parse(localStorage.money)
        else
            @money = 1
        if localStorage.levels?
            @levels = JSON.parse(localStorage.levels)
            load = true
        else
            @levels = {}
            @levels.version = 1
            @levels.income = []
            @levels.staff = []
            @levels.marketing = []
            load = false
        @income = []
        for income_def, index in constants.INCOMES
            @income[index] = {}
            for attribute_name, attribute of income_def
                @income[index][attribute_name] = attribute
            @initIncome(index, load)
        @staff = []
        for staff_def, index in constants.STAFF
            @staff[index] = {}
            for attribute_name, attribute of staff_def
                @staff[index][attribute_name] = attribute
            @initStaff(index, load)
        @marketing = []
        for marketing_def, index in constants.MARKETING
            @marketing[index] = {}
            for attribute_name, attribute of marketing_def
                @marketing[index][attribute_name] = attribute
            @initMarketing(index, load)
        @setup()


    animate: (environment, delta) ->
        for definition, index in @income
            definition.left -= delta
            if definition.left <= 0
                times = Math.min(Number.MAX_VALUE, -(definition.left // definition.current_each))
                quantity = Math.min(Number.MAX_VALUE, definition.income * (1 + definition.powerup))
                @money = Math.min(Number.MAX_VALUE, @money + times*quantity)
                left = definition.left %% definition.current_each
                if left == 0 then left = definition.current_each
                definition.left = Math.min(Number.MAX_VALUE, left)
        environment.money_span.text(writeNumber(@money))
        {object, name} = switch environment.current
            when "buttons_incomes" then {"object": @income, "name": "income"}
            when "buttons_staff" then {"object": @staff, "name": "staff"}
            when "buttons_marketing" then {"object": @marketing, "name": "marketing"}
        for definition, index in object
            if @money >= definition.cost
                definition.div.css("background-color", "green")
                definition.div.css("color", "black")
            else
                definition.div.css("background-color", "red")
                definition.div.css("color", "white")

    levelUpIncome: (income_id) ->
        if @income[income_id].cost <= @money
            @money -= @income[income_id].cost
            @income[income_id].level += 1
            @levels.income[income_id] += 1
            @income[income_id].cost += @income[income_id].cost * 0.15
            @income[income_id].income += @income[income_id].base_income
            @updateIncome(income_id)
            @updateMpS()
            if @income[income_id].level == 1 and @income.length > income_id + 1
                @income[income_id + 1].div.fadeIn(1000)

    levelUpStaff: (staff_id) ->
        if @staff[staff_id].cost <= @money
            @money -= @staff[staff_id].cost
            @staff[staff_id].level += 1
            @levels.staff[staff_id] += 1
            @staff[staff_id].cost += @staff[staff_id].cost * 0.50
            @staff[staff_id].current += @staff[staff_id].base_effect
            if @staff[staff_id].scope == "everything"
                for income, index in @income
                    income.powerup += @staff[staff_id].base_effect
                    @updateIncome(index)
            @updateStaff(staff_id)
            @updateMpS()
            if @staff[staff_id].level == 1 and @staff.length > staff_id + 1
                @staff[staff_id + 1].div.fadeIn(1000)

    levelUpMarketing: (marketing_id) ->
        if @marketing[marketing_id].cost <= @money
            @money -= @marketing[marketing_id].cost
            @marketing[marketing_id].level += 1
            @levels.marketing[marketing_id] += 1
            @marketing[marketing_id].cost += @marketing[marketing_id].cost * 1.00
            @marketing[marketing_id].current = @marketing[marketing_id].current * @marketing[marketing_id].base_effect
            if @marketing[marketing_id].scope == "everything"
                for income, index in @income
                    income.reduction = income.reduction * @marketing[marketing_id].base_effect
                    income.current_each = Math.ceil(income.each * income.reduction)
                    if income.current_each == 0 then income.current_each = Number.MIN_VALUE
                    @updateIncome(index)
            @updateMarketing(marketing_id)
            @updateMpS()
            if @marketing[marketing_id].level == 1 and @marketing.length > marketing_id + 1
                @marketing[marketing_id + 1].div.fadeIn(1000)

    updateMpS: ->
        acum = 0
        for definition in @income
            acum += definition.income * (1 + definition.powerup) / definition.current_each
        acum = Math.min(Number.MAX_VALUE, acum * 1000)
        $("span#mps").text(writeNumber(acum))

    updateIncome: (income_id) ->
        div = @income[income_id].div
        div.find(".level").text(@income[income_id].level)
        div.find(".income").text(writeNumber(@income[income_id].income * (1 + @income[income_id].powerup)))
        div.find(".powerup").text(writeNumber(@income[income_id].powerup))
        div.find(".each").text(writeNumber(@income[income_id].current_each / 1000))
        div.find(".cost").text(writeNumber(@income[income_id].cost))


    updateStaff: (staff_id) ->
        div = @staff[staff_id].div
        div.find(".level").text(@staff[staff_id].level)
        div.find(".current").text(writeNumber(@staff[staff_id].current))
        div.find(".cost").text(writeNumber(@staff[staff_id].cost))

    updateMarketing: (marketing_id, div) ->
        div = @marketing[marketing_id].div
        div.find(".level").text(@marketing[marketing_id].level)
        div.find(".current").text(writeNumber(@marketing[marketing_id].current))
        div.find(".cost").text(writeNumber(@marketing[marketing_id].cost))

    setup: ->
        container = $("div#incomes_frame")
        for income_def, index in @income
            text = "#{income_def.name}<br />"
            text += "Level: <span class=\"level\">#{income_def.level}</span><br />"
            text += "Income: <span class=\"income\">#{writeNumber(income_def.income)}</span><br />"
            text += "Each: <span class=\"each\">#{writeNumber(income_def.each / 1000)}</span>s<br />"
            text += "Cost: <span class=\"cost\">#{writeNumber(income_def.cost)}</span><br />"
            element = $("<div>", {
                "class": "income_box",
                "id": "income_#{index}",
                "title": income_def.description,
                "html": text,
                "hidden": "hidden",
            })
            element.click(( (state) ->
                -> state.levelUpIncome(parseInt($(this)[0].id.split("_")[1]))
                )(this))
            element.on("tap", ( (state) ->
                -> state.levelUpIncome(parseInt($(this)[0].id.split("_")[1]))
                )(this))
            income_def.div = element
            container.append(element)
            if income_def.level > 0 or index == 0 or index > 0 and @income[index - 1].level > 0
                income_def.div.fadeIn(1000)
        container = $("div#staff_frame")
        for staff_def, index in @staff
            text = "#{staff_def.name}<br />"
            text += "Level: <span class=\"level\">#{staff_def.level}</span><br />"
            if staff_def.scope == "everything"
                scope = "everything"
            else
                scope = ""
                for income, index in staff_def.scope
                    scope += @income[income].name
                    unless index == staff_def.scope.length - 1 then scope += ", "

            text += "Scope: <span class=\"scope\">#{scope}</span><br />"
            text += "Current: <span class=\"current\">#{writeNumber(staff_def.current)}</span>%<br />"
            text += "Cost: <span class=\"cost\">#{writeNumber(staff_def.cost)}</span><br />"
            element = $("<div>", {
                "class": "staff_box",
                "id": "staff_#{index}",
                "title": staff_def.description,
                "html": text,
                "hidden": "hidden",
            })
            element.click(( (state) ->
                -> state.levelUpStaff(parseInt($(this)[0].id.split("_")[1]))
                )(this))
            element.on("tap", ( (state) ->
                -> state.levelUpStaff(parseInt($(this)[0].id.split("_")[1]))
                )(this))
            staff_def.div = element
            container.append(element)
            if staff_def.level > 0 or index == 0 or index > 0 and @staff[index - 1].level > 0
                staff_def.div.fadeIn(1000)

        container = $("div#marketing_frame")
        for marketing_def, index in @marketing
            text = "#{marketing_def.name}<br />"
            text += "Level: <span class=\"level\">#{marketing_def.level}</span><br />"
            if marketing_def.scope == "everything"
                scope = "everything"
            else
                scope = ""
                for income, index in marketing_def.scope
                    scope += @income[income].name
                    unless index == marketing_def.scope.length - 1 then scope += ", "
            text += "Scope: <span class=\"scope\">#{scope}</span><br />"
            text += "Current: <span class=\"current\">#{writeNumber(marketing_def.current)}</span>%<br />"
            text += "Cost: <span class=\"cost\">#{writeNumber(marketing_def.cost)}</span><br />"
            element = $("<div>", {
                "class": "marketing_box",
                "id": "marketing_#{index}",
                "title": marketing_def.description,
                "html": text,
                "hidden": "hidden",
            })
            element.click(( (state) ->
                -> state.levelUpMarketing(parseInt($(this)[0].id.split("_")[1]))
                )(this))
            element.on("tap", ( (state) ->
                -> state.levelUpMarketing(parseInt($(this)[0].id.split("_")[1]))
                )(this))
            marketing_def.div = element
            container.append(element)
            if marketing_def.level > 0 or index == 0 or index > 0 and @marketing[index - 1].level > 0
                marketing_def.div.fadeIn(1000)
    initIncome: (index, load) ->
        if load
            if @levels.version == 1
                @income[index].level = @levels.income[index]
                @income[index].income = @income[index].level * @income[index].base_income
                @income[index].cost = @income[index].cost * (1.15 ** @income[index].level)
                @income[index].current_each = Math.ceil(@income[index].each)
                @income[index].left = @income[index].current_each
                @income[index].powerup = 0
                @income[index].reduction = 1
        else
            @income[index].level = 0
            @levels.income[index] = 0
            @income[index].income = 0
            @income[index].current_each = Math.ceil(@income[index].each)
            @income[index].left = @income[index].current_each
            @income[index].powerup = 0
            @income[index].reduction = 1
    initStaff: (index, load) ->
        if load
            if @levels.version == 1
                @staff[index].level = @levels.staff[index]
                @staff[index].cost = @staff[index].cost * (1.50 ** @staff[index].level)
                @staff[index].current = @staff[index].base_effect * @staff[index].level
                if @staff[index].scope == "everything"
                    for income in @income
                        income.powerup += @staff[index].base_effect
        else
            @staff[index].current = 0
            @staff[index].level = 0
            @levels.staff[index] = 0
    initMarketing: (index, load) ->
        if load
            if @levels.version == 1
                @marketing[index].level = @levels.marketing[index]
                @marketing[index].cost = @marketing[index].cost * (2 ** @marketing[index].level)
                @marketing[index].current = 1 * (@marketing[index].base_effect ** @marketing[index].level)
                if @marketing[index].scope == "everything"
                    for income in @income
                        income.reduction = income.reduction * @marketing[index].current
                        income.current_each = Math.ceil(income.each * income.reduction)
                        if income.current_each == 0 then income.current_each = Number.MIN_VALUE
        else
             @marketing[index].level = 0
             @levels.marketing[index] = 0
             @marketing[index].current = 0

writeNumber = (number) ->
    unit = 0
    while number > 1000 or unit == 8
        number = number / 1000
        unit += 1
    expr = switch unit
        when 0 then ""
        when 1 then "k"
        when 2 then "M"
        when 3 then "G"
        when 4 then "T"
        when 5 then "P"
        when 6 then "E"
        when 7 then "Z"
        when 8 then "Y"
    number.toFixed(2) + expr
