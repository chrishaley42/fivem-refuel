fx_version 'cerulean'
games      { 'gta5' }

--
-- Server
--

server_scripts {
    'config.lua',
    'server/server.lua',
}

--
-- Client
--

client_scripts {
    'config.lua',
    'client/client.lua',
}

dependency 'es_extended'