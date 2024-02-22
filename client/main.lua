local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData				= {}
local FirstSpawn				= true
local IsDead					= false
local TimerThreadId	   = nil
local DistressThreadId	= nil
local HasAlreadyEnteredMarker	= false
local LastZone					= nil
local CurrentAction				= nil
local obezwladniony = false
local CurrentActionMsg			= ''
local CurrentActionData			= {}
local IsBusy					= false
local blockShooting = GetGameTimer()
local CurrentTask = {}
local Melee = { `WEAPON_UNARMED`, `WEAPON_KNUCKLE`, `WEAPON_BAT`, `WEAPON_FLASHLIGHT`, `WEAPON_HAMMER`, `WEAPON_CROWBAR`, `WEAPON_PIPEWRENCH`, `WEAPON_NIGHTSTICK`, `WEAPON_GOLFCLUB`, `WEAPON_WRENCH` }
local Knife = { `WEAPON_KNIFE`, `WEAPON_DAGGER`, `WEAPON_MACHETE`, `WEAPON_HATCHET`, `WEAPON_SWITCHBLADE`, `WEAPON_BATTLEAXE`, `WEAPON_BATTLEAXE`, `WEAPON_STONE_HATCHET` }
local Bullet = { `WEAPON_SNSPISTOL`, `WEAPON_SNSPISTOL_MK2`, `WEAPON_PISTOL50`, `WEAPON_VINTAGEPISTOL`, `WEAPON_PISTOL`, `WEAPON_MILITARYRIFLE`, `WEAPON_PISTOL_MK2`, `WEAPON_GADGETPISTOL`, `WEAPON_DOUBLEACTION`, `WEAPON_COMBATPISTOL`, `WEAPON_HEAVYPISTOL`, `WEAPON_DBSHOTGUN`, `WEAPON_SAWNOFFSHOTGUN`, `WEAPON_PUMPSHOTGUN`, `WEAPON_PUMPSHOTGUN_MK2`, `WEAPON_BULLPUPSHOTGUN`, `WEAPON_MICROSMG`, `WEAPON_SMG`, `WEAPON_SMG_MK2`, `WEAPON_ASSAULTSMG`, `WEAPON_COMBATPDW`, `WEAPON_GUSENBERG`, `WEAPON_COMPACTRIFLE`, `WEAPON_ASSAULTRIFLE`, `WEAPON_ASSAULTRIFLE`, `WEAPON_EMPLAUNCHER`, `WEAPON_FERTILIZERCAN`, `WEAPON_CARBINERIFLE`, `WEAPON_MARKSMANRIFLE`, `WEAPON_SNIPERRIFLE`, `WEAPON_NAVYREVOLVER`, `WEAPON_RPG` }
local Electricity = { `WEAPON_STUNGUN`, `WEAPON_STUNGUN_MP` }
local Animal = { -100946242, 148160082 }
local FallDamage = { -842959696 }
local Explosion = { -1568386805, 1305664598, -1312131151, 375527679, 324506233, 1752584910, -1813897027, 741814745, -37975472, 539292904, 341774354, -1090665087 }
local Gas = { -1600701090 }
local Burn = { 615608432, 883325847, -544306709 }
local Drown = { -10959621, 1936677264 }
local Car = { 133987706, -1553120962 }
local tekst = 0
local isUsing = false
local cam = nil
local check = false
local czanrnytoziomek = false

local choosedHospital = nil
local heli = false
local qtarget = exports.qtarget

RegisterNetEvent("ambulance")
AddEventHandler("ambulance", function(title, msg, type)
    lib.notify({
		title = title,
        description = msg,
        type = type
    })
end)

ESX = exports['es_extended']:getSharedObject()

function isDead()
	return IsDead
end

function checkArray(array, val)
	for _, value in ipairs(array) do
		local v = value
		if type(v) == 'string' then
			v = GetHashKey(v)
		end

		if v == val then
			return true
		end
	end

	return false
end

function DrawText3D(x, y, z, text, scale)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

	SetTextScale(scale, scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(1)
	SetTextColour(255, 255, 255, 255)
	SetTextOutline()

	AddTextComponentString(text)
	DrawText(_x, _y)

	local factor = (string.len(text)) / 270
	DrawRect(_x, _y + 0.015, 0.005 + factor, 0.03, 31, 31, 31, 155)
end

function cleanPlayer(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end

function RespawnPed(ped, coords)
	TriggerEvent("csskrouble:niggerCheck", false)
	TriggerEvent("csskrouble:save")
	exports["death"]:setDeath(false)
	SetEntityCoords(ped, coords.x, coords.y, coords.z)
	SetEntityHeading(ped, coords.heading)
	if ped == PlayerPedId() then
		SetGameplayCamRelativeHeading(coords.heading)
	end
	
	SetEntityHealth(ped, GetEntityMaxHealth(ped))
	
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
	TriggerEvent('esx:onPlayerSpawn', coords.x, coords.y, coords.z)
	SetPlayerInvincible(ped, false)
	--Citizen.InvokeNative(0x239528EACDC3E7DE, ped, false)
	ClearPedBloodDamage(ped)
end

Citizen.CreateThread(function()
	while true do
	local playerPed = PlayerPedId()
	Citizen.InvokeNative(0x4757f00bc6323cfe, -842959696, 10.9)
	Wait (0) 
	Citizen.Wait(100)
	end
	end)

RegisterNetEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(_type)
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed)
	if _type == 'small' then
		local health = GetEntityHealth(playerPed)
		local newHealth = math.min(maxHealth , math.floor(health + maxHealth/4))
		SetEntityHealth(playerPed, newHealth)
	elseif _type == 'big' then
		SetEntityHealth(playerPed, newHealth)
	end
	
	ESX.ShowNotification(_U('healed'))
end)

RegisterNetEvent('esx_ambulancejob:healitem')
AddEventHandler('esx_ambulancejob:healitem', function(_type)
	local playerPed = PlayerPedId()
	local health = GetEntityHealth(playerPed)
	local maxHealth = GetEntityMaxHealth(playerPed)

	if not isUsing then
		if _type == 'bsmall' then
			if health < 200 then 
				isUsing = true
				ESX.UI.Menu.CloseAll()
				local newHealth = health + 50
				FreezeEntityPosition(playerPed, true)
				ClearPedTasks(playerPed)
				FreezeEntityPosition(playerPed, true)
				TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
				
				exports['ExileRP']:DrawProcent(150, function()
					SetEntityHealth(playerPed, newHealth)
					FreezeEntityPosition(playerPed, false)
					ClearPedTasks(playerPed)
					isUsing = false				
					FreezeEntityPosition(playerPed, false)
				end)
			elseif health == 200 then
				lib.notify({title = 'Powiadomienie',description = 'Zużyłeś bandaż.',type = 'inform'})
			end
		elseif _type == 'bmedium' then
			isUsing = true
			ESX.UI.Menu.CloseAll()
			ClearPedTasks(playerPed)
			FreezeEntityPosition(playerPed, true)
			TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
			
			exports['ExileRP']:DrawProcent(300, function()
				FreezeEntityPosition(playerPed, false)
				ClearPedTasks(playerPed)
				isUsing = false
				SetEntityHealth(playerPed, maxHealth)
				ESX.ShowNotification(_U('healed'))			
			end)
		end
	else
		lib.notify({title = 'Powiadomienie',description = 'Juz sobie pomagasz',type = 'inform'})
	end
end)

function StartRespawnTimer()
	Citizen.SetTimeout(Config.RespawnDelayAfterRPDeath, function()
			if IsDead then 
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'rp_dead', {
			title = _U('rp_dead'),
			align = 'center',
			elements = {
				{ label = _U('yes'), value = 'yes' },
				{ label = _U('no'), value = 'no' },
			}
		}, function (data, menu)
			if data.current.value == 'yes' then
				RemoveItemsAfterRPDeath()
			end
			menu.close()
		end, function (data, menu)
			menu.close()
			if data.current.value == 'no' and IsControlJustPressed(1, 178) then
				RemoveItemsAfterRPDeath()
			end
			menu.close()
		end)
			end
	end)
end

function setUniform(job, playerPed)
	local sex = 0
    if (exports['fivem-appearance']:getPedModel(playerPed) == 'mp_f_freemode_01') then sex = 1 end

    for k, v in pairs(Config.Uniforms[job]) do
        local drawable = v.male.drawable
        local texture = v.male.texture
        if (sex == 1) then
            drawable = v.female.drawable
            texture = v.female.texture
        end

        TriggerEvent('many-base:SetClothing', k, drawable, texture)
    end
end

function StartDistressSignal()
	CreateThread(function()
		local timer = Config.RespawnDelayAfterRPDeath

		local signal = 0
		while IsDead do
			Citizen.Wait(0)

			if obezwladniony then
				return
			else
				if signal < GetGameTimer() then
					SetTextFont(4)
					SetTextCentre(true)
					SetTextProportional(1)
					SetTextScale(0.45, 0.45)
					SetTextColour(255, 255, 255, 255)
					SetTextDropShadow(0, 0, 0, 0, 255)
					SetTextEdge(1, 0, 0, 0, 255)
					SetTextDropShadow()
					SetTextOutline()

					BeginTextCommandDisplayText('STRING')
					--AddTextComponentSubstringPlayerName(_U('distress_send'))
					EndTextCommandDisplayText(0.5, 0.905)		

					if IsDisabledControlPressed(0, Keys['G']) and not exports['esx_policejob']:IsCuffed() then
						SendDistressSignal()
						signal = GetGameTimer() + 90000 * 4
					end					
				end
			end
		end
	end)
end

function SendDistressSignal()	
	ESX.TriggerServerCallback('gcphone:getItemAmount', function(qtty)
		if qtty > 0 then
			ESX.TriggerServerCallback('route68:getSimWczytana', function(sim)
				if sim == nil then
					lib.notify({title = 'Powiadomienie',description = 'Nie posiadasz podpiętej karty sim',type = 'inform'})
				else
					local godzinaInt = GetClockHours()
					local godzina = ''
					if string.len(tostring(godzinaInt)) == 1 then
						godzina = '0'..godzinaInt
					else
						godzina = godzinaInt
					end
					local minutaInt = GetClockMinutes()
					local minuta = ''
					if string.len(tostring(minutaInt)) == 1 then
						minuta = '0'..minutaInt
					else
						minuta = minutaInt
					end
					godzina = godzina..":"..minuta
					
					lib.notify({title = 'Powiadomienie',description = 'Sygnał alarmowy został wysłany!',type = 'inform'})
					
					local coords = GetEntityCoords(PlayerPedId())
					TriggerServerEvent('esx_addons_gcphone:startCall', 'ambulance', 'Ranny obywatel o godzienie: '..godzina, {
						x = coords.x,
						y = coords.y,
						z = coords.z
					})				
				end
			end)
		end
	end, 'phone')
end

function ShowDeathTimer()
	if DistressThreadId then
		TerminateThread(DistressThreadId)
	end
	
	local respawnTimer = Config.RespawnDelayAfterRPDeath
	local allowRespawn = Config.RespawnDelayAfterRPDeath/2
	local fineAmount = Config.EarlyRespawnFineAmount
	local payFine = false

	if Config.EarlyRespawn and Config.EarlyRespawnFine then
		ESX.TriggerServerCallback('esx_ambulancejob:checkBalance', function(finePayable)
			if finePayable then
				payFine = true
			else
				payFine = false
			end
		end)
	end

	CreateThread(function()
		ClearPedTasksImmediately(PlayerPedId())
		while respawnTimer > 0 and IsDead do
			Citizen.Wait(0)
			if obezwladniony then
				return
			else
				raw_seconds = respawnTimer/1000
				raw_minutes = raw_seconds/60
				minutes = stringsplit(raw_minutes, ".")[1]
				seconds = stringsplit(raw_seconds-(minutes*60), ".")[1]

				SetTextFont(4)
				SetTextProportional(0)
				SetTextScale(0.0, 0.5)
				SetTextColour(255, 255, 255, 255)
				SetTextDropshadow(0, 0, 0, 0, 255)
				SetTextEdge(1, 1, 0, 0, 255)
				SetTextDropShadow()
				SetTextOutline()

				local text = _U('please_wait', minutes, seconds)

				if Config.EarlyRespawn then
					if not Config.EarlyRespawnFine and respawnTimer <= allowRespawn then
						text = text .. _U('press_respawn')
					elseif Config.EarlyRespawnFine and respawnTimer <= allowRespawn and payFine then
						text = text .. _U('respawn_now_fine', fineAmount)
					else
						text = text
					end
				end

				SetTextCentre(true)
				SetTextEntry("STRING")
				AddTextComponentString(text)
				DrawText(0.5, 0.8)

				if Config.EarlyRespawn then
					if not Config.EarlyRespawnFine then
						if IsControlPressed(0, 46) then
							RemoveItemsAfterRPDeath()
							break
						end
					elseif Config.EarlyRespawnFine then
						if respawnTimer <= allowRespawn and payFine then
							if IsControlPressed(0, 46) then
								RemoveItemsAfterRPDeath()
								break
							end
						end
					end
				end
				respawnTimer = respawnTimer - 15
			end
		end
	end)
end

RegisterNetEvent('esx_ambulancejob:tepek')
AddEventHandler('esx_ambulancejob:tepek', function(source)
	TepekCwela()
end)

RegisterCommand('fine', function()
	RemoveItemsAfterRPDeath()
end)

function TepekCwela()
	CreateThread(function()
		DoScreenFadeOut(800)
		ESX.UI.Menu.CloseAll()
		local gracz = PlayerPedId()
			ESX.SetPlayerData('lastPosition', vector3(322.0606, -589.4077, 43.9903))
			TriggerServerEvent('esx:updateCoords', vector3(322.0606, -589.4077, 43.9903))
			RespawnPed(gracz, vector3(322.0606, -589.4077, 43.9903))
			SetEntityHeading(gracz, 70.9027)
			DoScreenFadeIn(800)
			if lib.progressBar({
				duration = 10000,
				label = 'Trwa leczenie...',
				useWhileDead = true,
				canCancel = false,
				disable = {
					car = true,
					move = true,
					combat = true
				},
				anim = {
					dict = 'missfbi1',
					clip = 'cpr_pumpchest_idle',
					flag = 1
				},
			}) then
			StopScreenEffect('DeathFailOut')
			TriggerServerEvent('esx_ambulancejob:setDeathStatus', 0)
			TriggerEvent('esx_ambulancejob:baska')
			end
	end)
end

RegisterNetEvent('esx_ambulancejob:baska')
AddEventHandler('esx_ambulancejob:baska', function(source)
	BaskaKurwaLeczenie()
end)

RegisterCommand('baska', function()
	TepekCwela()
end)

function BaskaKurwaLeczenie()
	CreateThread(function()
		DoScreenFadeOut(800)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end
		ESX.UI.Menu.CloseAll()
			ESX.SetPlayerData('lastPosition', vector3(321.9770, -590.3242, 43.2782))
			TriggerServerEvent('esx:updateCoords', vector3(321.9770, -590.3242, 43.2782))
			RespawnPed(PlayerPedId(), vector3(321.9770, -590.3242, 43.2782))
			SetEntityHeading(PlayerPedId(), 162.4371)
			exports['many-base']:playAnim(PlayerPedId(), 'mp_safehouseseated@male@generic@exit', 'exit_forward', 700, false)
			StopScreenEffect('DeathFailOut')
			DoScreenFadeIn(800)
		end)
end

RegisterNetEvent('esx_ambulancejob:respkurwe')
AddEventHandler('esx_ambulancejob:respkurwe', function(source)
	RespienieKurwyBW()
end)

function RespienieKurwyBW()
	CreateThread(function()
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		DoScreenFadeOut(800)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end
		ESX.UI.Menu.CloseAll()
			ESX.SetPlayerData('lastPosition', vector3(318.0996, -591.1799, 43.2841))
			TriggerServerEvent('esx:updateCoords', vector3(318.0996, -591.1799, 43.2841))
			RespawnPed(PlayerPedId(), vector3(318.0996, -591.1799, 43.2841))
			TriggerServerEvent('esx_ambulancejob:setDeathStatus', 0)
			czanrnytoziomek = false
			FreezeEntityPosition(playerPed, false)
			SetEntityInvincible(playerPed, false)
			SetEntityCanBeDamaged(playerPed, true)
			StopScreenEffect('DeathFailOut')
			DoScreenFadeIn(800)
		end)
end

function RemoveItemsAfterRPDeath()
	CreateThread(function()
		DoScreenFadeOut(800)
		while not IsScreenFadedOut() do
			Citizen.Wait(10)
		end
		ESX.UI.Menu.CloseAll()
		ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()
			ESX.SetPlayerData('lastPosition', vector3(318.0996, -591.1799, 43.2841))
			TriggerServerEvent('esx:updateCoords', vector3(318.0996, -591.1799, 43.2841))
			RespawnPed(PlayerPedId(), vector3(318.0996, -591.1799, 43.2841))
			TriggerServerEvent('esx_ambulancejob:setDeathStatus', 0)
			StopScreenEffect('DeathFailOut')
			DoScreenFadeIn(800)
		end)
	end)
end

function PayFine()
	ESX.TriggerServerCallback('esx_ambulancejob:payFine', function()
	RemoveItemsAfterRPDeath()
	end)
end

function secondsToClock(seconds)
	local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

	if seconds <= 0 then
		return 0, 0
	else
		local hours = string.format('%02.f', math.floor(seconds / 3600))
		local mins = string.format('%02.f', math.floor(seconds / 60 - (hours * 60)))
		local secs = string.format('%02.f', math.floor(seconds - hours * 3600 - mins * 60))

		return secs, mins
	end
end

function StartDeathTimer()
	if TimerThreadId then
		TerminateThread(TimerThreadId)
	end
	local timer = ESX.Math.Round(Config.RespawnToHospitalDelay / 1000)
	local seconds,minutes = secondsToClock(timer)
	local firstScreen = true
	CreateThread(function() 
		HasTimer = true
		while timer > 0 and IsDead do
			Citizen.Wait(1000)
			if timer > 0 then
				timer = timer - 1
			end
			seconds,minutes = secondsToClock(timer)
		end
		HasTimer = false
		firstScreen = false
	end)
	CreateThread(function()
		TimerThreadId = GetIdOfThisThread()

		while firstScreen do
			Citizen.Wait(1)
			if obezwladniony then
				return
			else
				Wait(1)
			end
		end

		local pressStart = nil
		while IsDead do
			Citizen.Wait(1)
			if obezwladniony then 
				return
			else
				exports["death"]:setDeath(true, Config.EarlyRespawnTimerr/1000)
				if IsControlPressed(0, Keys['E']) or IsDisabledControlPressed(0, Keys['E']) then
					if not pressStart then
						pressStart = GetGameTimer()
					end

					if GetGameTimer() - pressStart > 3000 then
						TriggerEvent('esx_ambulancejob:respkurwe')
					end
			end
		end
		end
	end)
end

function StartDeathTimer2()
	if TimerThreadId2 then
		TerminateThread(TimerThreadId2)
	end

	local timer2 = ESX.Math.Round(Config.RespawnToHospitalDelay / 1000)
	local seconds,minutes = secondsToClock(timer2)
	local firstScreen2 = true
	local nigger1 = false
	CreateThread(function() 
		HasTimer2 = true
		while timer2 > 0 do
			Citizen.Wait(1000)
			if timer2 > 0 then
				timer2 = timer2 - 1
			else
				nigger1 = true
			end
			seconds,minutes = secondsToClock(timer2)
		end
		HasTimer2 = false
		firstScreen2 = false
	end)
	CreateThread(function()
		TimerThreadId2 = GetIdOfThisThread()

		while firstScreen2 do
			Citizen.Wait(1)
			if obezwladniony then
				return
			else
				Wait(1)
			end
		end

		local pressStart2 = nil
		while czanrnytoziomek do
			Citizen.Wait(1)
			if czanrnytoziomek and timer2 <= 0 then
				exports["death"]:setDeath(true, Config.EarlyRespawnTimerr/1000)
				if IsControlPressed(0, Keys['E']) or IsDisabledControlPressed(0, Keys['E']) then
					if not pressStart2 then
						pressStart2 = GetGameTimer()
					end

					if GetGameTimer() - pressStart2 > 3000 then
						TriggerEvent('esx_ambulancejob:respkurwe')
						nigger1 = false
					end
				end
		end
		end
	end)
end

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do        
        Citizen.Wait(1)
    end
end

CreateThread(function()
	while true do
		Citizen.Wait(2)

		if IsDead then
			DisableAllControlActions(0)
			EnableControlAction(0, 1, true)
			EnableControlAction(0, 2, true)
			EnableControlAction(0, Keys['G'], true)
			EnableControlAction(0, Keys['T'], true)
			EnableControlAction(0, Keys['E'], true)
			EnableControlAction(0, Keys['F5'], true)
			EnableControlAction(0, Keys['N'], true)
			EnableControlAction(0, Keys['HOME'], true)
			EnableControlAction(0, Keys['DELETE'], true)
			EnableControlAction(0, Keys['H'], true)
			EnableControlAction(0, 21, true)
			EnableControlAction(0, Keys['Z'], true)
			EnableControlAction(0, Keys['F5'], true)
	--		EnableControlAction(0, Keys['F1'], true)
			EnableControlAction(0, Keys['F2'], true)
		else
			Citizen.Wait(500)
		end
	end
end)

function DeathFunc() 
	local playerPed = PlayerPedId()
	CreateThread(function ()
		RequestAnimDict('dead')
		while not HasAnimDictLoaded('dead') do
			Citizen.Wait(0)
		end

		if IsPedInAnyVehicle(playerPed, false) then
			while IsPedInAnyVehicle(playerPed, true) do
				Citizen.Wait(0)
			end
		else
			if GetEntitySpeed(playerPed) > 0.2 then
				while GetEntitySpeed(playerPed) > 0.2 do
					Citizen.Wait(0)
				end
			end
		end

		local weapon = GetPedCauseOfDeath(playerPed)
		local sourceofdeath = GetPedSourceOfDeath(playerPed)
		local damagedbycar = false
		if weapon == 0 and sourceofdeath == 0 and HasEntityBeenDamagedByWeapon(playerPed, `WEAPON_RUN_OVER_BY_CAR`, 0) then
			damagedbycar = true
		end
		local coords = GetEntityCoords(playerPed)
		NetworkResurrectLocalPlayer(coords, 0.0, false, false)
		Citizen.Wait(100)
		SetEntityCoords(playerPed, coords)
		SetPlayerInvincible(PlayerId(), true)
		SetPlayerCanUseCover(PlayerId(), false)

		local knockoutDuration = 15000

		if weapon == `WEAPON_UNARMED` or ((weapon == `WEAPON_RUN_OVER_BY_CAR` or damagedbycar) and sourceofdeath ~= playerPed) or weapon == `WEAPON_NIGHTSTICK` then
			obezwladniony = true
			TaskPlayAnim(playerPed, 'dead', 'dead_a', 1.0, 1.0, -1, 2, 0, 0, 0, 0)
			if lib.progressBar({
				duration = 15000,
				label = 'Odzyskiwanie sił...',
				useWhileDead = true,
				canCancel = false,
				disable = {
					car = true,
					move = true,
					combat = true
				}
			}) then
				RespawnPed(PlayerPedId(), GetEntityCoords(GetPlayerPed(-1)))
				Citizen.Wait(500)
				SetEntityHealth(PlayerPedId(), 170)
			end
		end

		while IsDead do
			SetEntityInvincible(playerPed, false)
			SetEntityCanBeDamaged(playerPed, true)
			if not IsPedInAnyVehicle(playerPed, false) then
				if not IsEntityPlayingAnim(playerPed, 'dead', 'dead_a', 3) then
					TaskPlayAnim(playerPed, 'dead', 'dead_a', 1.0, 1.0, -1, 2, 0, 0, 0, 0)
					czanrnytoziomek = true
					check = true
				end
			end

			Citizen.Wait(1)
		end
		obezwladniony = false
		SetPlayerInvincible(PlayerId(), false)
		SetPlayerCanUseCover(PlayerId(), true)
		SetEntityInvincible(playerPed, false)
		SetEntityCanBeDamaged(playerPed, true)
		StopAnimTask(PlayerPedId(), 'dead', 'dead_a', 4.0)
		RemoveAnimDict('dead')
		czanrnytoziomek = true
		check = false
		EnableAllControlActions(0)
	end)
end

function DrugieBw()
	czanrnytoziomek = true
	local playerPed = PlayerPedId()
	obezwladniony = false
	if IsDead then
	local coords = GetEntityCoords(playerPed)
	local formattedCoords = {
		x = ESX.Math.Round(coords.x, 1),
		y = ESX.Math.Round(coords.y, 1),
		z = ESX.Math.Round(coords.z, 1)
	}
	RespawnPed(playerPed, formattedCoords, 0.0)
	EnableDeathScreen2()
	exports.ox_target:disableTargeting(true)
	RequestAnimDict('dead')
	while not HasAnimDictLoaded('dead') do
		Citizen.Wait(0)
	end
	while czanrnytoziomek do
		if not IsEntityPlayingAnim(playerPed, 'dead', 'dead_h', 3) then
				TaskPlayAnim(playerPed, 'dead', 'dead_h', 1.0, 1.0, -1, 2, 1, 0, 0, 0)
			end
	--		FreezeEntityPosition(playerPed, true)
			SetEntityInvincible(playerPed, true)
			SetEntityCanBeDamaged(playerPed, false)
			Citizen.Wait(1)
		end
		Citizen.Wait(1)
		end
	end


function EnableDeathScreen()
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', 0)
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', 1)
	exports["death"]:setDeath(true, Config.EarlyRespawnTimer/1000)
	StartDeathTimer()
	StartDistressSignal()
end

function EnableDeathScreen2()
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', 0)
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', 1)
	exports["death"]:setDeath(true, Config.EarlyRespawnTimer/1000)
	StartDeathTimer2()
	StartDistressSignal()
end

function OnPlayerDeath()
	if not IsDead then
		IsDead = true
		ESX.UI.Menu.CloseAll()

		local playerPed = PlayerPedId()
		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			if GetPedInVehicleSeat(vehicle, -1) == playerPed then
				SetVehicleEngineOn(vehicle, false, true, true)
				while GetEntitySpeed(vehicle) > 0.0 do
					local vehSpeed = GetEntitySpeed(vehicle)
					SetVehicleForwardSpeed(vehicle, (vehSpeed * 0.85))
					Citizen.Wait(300)
				end
			else
				SetEntityCoords(playerPed, GetEntityCoords(playerPed))
			end
		end

		ClearPedTasksImmediately(PlayerPedId())
		--Citizen.InvokeNative(0xAAA34F8A7CB32098, PlayerPedId())

		DeathFunc()
		EnableDeathScreen()
	else
		ClearPedTasksImmediately(PlayerPedId())
		DrugieBw()
	end	
end

function TeleportFadeEffect(entity, coords)

	CreateThread(function()

		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		ESX.Game.Teleport(entity, coords, function()
			DoScreenFadeIn(800)
		end)
	end)
end

function WarpPedInClosestVehicle(ped)

	local coords = GetEntityCoords(ped)

	local vehicle, distance = ESX.Game.GetClosestVehicle({
		x = coords.x,
		y = coords.y,
		z = coords.z
	})

	if distance ~= -1 and distance <= 5.0 then

		local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
		local freeSeat = nil

		for i=maxSeats - 1, 0, -1 do
			if IsVehicleSeatFree(vehicle, i) then
				freeSeat = i
				break
			end
		end

		if freeSeat ~= nil then
			TaskWarpPedIntoVehicle(ped, vehicle, freeSeat)
		end

	else
		ESX.ShowNotification(_U('no_vehicles'))
	end
end

function SzatniaEMS()

	ESX.UI.Menu.CloseAll()
	local playerPed = GetPlayerPed(-1)


	local elements = {
		{ label = 'Ubranie Codzienne', value = 'citizen_wear' },
		{ label = 'Ubrania Służbowe', value = 'alluniforms'},
	  }



	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom',
	{
		title    = 'Szatnia',
		align    = 'center',
		elements = elements
	}, function(data, menu)

		cleanPlayer(playerPed)

		if data.current.value == 'ambulance_wear' then
			menu.close()
			setUniform('pielegniarz_wear', playerPed)
		end
		
		if data.current.value == 'citizen_wear' then
			menu.close()
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		end

		if data.current.value == 'alluniforms' then
			local elements2 = {
				{label = "REKRUT", value = 'REKRUT'},
				{label = "PIELĘGNIARZ", value = 'PIELEGNIARZ'},
				{label = "RATOWNIK MEDYCZNY", value = 'RATOWNIK_MED'},
				{label = "LEKARZ", value = 'LEKARZ'},
				{label = "LEKARZ HABILOTOWANY", value = 'LEKARZ2'},
				{label = "ZASTĘPCA ORDYNATORA", value = 'ZASTEPCA_ORD'},
				{label = "ORDYNATOR", value = 'ORDYNATOR'},
				{label = "ZASTĘPCA DYREKTORA", value = 'ZASTEPCA_DYR'},
				{label = "DYREKTOR ", value = 'DYREKTOR'},
			}

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'alluniforms', {
				title    = "Szatnia - EMS",
				align    = 'center',
				elements = elements2
			}, function(data2, menu2)
				setUniform(data2.current.value, playerPed)
			end, function(data2, menu2)
				menu2.close()
			end)
		end

	if
		data.current.value == 'REKRUT' or
		data.current.value == 'PIELEGNIARZ' or
		data.current.value == 'RATOWNIK_MED' or
		data.current.value == 'LEKARZ' or
		data.current.value == 'LEKARZ2' or
		data.current.value == 'ZASTEPCA_ORD' or
		data.current.value == 'ORDYNATOR' or
		data.current.value == 'ZASTEPCA_DYR' or
		data.current.value == 'DYREKTOR'
	then
		setUniform(data.current.value, playerPed)
	end

	end, function(data, menu)
		menu.close()
		
		CurrentAction		= 'ambulance_actions_menu'
		CurrentActionMsg	= "Naciśnij ~INPUT_CONTEXT~, aby się przebrać"
		CurrentActionData	= {}

	end)
end

exports['qtarget']:AddBoxZone("PrzebieralniaEMS", vector3(298.6344, -598.2062, 43.2841), 1.7, 1.3, {
	name="PrzebieralniaEMS",
	heading=68.7154,
	--debugPoly=false,
	minZ=42.2841,
	maxZ=44.2841,
	}, {
		options = {
			{
				event = "fivem-appearance:clothingShop",
				icon = "fas fa-tshirt",
				label = "Przebierz się",
				job = "ambulance",
				num = 1
			},
			{
				action = function()
					SzatniaEMS()
				end,
				icon = "fas fa-tshirt",
				label = "Wybierz strój",
				job = "ambulance",
				num = 2
			},
		},
		distance = 3.0
})

function SetVehicleMaxMods(vehicle, livery, offroad, wheelsxd, color, extrason, extrasoff, bulletproof, tint, wheel, tuning, plate)
	local t = {
		modArmor        = 4,
		modTurbo        = true,
		modXenon        = true,
		windowTint      = 0,
		dirtLevel       = 0,
		color1			= 0,
		color2			= 0
	}
	
	if tuning then
		t.modEngine = 3
		t.modBrakes = 2
		t.modTransmission = 2
		t.modSuspension = 3
	end

	if offroad then
		t.wheelColor = 5
		t.wheels = 4
		t.modFrontWheels = 17
	end

	if wheelsxd then
		t.wheels = 1
		t.modFrontWheels = 5
	end

	if bulletproof then
		t.bulletProofTyre = true
	end

	if color then
		t.color1 = color
	end

	if tint then
		t.windowTint = tint
	end

	if wheel then
		t.wheelColor = wheel.color
		t.wheels = wheel.group
		t.modFrontWheels = wheel.type
	end
	
	ESX.Game.SetVehicleProperties(vehicle, t)

	if #extrason > 0 then
		for i=1, #extrason do
			SetVehicleExtra(vehicle, extrason[i], false)
		end
	end
	
	if #extrasoff > 0 then
		for i=1, #extrasoff do
			SetVehicleExtra(vehicle, extrasoff[i], true)
		end
	end
	  
	if livery then
		SetVehicleLivery(vehicle, livery)
	end
end

function CanPlayerUseHidden(grade)
	return not grade or PlayerData.hiddenjob.grade >= grade
end

function CanPlayerUse(grade)
	return not grade or PlayerData.job.grade >= grade
end

function OpenVehicleSpawnerMenu(partNum)
	local vehicles = Config.Ambulance.Vehicles
	
	ESX.UI.Menu.CloseAll()
	local elements = {}
	local found = true
	
	for i, group in ipairs(Config.VehicleGroups) do
		local elements2 = {}
		
		for _, vehicle in ipairs(Config.AuthorizedVehicles) do
			local let = false
			for _, group in ipairs(vehicle.groups) do
				if group == i then
					let = true
					break
				end
			end

			if let then
				if vehicle.grade then
					if vehicle.hidden == true then
						if i ~= 5 then
							if not CanPlayerUseHidden(vehicle.grade) then
								let = false
							end
						else
							if not CanPlayerUseHidden(vehicle.grade) and not CanPlayerUse(vehicle.grade) then
								let = false
							end
						end
					else
						if not CanPlayerUse(vehicle.grade) then
							let = false
						end
					end
				elseif vehicle.grades and #vehicle.grades > 0 then
					let = false
					for _, grade in ipairs(vehicle.grades) do
						if ((vehicle.swat and IsSWAT) or grade == PlayerData.job.grade) and (not vehicle.label:find('SEU') or IsSEU) then
							let = true
							break
						end
					end
				end

				if let then
					table.insert(elements2, { label = vehicle.label, model = vehicle.model, livery = vehicle.livery, extrason = vehicle.extrason, extrasoff = vehicle.extrasoff, offroad = vehicle.offroad, wheelsxd = vehicle.wheelsxd, color = vehicle.color, plate = vehicle.plate, tint = vehicle.tint, bulletproof = vehicle.bulletproof, wheel = vehicle.wheel, tuning = vehicle.tuning })
				end
			end
		end
			
		if (PlayerData.job.name == 'ambulance' and PlayerData.job.grade >= 12) or (PlayerData.hiddenjob.name == 'sheriff' and PlayerData.hiddenjob.grade >= 11) then
			if #elements2 > 0 then
				table.insert(elements, {label = group, value = elements2, group = i})				
			end
		else
			if i == 5 then
				found = false
				ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
					if hasWeaponLicense then
						table.insert(elements, { label = group, value = elements2, group = i })
					end
					
					found = true
				end, GetPlayerServerId(PlayerId()), 'seu')
			elseif i == 6 then
				found = false
				ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
					if hasWeaponLicense then
						table.insert(elements, { label = group, value = elements2, group = i })
					end
					
					found = true
				end, GetPlayerServerId(PlayerId()), 'dtu')
			elseif i == 7 then
				found = false
				ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
					if hasWeaponLicense then
						table.insert(elements, { label = group, value = elements2, group = i })
					end
					
					found = true
				end, GetPlayerServerId(PlayerId()), 'sert')
			elseif i == 8 then
				if PlayerData.hiddenjob.name == 'sheriff' then
					table.insert(elements, { label = group, value = elements2, group = i })
				end
			elseif i == 9 then
				found = false
				ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
					if hasWeaponLicense then
						table.insert(elements, { label = group, value = elements2, group = i })
					end
					
					found = true
				end, GetPlayerServerId(PlayerId()), 'usms')
			elseif i == 10 then
				if PlayerData.hiddenjob.name == 'hwp' then
					table.insert(elements, { label = group, value = elements2, group = i })
				end
			elseif i == 11 then
				if PlayerData.hiddenjob.name == 'hwp' then
					table.insert(elements, { label = group, value = elements2, group = i })
				end
			else
				table.insert(elements, { label = group, value = elements2, group = i })
			end
		end
	end
	
	while not found do
		Citizen.Wait(100)
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner', {
	  title    = _U('vehicle_menu'),
	  align    = 'right',
	  elements = elements
	}, function(data, menu)
		menu.close()
		if type(data.current.value) == 'table' and #data.current.value > 0 then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner_' .. data.current.group, {
				title    = data.current.label,
				align    = 'right',
				elements = data.current.value
			}, function(data2, menu2)
				local livery = data2.current.livery
				local extrason = data2.current.extrason
				local extrasoff = data2.current.extrasoff
				local offroad = data2.current.offroad
				local wheelsxd = data2.current.wheelsxd
				local color = data2.current.color
				local bulletproof = data2.current.bulletproof or false
				local tint = data2.current.tint
				local wheel = data2.current.wheel
				local tuning = data2.current.tuning

				local setPlate = true
				if data2.current.plate ~= nil and not data2.current.plate then
					setPlate = false
				end

				local vehicle = GetClosestVehicle(vehicles[partNum].spawnPoint.x,  vehicles[partNum].spawnPoint.y,  vehicles[partNum].spawnPoint.z, 3.0, 0, 71)
				if not DoesEntityExist(vehicle) then
					local playerPed = PlayerPedId()
					if Config.MaxInService == -1 then
						ESX.Game.SpawnVehicle(data2.current.model, {
							x = vehicles[partNum].spawnPoint.x,
							y = vehicles[partNum].spawnPoint.y,
							z = vehicles[partNum].spawnPoint.z
						}, vehicles[partNum].heading, function(vehicle)
							SetVehicleMaxMods(vehicle, livery, offroad, wheelsxd, color, data2.current.extrason, data2.current.extrasoff, bulletproof, tint, wheel, tuning)
							
							if setPlate then
								local plate = ""
								if data.current.label == 'PATROL' then
									plate = math.random(100, 999) .. "SAMS" .. math.random(100, 999)
								elseif data.current.label == 'HP UNMARKED' then
									plate = math.random(100, 999) .. "SAMS" .. math.random(100, 999)
								elseif PlayerData.hiddenjob.name == 'sheriff' then
									plate = "SAMS " .. math.random(100,999)
								elseif PlayerData.hiddenjob.name == 'hwp' then
									plate = "SAMS " .. math.random(100,999)
								else
									plate = "SAMS " .. math.random(100,999)
								end
								
								SetVehicleNumberPlateText(vehicle, plate)
								local localVehPlate = string.lower(GetVehicleNumberPlateText(vehicle))
								TriggerEvent('ls:dodajklucze2', localVehPlate)
							else
								local localVehPlate = string.lower(GetVehicleNumberPlateText(vehicle))
								TriggerEvent('ls:dodajklucze2', localVehPlate)
							end

							TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
						end)
					else
						ESX.Game.SpawnVehicle(data2.current.model, {
							x = vehicles[partNum].spawnPoint.x,
							y = vehicles[partNum].spawnPoint.y,
							z = vehicles[partNum].spawnPoint.z
						}, vehicles[partNum].heading, function(vehicle)
							SetVehicleMaxMods(vehicle, livery, offroad, wheelsxd, color, data2.current.extrason, data2.current.extrasoff, bulletproof, tint, wheel, tuning)

							if setPlate then
								local plate = ""
								
								if data.current.label == 'PATROL' then
									plate = math.random(100, 999) .. "SAMS" .. math.random(100, 999)
								elseif PlayerData.hiddenjob.name == 'sheriff' then
									plate = "SAMS " .. math.random(100,999)
								else
									plate = "SAMS " .. math.random(100,999)
								end
								
								SetVehicleNumberPlateText(vehicle, plate)
								local localVehPlate = string.lower(GetVehicleNumberPlateText(vehicle))
								TriggerEvent('ls:dodajklucze2', localVehPlate)
							else
								local localVehPlate = string.lower(GetVehicleNumberPlateText(vehicle))
								TriggerEvent('ls:dodajklucze2', localVehPlate)
							end

							TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
						end)
					end
				else
					lib.notify({title = 'Powiadomienie',description = 'Pojazd znaduje się w miejscu wyciągnięcia następnego',type = 'inform'})
				end
			end, function(data2, menu2)
				menu.close()
				OpenVehicleSpawnerMenu(partNum)
			end)
		else
			lib.notify({title = 'Powiadomienie',description = 'Brak pojazdów dostępnych w tej kategorii dla twojego stopnia.',type = 'inform'})
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'menu_vehicle_spawner'
		CurrentActionMsg  = _U('vehicle_spawner')
		CurrentActionData = {station = station, partNum = partNum}
	end)
end

AddEventHandler('playerSpawned', function()
	IsDead = false

	if FirstSpawn then
		FirstSpawn = false
		CreateThread(function()
			local status = 0
			while true do
				if status == 0 then
					status = 1 
						if result == 3 then
							status = 2
						else
							status = 0
						end
				end
				
				Citizen.Wait(200)
				if status == 2 then
					break
				end
			end
			
			exports.spawnmanager:setAutoSpawn(false)
		end)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	ESX.TriggerServerCallback('esx_license:checkLicense', function(lickajest)
		if lickajest then
			heli = true
		else
			heli = false
		end
	end, GetPlayerServerId(PlayerId()), 'ems_heli')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)


AddEventHandler('esx:onPlayerDeath', function(reason)
	OnPlayerDeath()
end)

RegisterNetEvent('esx_healthnarmour:set')
AddEventHandler('esx_healthnarmour:set', function(health, armour)
	SetEntityHealth(PlayerPedId(), tonumber(health))
	SetPedArmour(PlayerPedId(), tonumber(armour))
	if tonumber(health) == 0 then
		lib.notify({title = 'Powiadomienie',description = 'Jesteś nieprzytomny, ponieważ przed wyjściem z serwera Twoja postać miała BW',type = 'inform'})
	end
end)

RegisterNetEvent('hypex_ambulancejob:hypexrevive')
AddEventHandler('hypex_ambulancejob:hypexrevive', function(notBlock)
	if notBlock == nil then
		notBlock = false
	end
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', 0)
	czanrnytoziomek = false
	FreezeEntityPosition(playerPed, false)
	SetEntityInvincible(playerPed, false)
	SetEntityCanBeDamaged(playerPed, true)
	exports.ox_target:disableTargeting(false)
	DoScreenFadeOut(800)

	Citizen.Wait(800)
	
	local formattedCoords = {
		x = ESX.Math.Round(coords.x, 1),
		y = ESX.Math.Round(coords.y, 1),
		z = ESX.Math.Round(coords.z, 1)
	}

	ESX.SetPlayerData('lastPosition', formattedCoords)
	ESX.SetPlayerData('loadout', {})
	TriggerServerEvent('esx:updateCoords', formattedCoords)
	RespawnPed(playerPed, formattedCoords, 0.0)


	DoScreenFadeIn(800)
end)

CreateThread(function()
	local lastHealth = GetEntityHealth(PlayerPedId())
	while true do
		Citizen.Wait(1000)
		local myPed = PlayerPedId()
		local health = GetEntityHealth(myPed)
		if HasEntityBeenDamagedByWeapon(myPed, `WEAPON_RAMMED_BY_CAR`, 0) then
			ClearEntityLastDamageEntity(myPed)
			if (health ~= lastHealth) then
				SetEntityHealth(myPed, lastHealth)
			end
		end
		lastHealth = health
	end
end)

RegisterNetEvent('hypex_ambulancejob:hypexreviveblack')
AddEventHandler('hypex_ambulancejob:hypexreviveblack', function(admin)
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	if IsDead then
		TriggerServerEvent('exile_wypadanie:bron')
	end
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', 0)

	DoScreenFadeOut(800)

	Citizen.Wait(800)

	local formattedCoords = {
		x = ESX.Math.Round(coords.x, 1),
		y = ESX.Math.Round(coords.y, 1),
		z = ESX.Math.Round(coords.z, 1)
	}

	ESX.SetPlayerData('lastPosition', formattedCoords)
	ESX.SetPlayerData('loadout', {})
	TriggerServerEvent('esx:updateCoords', formattedCoords)
	RespawnPed(playerPed, formattedCoords, 0.0)

	if admin and admin ~= nil then
		lib.notify({title = 'Powiadomienie',description = "Zostałeś ożywiony przez administratora "..admin.."!",type = 'inform'})
	end
	exports.ox_target:disableTargeting(false)
	DoScreenFadeIn(800)
end)

CreateThread(function()
		local blip = AddBlipForCoord(vector3(300.8911, -585.2526, 43.2841))
		SetBlipSprite(blip, Config.Sprite)
		SetBlipDisplay(blip, Config.Display)
		SetBlipScale(blip, Config.Scale)
		SetBlipColour(blip, Config.Colour)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Szpital")
		EndTextCommandSetBlipName(blip)
end)

local hasVehicle = false
RegisterNetEvent('esx_ambulancejob:vehicle', function()
    if not hasVehicle then
    local vehicle = 'emsnspeedo'
    local coords = vector4(330.3551, -588.3318, 28.7968, 337.1913)
    local TR = PlayerPedId()
    RequestModel(vehicle)
    while not HasModelLoaded(vehicle) do
        Wait(0)
    end
    if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
        local JobVehicle = CreateVehicle(vehicle, coords, 45.0, true, false)
        SetVehicleHasBeenOwnedByPlayer(JobVehicle, true)
        SetEntityAsMissionEntity(JobVehicle, true, true)
        local num = math.random(10, 999)
        local carplate = SetVehicleNumberPlateText(JobVehicle, 'EMS'..num)
        hasVehicle = true
        SetVehicleFuelLevel(JobVehicle, 100.0)
        local id = NetworkGetNetworkIdFromEntity(JobVehicle)
        Wait(500)
        SetNetworkIdCanMigrate(id, true)
        TaskWarpPedIntoVehicle(TR, JobVehicle, -1)
        local plate = GetVehicleNumberPlateText(JobVehicle)
        TriggerServerEvent('many-addkeys', plate)
    else
		lib.notify({title = 'Powiadomienie',description = 'Miejsce wyjmowania pojazdu jest zastawione!',type = 'inform'})
    end
else
	lib.notify({title = 'Powiadomienie',description = 'Musisz schować poprzedni pojazd przed wyjęciem kolejnego!',type = 'inform'})
end
end)

RegisterNetEvent('esx_ambulancejob:removevehicle', function()
    if hasVehicle then
    local TR92 = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(TR92,true)
    SetEntityAsMissionEntity(TR92,true)
    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
    TriggerServerEvent('many-removekeys', plate)
    DeleteVehicle(vehicle)
	lib.notify({title = 'Powiadomienie',description = 'Schowano służbowy pojazd!',type = 'inform'})
    hasVehicle = false
    else
		lib.notify({title = 'Powiadomienie',description = 'Nie wyjąłeś żadnego pojazdu!',type = 'inform'})
    end
end)

exports['qtarget']:AddBoxZone("AmbulanceVehicle", vector3(318.72, -583.05, 28.8), 0.8, 0.8, {
	name="AmbulanceVehicle",
	heading=340,
	--debugPoly=false,
	minZ=28.0,
	maxZ=29.29,
	}, {
		options = {
			{
				event = "esx_ambulancejob:vehicle",
				icon = "fas fa-car",
				label = "Wyjmij Pojazd",
			},
			{
				event = "esx_ambulancejob:removevehicle",
				icon = "fas fa-car",
				label = "Schowaj Pojazd",
			},
		},
		distance = 3.5
})

local hasHeli = false
RegisterNetEvent('esx_ambulancejob:heli', function()
	ESX.TriggerServerCallback('esx_license:checkLicense', function(license)
		if license then
    if not hasHeli then
    local vehicle = 'emsaw139'
    local coords = vector4(351.6902, -588.2372, 74.1617, 283.1264)
    local TR = PlayerPedId()
    RequestModel(vehicle)
    while not HasModelLoaded(vehicle) do
        Wait(0)
    end
    if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
        local EmsHELI = CreateVehicle(vehicle, coords, 45.0, true, false)
        SetVehicleHasBeenOwnedByPlayer(EmsHELI, true)
        SetEntityAsMissionEntity(EmsHELI, true, true)
        local num = math.random(10, 999)
        local carplate = SetVehicleNumberPlateText(EmsHELI, 'EMS'..num)
        hasHeli = true
        SetVehicleFuelLevel(EmsHELI, 100.0)
        local id = NetworkGetNetworkIdFromEntity(EmsHELI)
        Wait(500)
        SetNetworkIdCanMigrate(id, true)
        TaskWarpPedIntoVehicle(TR, EmsHELI, -1)
        local plate = GetVehicleNumberPlateText(EmsHELI)
        TriggerServerEvent('many-addkeys', plate)
    else
		lib.notify({title = 'Powiadomienie',description = 'Miejsce wyjmowania helikopteru jest zastawione!',type = 'inform'})
    end
else
	lib.notify({title = 'Powiadomienie',description = 'Musisz schować poprzedni helikopter przed wyjęciem kolejnego!',type = 'inform'})
end
else
	lib.notify({title = 'Powiadomienie',description = 'Nie jesteś upoważniony do wyjmowania helikopterów!',type = 'inform'})
end
end, GetPlayerServerId(PlayerId()), 'ems_heli')
end)

RegisterNetEvent('esx_ambulancejob:removeheli', function()
    if hasHeli then
    local TR92 = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(TR92,true)
    SetEntityAsMissionEntity(TR92,true)
    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
    TriggerServerEvent('many-removekeys', plate)
    DeleteVehicle(vehicle)
	lib.notify({title = 'Powiadomienie',description = 'Schowano służbowy helikopter!',type = 'inform'})
    hasHeli = false
    else
		lib.notify({title = 'Powiadomienie',description = 'Nie wyjąłeś żadnego helikopteru!',type = 'inform'})
    end
end)

exports['qtarget']:AddBoxZone("AmbulanceHeli", vector3(337.76, -586.53, 74.16), 0.8, 0.8, {
	name="AmbulanceHeli",
	heading=340,
	--debugPoly=false,
	minZ=74.16,
	maxZ=74.96,
	}, {
		options = {
			{
				event = "esx_ambulancejob:heli",
				icon = "fas fa-helicopter",
				label = "Wyjmij Helikopter",
				job = 'ambulance',
			},
			{
				event = "esx_ambulancejob:removeheli",
				icon = "fas fa-helicopter",
				label = "Schowaj Helikopter",
				job = 'ambulance',
			},
		},
		distance = 2.5
})

exports['qtarget']:AddBoxZone("AmbulanceTP1", vector3(337.9, -583.56, 74.16), 2.2, 1, {
	name="AmbulanceTP1",
	heading=339,
	--debugPoly=false,
	minZ=74.06,
	maxZ=74.96,
	}, {
		options = {
			{
				action = function()
					local ped = PlayerPedId()
					DoScreenFadeOut(1000)
					Wait(1000)
					SetEntityCoords(ped, 327.3431, -602.7170, 43.6840)
					SetEntityHeading(ped, 340.5486)
					Wait(500)
					DoScreenFadeIn(1000)
				end,
				icon = "fas fa-door-closed",
				label = "Użyj windy",
				job = 'ambulance',
			},
		},
		distance = 2.5
})

exports['qtarget']:AddBoxZone("AmbulanceTP2", vector3(326.98, -604.52, 43.28), 2.4, 1, {
	name="AmbulanceTP2",
	heading=70,
	--debugPoly=false,
	minZ=43.00,
	maxZ=43.88,
	}, {
		options = {
			{
				action = function()
					local ped = PlayerPedId()
					DoScreenFadeOut(1000)
					Wait(1000)
					SetEntityCoords(ped, 339.6879, -584.4088, 74.5617)
					SetEntityHeading(ped, 248.3233)
					Wait(500)
					DoScreenFadeIn(1000)
				end,
				icon = "fas fa-door-closed",
				label = "Użyj windy",
				job = 'ambulance',
			},
		},
		distance = 2.5
})

exports['qtarget']:AddBoxZone("AmbulanceTP3", vector3(333.04, -595.94, 43.28), 2.4, 1, {
	name="AmbulanceTP3",
	heading=340,
	--debugPoly=false,
	minZ=43.00,
	maxZ=43.88,
	}, {
		options = {
			{
				action = function()
					local ped = PlayerPedId()
					DoScreenFadeOut(1000)
					Wait(1000)
					SetEntityCoords(ped, 345.2421, -586.4078, 28.9968)
					SetEntityHeading(ped, 245.6150)
					Wait(500)
					DoScreenFadeIn(1000)
				end,
				icon = "fas fa-door-closed",
				label = "Użyj windy",
			},
		},
		distance = 2.5
})

exports['qtarget']:AddBoxZone("AmbulanceTP4", vector3(343.65, -586.0, 28.8), 2.4, 1, {
	name="AmbulanceTP4",
	heading=340,
	--debugPoly=false,
	minZ=28.1,
	maxZ=29.2,
	}, {
		options = {
			{
				action = function()
					local ped = PlayerPedId()
					DoScreenFadeOut(1000)
					Wait(1000)
					SetEntityCoords(ped, 331.4947, -595.4993, 43.6840)
					SetEntityHeading(ped, 73.1074)
					Wait(500)
					DoScreenFadeIn(1000)
				end,
				icon = "fas fa-door-closed",
				label = "Użyj windy",
			},
		},
		distance = 2.5
})


RegisterNetEvent('esx_ambulancejob:requestDeath')
AddEventHandler('esx_ambulancejob:requestDeath', function()
	if Config.AntiCombatLog then
		Citizen.Wait(6000)
		local playerPed = PlayerPedId()
		SetEntityHealth(playerPed, 0)
		lib.notify({title = 'Powiadomienie',description = 'Jesteś nieprzytomny/a, ponieważ przed wyjściem z serwera Twoja postać miała BW',type = 'error'})
	end
end)

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

function GetPlayerByEntityID(id)
	for _, player in ipairs(GetActivePlayers()) do
		if id == GetPlayerPed(player) then
			return player
		end
	end
end

local cam = nil

local angleY = 0.0
local angleZ = 0.0

CreateThread(function()
    while true do
        Citizen.Wait(1)
        if (cam and IsDead) then
		else
			Citizen.Wait(500)
		end
    end
end)


local punkty = {
  {x= 307.0954, y= -594.7979, z= 43.2840}, -- kordy baski
}

local treatment = false
local timer = false
local choosen = false
local gotowa = false
local karta = false
local bang

Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(0)
	  for _, item in pairs(punkty) do
		  if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), item.x,item.y,item.z, true) <= 2 then
			TriggerEvent('HelpNotification:Show', "Naciśnij ~INPUT_CONTEXT~ aby uzyskać pomoc (500$)")

			if (IsControlJustPressed(1,38)) and (GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), item.x, item.y, item.z, true) <= 2) then
				TriggerEvent('wyborek')
				if choosen == true then 
				lib.notify({title = 'Powiadomienie',description = 'Lekarze się tobą zajmują!',type = 'inform'})
			  treatment = true
			  choosen = false
				end
			end
		  end

		if treatment == true then
		  timer = true
		end
		if treatment == true and timer == true and (GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), item.x, item.y, item.z, true) <= 2) then
			if gotowa == true and itemCount('money') >= 1500 then 
				TriggerServerEvent('hospital:price_gotowka')
			elseif karta == true then 
				TriggerServerEvent('hospital:price')
			end
		  lib.notify({title = 'Powiadomienie',description = 'Pobrano 500$ z twojego konta!',type = 'inform'})
		  TriggerEvent('esx_ambulancejob:tepek', source)
		  SetEntityHealth(GetPlayerPed(-1), 200)
		  treatment = false
		  timer = false
		  choosen = false
		  karta = false
		  gotowa = false
		end
		if treatment == true and timer == true and (GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), item.x, item.y, item.z, true) > 2) then
			lib.notify({title = 'Powiadomienie',description = 'Odszedłeś za daleko, lekarz nie może ci pomóc!',type = 'inform'})
		  treatment = false
		  timer = false 
		  choosen = false           
		end
	  end 
	end       
  end)

  RegisterNetEvent('wyborek', function(args)
		lib.registerContext({
			id = 'menu_leczenia',
			title = 'Wybierz Opcje Płatności',
			options = {
			  {
				title = 'Gotówka',
				description = 'Zapłać Gotówką',
				icon = 'circle',
				onSelect = function()
				  choosen = true
				  treatment = true
				  gotowa = true
				end,
			  },
			  {
				title = 'Karta',
				description = 'Zapłać Kartą',
				icon = 'circle',
				onSelect = function()
				  choosen = true
				  treatment = true
				  karta = true
				end,
			  },
			}
		  })
   
	lib.showContext('menu_leczenia')
  end)

  AddEventHandler('sociecia', function()
	TriggerEvent('esx_society:openBossMenu', 'ambulance', function(data, menu)
	  menu.close()
  end, opt)
	end)

exports.qtarget:AddBoxZone("ambulanceBOSS", vector3(307.49, -563.86, 43.28), 0.4, 0.4, {
	name="ambulanceBOSS",
	heading=343,
	debugPoly=false,
	minZ=43.28,
	maxZ=43.48,
	}, {
		options = {
			{
				event = "sociecia",
				icon = "fas fa-laptop-code",
				label = "Menu Szefa",
				job = {['ambulance'] = 8}
			},
		},
		distance = 2.5
})