fx_version "cerulean"

games {"gta5"}
lua54 'yes'
description 'esx_ambulancejob'
version '2.0'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'config.lua',
	'client/main.lua',
	'client/beds.lua'
}


exports {
	'isDead',
	'IsBlockWeapon'
}

shared_script '@ox_lib/init.lua'

dependency 'es_extended'