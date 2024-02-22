Config                            = {}
Config.DrawDistance               = 15.0
Config.MarkerColor                = { r = 56, g = 197, b = 201 }
Config.MarkerSize                 = { x = 1.5, y = 1.5, z = 1.0 }
Config.Sprite  = 61
Config.Display = 4
Config.Scale   = 1.0
Config.Colour  = 11
Config.ReviveReward               = 1500
Config.AntiCombatLog              = false
Config.LoadIpl                    = false
Config.Locale = 'en'
Config.RespawnToHospitalDelay		= 60000 * 5
Config.EarlyRespawnTimer = 60000*5
Config.EarlyRespawnTimerr = 1000
 
bedNames = {
	'v_med_bed2',
}
 
local second = 1000
local minute = 60 * second
 
-- How much time before auto respawn at hospital
Config.RespawnDelayAfterRPDeath   = 5 * minute
 
Config.EnablePlayerManagement       = true
Config.EnableSocietyOwnedVehicles   = false
 
Config.RemoveWeaponsAfterRPDeath    = false
Config.RemoveCashAfterRPDeath       = false
Config.RemoveItemsAfterRPDeath      = false
 
Config.ShowDeathTimer               = false
 
Config.EarlyRespawn                 = false

Config.EarlyRespawnFine                  = false
Config.EarlyRespawnFineAmount            = 500

Config.Uniforms = {
	REKRUT = {
		hats = {
            male = { drawable = 164,  texture = 0 },
            female = { drawable = -1,  texture = 0 }
        },
        mask = {
            male = { drawable = 198,  texture = 1 },
            female = { drawable = 0,  texture = 0 }
        },
        torso = {
            male = { drawable = 15,  texture = 0 },
            female = { drawable = 4,  texture = 0 }
        },
        jackets = {
            male = { drawable = 394,  texture = 0 },
            female = { drawable = 23,  texture = 0 }
        },
        leg = {
            male = { drawable = 145,  texture = 0 },
            female = { drawable = 41,  texture = 0 }
        },
        bags = {
            male = { drawable = 0,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        scarfAndChains = {
            male = { drawable = 152,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shirt = {
            male = { drawable = 15,  texture = 0 },
            female = { drawable = 15,  texture = 0 }
        },
        bodyArmor = {
            male = { drawable = 5,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shoes = {
            male = { drawable = 69,  texture = 0 },
            female = { drawable = 4,  texture = 1 }
        }
	},
	PIELEGNIARZ = {
		hats = {
            male = { drawable = 164,  texture = 3 },
            female = { drawable = -1,  texture = 0 }
        },
        mask = {
            male = { drawable = 198,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        torso = {
            male = { drawable = 94,  texture = 0 },
            female = { drawable = 4,  texture = 0 }
        },
        jackets = {
            male = { drawable = 394,  texture = 3 },
            female = { drawable = 23,  texture = 0 }
        },
        leg = {
            male = { drawable = 145,  texture = 0 },
            female = { drawable = 41,  texture = 0 }
        },
        bags = {
            male = { drawable = 0,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        scarfAndChains = {
            male = { drawable = 152,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shirt = {
            male = { drawable = 15,  texture = 0 },
            female = { drawable = 15,  texture = 0 }
        },
        bodyArmor = {
            male = { drawable = 5,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shoes = {
            male = { drawable = 69,  texture = 0 },
            female = { drawable = 4,  texture = 1 }
        }
	},
	RATOWNIK_MED = {
		hats = {
            male = { drawable = 164,  texture = 3 },
            female = { drawable = -1,  texture = 0 }
        },
        mask = {
            male = { drawable = 198,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        torso = {
            male = { drawable = 94,  texture = 0 },
            female = { drawable = 4,  texture = 0 }
        },
        jackets = {
            male = { drawable = 394,  texture = 3 },
            female = { drawable = 23,  texture = 0 }
        },
        leg = {
            male = { drawable = 145,  texture = 1 },
            female = { drawable = 41,  texture = 0 }
        },
        bags = {
            male = { drawable = 100,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        scarfAndChains = {
            male = { drawable = 152,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shirt = {
            male = { drawable = 15,  texture = 0 },
            female = { drawable = 15,  texture = 0 }
        },
        bodyArmor = {
            male = { drawable = 5,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shoes = {
            male = { drawable = 69,  texture = 0 },
            female = { drawable = 4,  texture = 1 }
        }
	},
	LEKARZ = {
		hats = {
            male = { drawable = 164,  texture = 1 },
            female = { drawable = -1,  texture = 0 }
        },
        mask = {
            male = { drawable = 198,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        torso = {
            male = { drawable = 85,  texture = 0 },
            female = { drawable = 4,  texture = 0 }
        },
        jackets = {
            male = { drawable = 399,  texture = 0 },
            female = { drawable = 23,  texture = 0 }
        },
        leg = {
            male = { drawable = 144,  texture = 3 },
            female = { drawable = 41,  texture = 0 }
        },
        bags = {
            male = { drawable = 100,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        scarfAndChains = {
            male = { drawable = 152,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shirt = {
            male = { drawable = 189,  texture = 3 },
            female = { drawable = 15,  texture = 0 }
        },
        bodyArmor = {
            male = { drawable = 5,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shoes = {
            male = { drawable = 25,  texture = 0 },
            female = { drawable = 4,  texture = 1 }
        }
	},
	LEKARZ2 = {
		hats = {
            male = { drawable = 164,  texture = 1 },
            female = { drawable = -1,  texture = 0 }
        },
        mask = {
            male = { drawable = 198,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        torso = {
            male = { drawable = 85,  texture = 0 },
            female = { drawable = 4,  texture = 0 }
        },
        jackets = {
            male = { drawable = 399,  texture = 0 },
            female = { drawable = 23,  texture = 0 }
        },
        leg = {
            male = { drawable = 144,  texture = 3 },
            female = { drawable = 41,  texture = 0 }
        },
        bags = {
            male = { drawable = 100,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        scarfAndChains = {
            male = { drawable = 152,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shirt = {
            male = { drawable = 189,  texture = 3 },
            female = { drawable = 15,  texture = 0 }
        },
        bodyArmor = {
            male = { drawable = 5,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shoes = {
            male = { drawable = 25,  texture = 0 },
            female = { drawable = 4,  texture = 1 }
        }
	},
	ZASTEPCA_ORD = {
		hats = {
            male = { drawable = 164,  texture = 10 },
            female = { drawable = -1,  texture = 0 }
        },
        mask = {
            male = { drawable = 198,  texture = 2 },
            female = { drawable = 0,  texture = 0 }
        },
        torso = {
            male = { drawable = 85,  texture = 0 },
            female = { drawable = 4,  texture = 0 }
        },
        jackets = {
            male = { drawable = 399,  texture = 0 },
            female = { drawable = 23,  texture = 0 }
        },
        leg = {
            male = { drawable = 144,  texture = 3 },
            female = { drawable = 41,  texture = 0 }
        },
        bags = {
            male = { drawable = 100,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        scarfAndChains = {
            male = { drawable = 152,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shirt = {
            male = { drawable = 189,  texture = 2 },
            female = { drawable = 15,  texture = 0 }
        },
        bodyArmor = {
            male = { drawable = 5,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shoes = {
            male = { drawable = 25,  texture = 0 },
            female = { drawable = 4,  texture = 1 }
        }
	},
	ORDYNATOR = {
		hats = {
            male = { drawable = 164,  texture = 10 },
            female = { drawable = -1,  texture = 0 }
        },
        mask = {
            male = { drawable = 198,  texture = 2 },
            female = { drawable = 0,  texture = 0 }
        },
        torso = {
            male = { drawable = 85,  texture = 0 },
            female = { drawable = 4,  texture = 0 }
        },
        jackets = {
            male = { drawable = 399,  texture = 0 },
            female = { drawable = 23,  texture = 0 }
        },
        leg = {
            male = { drawable = 144,  texture = 3 },
            female = { drawable = 41,  texture = 0 }
        },
        bags = {
            male = { drawable = 100,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        scarfAndChains = {
            male = { drawable = 152,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shirt = {
            male = { drawable = 189,  texture = 2 },
            female = { drawable = 15,  texture = 0 }
        },
        bodyArmor = {
            male = { drawable = 5,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shoes = {
            male = { drawable = 25,  texture = 0 },
            female = { drawable = 4,  texture = 1 }
        }
	},
	ZASTEPCA_DYR = {
		hats = {
            male = { drawable = 164,  texture = 9 },
            female = { drawable = -1,  texture = 0 }
        },
        mask = {
            male = { drawable = 198,  texture = 2 },
            female = { drawable = 0,  texture = 0 }
        },
        torso = {
            male = { drawable = 85,  texture = 0 },
            female = { drawable = 4,  texture = 0 }
        },
        jackets = {
            male = { drawable = 395,  texture = 6 },
            female = { drawable = 23,  texture = 0 }
        },
        leg = {
            male = { drawable = 129,  texture = 1 },
            female = { drawable = 41,  texture = 0 }
        },
        bags = {
            male = { drawable = 100,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        scarfAndChains = {
            male = { drawable = 152,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shirt = {
            male = { drawable = 190,  texture = 0 },
            female = { drawable = 15,  texture = 0 }
        },
        bodyArmor = {
            male = { drawable = 5,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shoes = {
            male = { drawable = 25,  texture = 0 },
            female = { drawable = 4,  texture = 1 }
        }
	},
	DYREKTOR = {
		hats = {
            male = { drawable = 164,  texture = 9 },
            female = { drawable = -1,  texture = 0 }
        },
        mask = {
            male = { drawable = 198,  texture = 2 },
            female = { drawable = 0,  texture = 0 }
        },
        torso = {
            male = { drawable = 86,  texture = 0 },
            female = { drawable = 4,  texture = 0 }
        },
        jackets = {
            male = { drawable = 399,  texture = 0 },
            female = { drawable = 23,  texture = 0 }
        },
        leg = {
            male = { drawable = 20,  texture = 0 },
            female = { drawable = 41,  texture = 0 }
        },
        bags = {
            male = { drawable = 100,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        scarfAndChains = {
            male = { drawable = 152,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shirt = {
            male = { drawable = 72,  texture = 3 },
            female = { drawable = 15,  texture = 0 }
        },
        bodyArmor = {
            male = { drawable = 5,  texture = 0 },
            female = { drawable = 0,  texture = 0 }
        },
        shoes = {
            male = { drawable = 6,  texture = 0 },
            female = { drawable = 4,  texture = 1 }
        }
	},
}
