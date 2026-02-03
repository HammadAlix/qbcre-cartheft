Config = {}

Config.carlocations = { -- You can add as many cars as you like.
    { model = GetHashKey('sultan'), coords = vector4(878.04, -594.91, 57.38, 320.69), name = 'Mirror Park' },
    { model = GetHashKey('baller'), coords = vector4(-888.68, -15.69, 43.15, 314.21), name = 'Rockford Hills' },
    { model = GetHashKey('adder'), coords = vector4(292.08, 176.4, 103.71, 67.92), name = 'Vinewood Boulevard' },
    { model = GetHashKey('bfinjection'), coords = vector4(2561.7, 4687.72, 34.11, 71.04), name = 'Grapeseed' },
    { model = GetHashKey('bagger'), coords = vector4(-35.36, -1509.6, 30.79, 145.58), name = 'Forum Drive' }
}

Config.AIcops = true -- If set to true, you will get a wanted level upon entering the car. If set to false the qbcore police will get a notification.

Config.wantedlevel = 2 -- The wanted level that you get upon entering the vehicle. This can 1-5. This only works if Config.AIcops is set to true.

Config.payment = 1000 -- The payment amount that the player will get upon completing the mission.

Config.moneytype = 'cash' -- This can either be cash or bank.

Config.cooldown = 300 -- The amount of seconds between two missions.
