ESX = exports['es_extended']:getSharedObject()

TriggerEvent('esx_society:registerSociety', 'ambulance', 'Ambulance', 'society_ambulance', 'society_ambulance', 'society_ambulance', {type = 'public'})

local date = os.date('*t')
if date.month < 10 then date.month = '0' .. tostring(date.month) end
if date.day < 10 then date.day = '0' .. tostring(date.day) end
if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
if date.min < 10 then date.min = '0' .. tostring(date.min) end
if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end
local date = (''..date.day .. '.' .. date.month .. '.' .. date.year .. ' o godz: ' .. date.hour .. ':' .. date.min .. ':' .. date.sec..'')

RegisterServerEvent('hypex_ambulancejob:hypexrevive')
AddEventHandler('hypex_ambulancejob:hypexrevive', function(target)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
		TriggerClientEvent('hypex_ambulancejob:hypexrevive', target)
end)

RegisterServerEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(target, type)
	TriggerEvent('esx_ambulancejob:heal', target, type)
end)

local notificationTitle = ''

ESX.RegisterServerCallback('esx_ambulancejob:checkEMS', function(source, cb)
    local src = source
    local players = ESX.GetPlayers()
    local emsCount = 0

    for i = 1, #players do
        local player = ESX.GetPlayerFromId(players[i])
        if player['job']['name'] == 'ambulance' then
            emsCount = emsCount + 1
        end
    end

    if emsCount >= 1 then
		cb(false)
		TriggerClientEvent("ambulance", source, "Powiadomienie", "Jest zbyt wielu medyków na służbie", 'error')
    else
		cb(true)
    end
end)

ESX.RegisterServerCallback('esx_ambulancejob:hasItem', function(source, cb, item)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    local playerItem = player.getInventoryItem(item)

    if player and playerItem ~= nil then
        if playerItem.count >= 1 then
            cb(true, playerItem.label)
			player.removeInventoryItem(item, 1)
        else
            cb(false, playerItem.label)
			TriggerClientEvent("ambulance", source, "Powiadomienie", "Nie masz potrzebnych przedmiotów!", 'error')
        end
    else
        print('[many-info] Nie znaleziono przedmiotów w bazie danych')
    end
end)

ESX.RegisterServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer ~= nil then
		for i=1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				if xPlayer.inventory[i].type ~= 'sim_card' then
					xPlayer.removeInventoryItem(xPlayer.inventory[i].name, xPlayer.inventory[i].count)
				end
			end
		end
	end

	cb()
end)

RegisterServerEvent('hospital:price')
AddEventHandler('hospital:price', function()
	exports.pefcl:removeBankBalance(source, { amount = 1500, message = 'Pomoc Medyczna' })
end)

RegisterServerEvent('hospital:price_gotowka')
AddEventHandler('hospital:price_gotowka', function(qtty)
	local xPlayer = ESX.GetPlayerFromId(source)
	exports.pefcl:removeCash(source, 1500)
end)

if Config.EarlyRespawn and Config.EarlyRespawnFine then
	ESX.RegisterServerCallback('esx_ambulancejob:checkBalance', function(source, cb)

		local xPlayer = ESX.GetPlayerFromId(source)
		local bankBalance = xPlayer.getAccount('bank').money
		local finePayable = false

		if bankBalance >= Config.EarlyRespawnFineAmount then
			finePayable = true
		else
			finePayable = false
		end

		cb(finePayable)
	end)

	ESX.RegisterServerCallback('esx_ambulancejob:payFine', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		TriggerClientEvent("ambulance", xPlayer.source, "Powiadomienie", _U('respawn_fine', Config.EarlyRespawnFineAmount), 'inform')
		xPlayer.removeAccountMoney('bank', Config.EarlyRespawnFineAmount)
		cb()
	end)
end

ESX.RegisterServerCallback('esx_ambulancejob:getItemAmount', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local qtty = xPlayer.getInventoryItem(item).count
	cb(qtty)
end)

RegisterServerEvent('esx_ambulancejob:removeItem')
AddEventHandler('esx_ambulancejob:removeItem', function(item)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem(item, 1)
	if item == 'bandage' then
		TriggerClientEvent("ambulance", source, "Powiadomienie", _U('used_bandage'), 'inform')
		--TriggerClientEvent('esx:showNotification', _source, _U('used_bandage'))
	elseif item == 'medikit' then
		TriggerClientEvent("ambulance", source, "Powiadomienie", _U('used_medikit'), 'inform')
		--TriggerClientEvent('esx:showNotification', _source, _U('used_medikit'))
	end
end)

RegisterServerEvent('esx_ambulancejob:giveItem')
AddEventHandler('esx_ambulancejob:giveItem', function(item, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if item == 'medikit' or item == 'bandage' or item == 'gps' or item == 'bodycam' or item == 'radio' then
		local limit = xPlayer.getInventoryItem(item).limit
		
		local delta = 1
		local qtty = xPlayer.getInventoryItem(item).count
		if limit ~= -1 then
			delta = limit - qtty
		end
		if qtty < limit then
			xPlayer.addInventoryItem(item, count ~= nil and count or delta)
		else
			TriggerClientEvent("ambulance", source, "Powiadomienie", _U('max_item'), 'inform')
		end
	end
end)

RegisterCommand('revive', function(source, args, user)
	if source == 0 then
		TriggerClientEvent('hypex_ambulancejob:hypexrevive', tonumber(args[1]), true)
	else
		local xPlayer = ESX.GetPlayerFromId(source)
		if (xPlayer.group == 'best' or xPlayer.group == 'superadmin' or xPlayer.group == 'admin' or xPlayer.group == 'mod' or xPlayer.group == 'support' or xPlayer.group == 'trialsupport') then
			if args[1] ~= nil then
				if GetPlayerName(tonumber(args[1])) ~= nil then
					TriggerClientEvent("ambulance", source, "Powiadomienie", "Zostałeś ożywiony przez administratora " ..GetPlayerName(xPlayer.source).."!", 'inform')
					TriggerClientEvent('hypex_ambulancejob:hypexrevive', tonumber(args[1]), true)
					exports['many-logs']:SendLog(source, "**Użyto komendy /revive**" .. tonumber(args[1]), "admin_commands")
				end
			else
				TriggerClientEvent("ambulance", source, "Powiadomienie", "Zostałeś ożywiony przez administratora!", 'inform')
				TriggerClientEvent('hypex_ambulancejob:hypexrevive', source, true)
				exports['many-logs']:SendLog(source, "**Użyto komendy /revive**", "admin_commands")
			end
		else
			TriggerClientEvent("ambulance", source, "Powiadomienie", "Nie posiadasz permisji", 'error')
		end
	end
end, false)

ESX.RegisterServerCallback('esx_ambulancejob:getDeathStatus', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.fetchScalar('SELECT isDead FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.getIdentifier(),
	}, function(isDead)

		cb(isDead)
	end)
end)

RegisterServerEvent('esx_ambulancejob:setDeathStatus')
AddEventHandler('esx_ambulancejob:setDeathStatus', function(isDead)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if xPlayer ~= nil then
		MySQL.Sync.execute("UPDATE users SET isDead=@isDead WHERE identifier=@identifier", {
			['@identifier'] = xPlayer.identifier,
			['@isDead'] = isDead
		})
	end
end)

RegisterServerEvent('esx:ambulancejob:deathspawn')
AddEventHandler('esx:ambulancejob:deathspawn', function()
	local _source    = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	MySQL.Async.fetchAll('SELECT isDead FROM users WHERE identifier=@identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		if result[1] ~= nil then
			if result[1].isDead == 1 then
				TriggerClientEvent('esx_ambulancejob:requestDeath', _source)
			end
		end
	end)
end)

RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
	local playerId = source
	local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer ~= nil then
		MySQL.Async.fetchScalar('SELECT isDead FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.getIdentifier(),
		}, function(isDead)
            if not isDead or isDead == 0 then 
                MySQL.Async.fetchAll("SELECT health, armour FROM users WHERE identifier = ?", {xPlayer.identifier}, function(data)
                    if data[1].health ~= nil and data[1].armour ~= nil then
                        TriggerClientEvent('esx_healthnarmour:set', playerId, data[1].health, data[1].armour)
                    end
                end)
            else
                TriggerClientEvent('esx_healthnarmour:set', playerId, 0, 0)
            end
        end)
    end
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
  local xPlayer = ESX.GetPlayerFromId(playerId)
  
  if xPlayer ~= nil then
    local health = GetEntityHealth(GetPlayerPed(xPlayer.source))
    local armour = GetPedArmour(GetPlayerPed(xPlayer.source))
	MySQL.Async.execute('UPDATE users SET health = @health, armour = @armour WHERE identifier = @identifier', {
		['@health'] = health,
		['@armour'] = armour,
		['@identifier'] = xPlayer.identifier})
  	end
end)