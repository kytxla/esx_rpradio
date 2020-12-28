ESX = nil
local PlayerData = {}
local onkoradio = false
local radiossa = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while PlayerData.job == nil do
		Citizen.Wait(1000)
		PlayerData = ESX.GetPlayerData()
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

function OpenRadioMenu()

	local elements = {}
		
	if PlayerData.job.name == 'police' then
		table.insert(elements, { label = 'Poliisi', value = 1})
		table.insert(elements, { label = 'Sheriffi', value = 2})
		table.insert(elements, { label = 'Ensihoito', value = 3})
	elseif PlayerData.job.name == 'ambulance' then
		table.insert(elements, { label = 'Ensihoito', value = 3})
	elseif PlayerData.job.name == 'mechanic' then
		table.insert(elements, { label = 'Mekaanikko', value = 4})
	elseif PlayerData.job.name == 'taxi' then
		table.insert(elements, { label = 'Taksi', value = 5})
	end
		
	table.insert(elements, { label = 'Liity avoimelle taajuudelle', value = 'avoin'}) 
	table.insert(elements, { label = 'Poistu radiotaajuudelta', value = 'poistu'}) 
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'radio',
		{
		title    = 'radiossa',
		align    = 'bottom-right',
		elements = elements,
		},

		function(data, menu)
		
		menu.close()
		
		if radiossa ~= nil then
			exports.tokovoip_script:removePlayerFromRadio(radiossa)
			radiossa = nil
		end
		
		if data.current.value == 'avoin' then
			AddTextEntry('FMMC_KEY_TIP8', "Taajuus 5.1-99.9")
			DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 4)
			while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
				Citizen.Wait(0)
			end
			local testaa = GetOnscreenKeyboardResult()
			testaa = tonumber(testaa)
			Citizen.Wait(150)
			if testaa ~= nil and testaa > 5 and testaa < 100 then
				radiossa = testaa
				exports.tokovoip_script:addPlayerToRadio(radiossa, true)
				ESX.ShowNotification('~g~Sinun taajuus:~w~ '..radiossa)
			else
				ESX.ShowNotification('~r~Virheellinen taajuus!')
			end
		elseif data.current.value == 'poistu' then
		else
			radiossa = data.current.value
			exports.tokovoip_script:addPlayerToRadio(radiossa, true)
		end
		
		CurrentAction     = 'radio'
		CurrentActionMsg  = 'radiossa'
		CurrentActionData = {}

		end,
	
	function(data, menu)

		menu.close()

		CurrentAction     = 'radio'
		CurrentActionMsg  = 'radiossa'
		CurrentActionData = {}
	end)
end

RegisterNetEvent('esx_radio:onkoradio')
AddEventHandler('esx_radio:onkoradio', function(onkovaiei)
	onkoradio = onkovaiei
	if not onkoradio then
		if radiossa ~= nil then
--			if PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'mecano' or PlayerData.job.name == 'taxi' then
--			else
				exports.tokovoip_script:removePlayerFromRadio(radiossa)
				radiossa = nil
--			end
		end
	end
end)

RegisterNetEvent('esx_radio:radio')
AddEventHandler('esx_radio:radio', function()
	OpenRadioMenu()
end)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function()
	if radiossa ~= nil then
	exports.tokovoip_script:removePlayerFromRadio(radiossa)
		radiossa = nil
	end
end)
