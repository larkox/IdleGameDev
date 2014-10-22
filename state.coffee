class State
    constructor: ->
        @money = 1
        @income = []
        for income_def, index in constants.INCOMES
            @income[index] = {}
            for attribute_name, attribute of income_def
                @income[index][attribute_name] = attribute
            @income[index].current_each = Math.ceil(@income[index].each)
            @income[index].powerup = 0
            @income[index].reduction = 1
            @income[index].level = 0
            @income[index].income = 0
            @income[index].left = @income[index].each
        @staff = []
        for staff_def, index in constants.STAFF
            @staff[index] = {}
            for attribute_name, attribute of staff_def
                @staff[index][attribute_name] = attribute
            @staff[index].current = 0
            @staff[index].level = 0
        @marketing = []
        for marketing_def, index in constants.MARKETING
            @marketing[index] = {}
            for attribute_name, attribute of marketing_def
                @marketing[index][attribute_name] = attribute
            @marketing[index].current = 1
            @marketing[index].level = 0
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
                #left = definition.left + definition.current_each * times
                definition.left = Math.min(Number.MAX_VALUE, left)
        environment.money_span.text(@money.toPrecision(4))
        {object, name} = switch environment.current
            when "buttons_incomes" then {"object": @income, "name": "income"}
            when "buttons_staff" then {"object": @staff, "name": "staff"}
            when "buttons_marketing" then {"object": @marketing, "name": "marketing"}
        for definition, index in object
            if @money >= definition.cost
                definition.div.css("background-color", "green")
            else
                definition.div.css("background-color", "red")

    levelUpIncome: (income_id) ->
        if @income[income_id].cost <= @money
            @money -= @income[income_id].cost
            @income[income_id].level += 1
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
        $("span#mps").text(acum.toPrecision(4))

    updateIncome: (income_id) ->
        div = @income[income_id].div
        div.find(".level").text(@income[income_id].level)
        div.find(".income").text((@income[income_id].income * (1 + @income[income_id].powerup)).toPrecision(4))
        div.find(".powerup").text(@income[income_id].powerup.toPrecision(4))
        div.find(".each").text((@income[income_id].current_each / 1000).toPrecision(4))
        div.find(".cost").text(@income[income_id].cost.toPrecision(4))


    updateStaff: (staff_id) ->
        div = @staff[staff_id].div
        div.find(".level").text(@staff[staff_id].level)
        div.find(".current").text(@staff[staff_id].current.toPrecision(4))
        div.find(".cost").text(@staff[staff_id].cost.toPrecision(4))

    updateMarketing: (marketing_id, div) ->
        div = @marketing[marketing_id].div
        div.find(".level").text(@marketing[marketing_id].level)
        div.find(".current").text(@marketing[marketing_id].current.toPrecision(4))
        div.find(".cost").text(@marketing[marketing_id].cost.toPrecision(4))

    setup: ->
        container = $("div#incomes_frame")
        for income_def, index in @income
            text = "#{income_def.name}<br />"
            text += "Level: <span class=\"level\">#{income_def.level}</span><br />"
            text += "Income: <span class=\"income\">#{income_def.income}</span><br />"
            text += "Each: <span class=\"each\">#{(income_def.each / 1000).toPrecision(4)}</span>s<br />"
            text += "Cost: <span class=\"cost\">#{income_def.cost}</span><br />"
            element = $("<div>", {
                "class": "income_box",
                "id": "income_#{index}",
                "width": 200,
                "height": 100,
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
        $("div#income_0").fadeIn(1000)

        container = $("div#staff_frame")
        for staff_def, index in @staff
            text = "#{staff_def.name}<br />"
            text += "Level: <span class=\"level\">#{staff_def.level}</span><br />"
            text += "Description: <span class=\"description\">#{staff_def.description}</span><br />"
            text += "Current: <span class=\"current\">#{(staff_def.current).toPrecision(4)}</span>%<br />"
            text += "Cost: <span class=\"cost\">#{staff_def.cost}</span><br />"
            element = $("<div>", {
                "class": "staff_box",
                "id": "staff_#{index}",
                "width": 200,
                "height": 100,
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
        $("div#staff_0").fadeIn(1000)

        container = $("div#marketing_frame")
        for marketing_def, index in @marketing
            text = "#{marketing_def.name}<br />"
            text += "Level: <span class=\"level\">#{marketing_def.level}</span><br />"
            text += "Description: <span class=\"description\">#{marketing_def.description}</span><br />"
            text += "Current: <span class=\"current\">#{(marketing_def.current).toPrecision(4)}</span>%<br />"
            text += "Cost: <span class=\"cost\">#{marketing_def.cost}</span><br />"
            element = $("<div>", {
                "class": "marketing_box",
                "id": "marketing_#{index}",
                "width": 200,
                "height": 100,
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
        $("div#marketing_0").fadeIn(1000)

