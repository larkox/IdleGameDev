class State
    constructor: ->
        @money = 1
        @income = []
        for income_def, index in constants.INCOMES
            @income[index] = {}
            for attribute_name, attribute of income_def
                @income[index][attribute_name] = attribute
            @income[index].powerup = 0
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
        @setup()
    animate: (environment, delta) ->
        for definition, index in @income
            definition.left -= delta
            if definition.left <= 0
                @money += definition.income * (1 + definition.powerup) * -(definition.left // definition.each)
                definition.left += definition.each * -(definition.left // definition.each)
        $("span#money").text(@money.toFixed(2))
        {object, name} = switch environment.current
            when "buttons_incomes" then {"object": @income, "name": "income"}
            when "buttons_staff" then {"object": @staff, "name": "staff"}
        for definition, index in object
            if @money >= definition.cost
                $("div##{name}_#{index}").css("background-color", "green")
            else
                $("div##{name}_#{index}").css("background-color", "red")
    levelUpIncome: (income_id) ->
        if @income[income_id].cost <= @money
            @money -= @income[income_id].cost
            @income[income_id].level += 1
            @income[income_id].cost += @income[income_id].cost * 0.15
            @income[income_id].income += @income[income_id].base_income
            @updateIncome(income_id)
            @updateMpS()
            if @income[income_id].level == 1 and @income.length > income_id
                $("div#income_#{income_id + 1}").fadeIn(1000)
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
            if @staff[staff_id].level == 1 and @staff.length > staff_id
                $("div#staff_#{staff_id + 1}").fadeIn(1000)
    updateMpS: ->
        acum = 0
        for definition in @income
            acum += definition.income * (1 + definition.powerup) / definition.each
        $("span#mps").text((acum * 1000).toFixed(2))
    updateIncome: (income_id) ->
        $("div#income_#{income_id} .level").text(@income[income_id].level)
        $("div#income_#{income_id} .income").text((@income[income_id].income * (1 + @income[income_id].powerup)).toFixed(2))
        $("div#income_#{income_id} .powerup").text(@income[income_id].powerup.toFixed(2))
        $("div#income_#{income_id} .each").text((@income[income_id].each / 1000).toFixed(2))
        $("div#income_#{income_id} .cost").text(@income[income_id].cost.toFixed(2))
    updateStaff: (staff_id) ->
        $("div#staff_#{staff_id} .level").text(@staff[staff_id].level)
        $("div#staff_#{staff_id} .current").text(@staff[staff_id].current)
        $("div#staff_#{staff_id} .cost").text(@staff[staff_id].cost.toFixed(2))
    setup: ->
        for income_def, index in @income
            text = "#{income_def.name}<br />"
            text += "Level: <span class=\"level\">#{income_def.level}</span><br />"
            text += "Income: <span class=\"income\">#{income_def.income}</span><br />"
            text += "Each: <span class=\"each\">#{(income_def.each / 1000).toFixed(2)}</span>s<br />"
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
            $("div#incomes_frame").append(element)
        $("div#income_0").fadeIn(1000)
        for staff_def, index in @staff
            text = "#{staff_def.name}<br />"
            text += "Level: <span class=\"level\">#{staff_def.level}</span><br />"
            text += "Description: <span class=\"description\">#{staff_def.description}</span><br />"
            text += "Current: <span class=\"current\">#{(staff_def.current).toFixed(2)}</span>s<br />"
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
            $("div#staff_frame").append(element)
        $("div#staff_0").fadeIn(1000)
