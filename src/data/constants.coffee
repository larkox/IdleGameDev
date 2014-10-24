constants = {
    "KEY_ENTER": 13,
    "KEY_ESC": 27,
    "KEY_LEFT": 37,
    "KEY_UP": 38,
    "KEY_RIGHT": 39,
    "KEY_DOWN": 40,

    "GENERAL": {
        "start": {x: 30, y: 30},
        "dimensions": {"w": 200, "h": 100},
        "line_height": 10,
    },
    "UI": {
        "money": {
            "x": 10,
            "y": 10,
            "w": 100,
            "h": 100,
        },
    },
    "INCOMES": [
        {
            "name": "Freelancing",
            "description": "The best way to start gaining experience is freelancing. Develop small parts for big companies and you can start earning money.",
            "each": 100,
            "cost": 1,
            "base_income": 0.01,
        },
        {
            "name": "Engine tweaks",
            "description": "Engines are huge, and sometimes need to be tweaked. Become a master of engines tweaking the work of people smarter than you.",
            "each": 1000,
            "cost": 5,
            "base_income": 0.5,
        },
        {
            "name": "Web Games",
            "description": "Low risk low gain games. The best for begginers.",
            "each": 5000,
            "cost": 50,
            "base_income": 10,
        },
        {
            "name": "Mobile Games",
            "description": "You can afford buying yourself a phone, so it is time to start developing for these little fiends.",
            "each": 10000,
            "cost": 250,
            "base_income": 140,
        },
        {
            "name": "Mobile Ports",
            "description": "Creativity is a plus, but going on under the wing of the giants is profitable. Start creating small ports for famous games. That's where the money is.",
            "each": 35000,
            "cost": 1700,
            "base_income": 600,
        },
    ],
    "STAFF": [
        {
            "name": "Billy",
            "scope": "everything",
            "description": "Good old Billy. He is not the best, but he can do everything.",
            "base_effect": 0.01,
            "cost": 500,
        },
        {
            "name": "Uncle Tom",
            "scope": [0],
            "description": "He does not like games, but he likes coding. Freelancing is his passion, and he knows how to do it.",
            "base_effect": 0.1,
            "cost": 750,
        },
        {
            "name": "Barbara",
            "scope": [2,3,4],
            "description": "Babs is the most talented artist you know. But that being said, you do not know many artists. Either way, any game looks better with her.",
            "base_effect": 0.1,
            "cost": 1000,
        },
    ],
    "MARKETING": [
        {
            "name": "Games All Around",
            "scope": "everything",
            "description": "Including adds here you may find more jobs from any field",
            "base_effect": 0.99,
            "cost": 500,
        },
        {
            "name": "Code4Money",
            "scope": [0],
            "description": "Everyone love this site. Need a code for sorting your data? Code4Money. Need a code for doing your laundry? Code4Money. Need a code for the security of the next rocket to Mars? Code4Money. There is always a freelancer willing to do program your code.",
            "base_effect": 0.90,
            "cost": 1200,
        },
    ],
}
