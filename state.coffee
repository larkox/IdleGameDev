class State
    constructor: ->
        @money = 1
        @income = []
        for income_def, index in constants.INCOMES
            @income[index] = {}
            for attribute_name, attribute of income_def
                @income[index][attribute_name] = attribute
        @setup()
    levelUp: (income_id) ->
        if @income[income_id].cost <= @money
            @money -= @income[income_id].cost
            @income[income_id].level += 1
            @income[income_id].cost += @income[income_id].cost * 0.15
            @income[income_id].income += @income[income_id].base_income
            @update(income_id)
            @updateMpS()
    updateMpS: ->
        acum = 0
        for definition in @income
            acum += 32 * definition.income / definition.each
        $("#mps").text(acum.toFixed(2))
    update: (income_id) ->
        $("#income_#{income_id} .level").text(@income[income_id].level)
        $("#income_#{income_id} .income").text(@income[income_id].income.toFixed(2))
        $("#income_#{income_id} .each").text((@income[income_id].each / 32).toFixed(2))
        $("#income_#{income_id} .cost").text(@income[income_id].cost.toFixed(2))
    setup: ->
        for income_def, index in @income
            text = "#{income_def.name}<br />"
            text += "Level: <span class=\"level\">#{income_def.level}</span><br />"
            text += "Income: <span class=\"income\">#{income_def.income}</span><br />"
            text += "Each: <span class=\"each\">#{(income_def.each / 32).toFixed(2)}</span>s<br />"
            text += "Cost: <span class=\"cost\">#{income_def.cost}</span><br />"
            element = $("<div>", {
                "class": "income_box",
                "id": "income_#{index}",
                "width": 200,
                "height": 100,
                "html": text
            })
            element.click(( (state) ->
                -> state.levelUp(parseInt($(this)[0].id.split("_")[1]))
                )(this))
            $("#generalContent").append(element)
