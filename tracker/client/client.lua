-- Main
local createdBlips = {}
local serverId = cache.serverId

lib.onCache('serverId', function(value)
	serverId = value
end)

-- Tracker control
function openTracker(data, slot)
	local options = {}

	local isEnabled = isEnabled or false
	local trackId = trackId or false

	if trackId then
		options[#options + 1] = { title = ('Current GPS tracker frequency: %s'):format(trackId) }
	end

	options[#options + 1] = { 
		title = 'Enter GPS tracker frequency',
		onSelect = openTrackIdControl
	}
	
	options[#options + 1] = { 
		title = isEnabled and 'Disable GPS tracker' or 'Enable GPS tracker',
		onSelect = function()
			toggleTracker(not isEnabled)
		end,
	}

	lib.registerContext({
		id = 'vh-tracker:openTracker',
		title = 'GPS tracker management',
		options = options
	})
	
	lib.showContext('vh-tracker:openTracker')
end

function openTrackIdControl()
	local input = lib.inputDialog('Frequency management', {'GPS tracker frequency'})

	if input then 
		local newTrackId = tonumber(input[1])
		local isAllowed = true

		if Tracker.PrivateChannels[newTrackId] then
			isAllowed = false
			local playerJob = ESX.PlayerData.job.name

			for _, job in pairs(Tracker.PrivateChannels[newTrackId]) do
				if playerJob == job and exports.esx_service:isInService(job) then
					isAllowed = true
					break
				end
			end
		end

		if isAllowed then
			if isEnabled and trackId and newTrackId ~= trackId then
				TriggerServerEvent('vh-tracker:remove', trackId)
			end

			trackId = newTrackId

			if isEnabled then
				TriggerServerEvent('vh-tracker:add', trackId)
			end
		else
			ESX.ShowNotification('This frequency is private and you cannot connect to it!', 'error') 
		end
	end

	openTracker()
end

function toggleTracker(newToggle, newTrackId)
	if newToggle then
		if newTrackId then
			if isEnabled and newTrackId ~= trackId then
				TriggerServerEvent('vh-tracker:remove', trackId)
			end

			trackId = newTrackId
		end
		
		if not trackId then 
			ESX.ShowNotification('Before enabling GPS tracker, you must enter the tracker frequency!', 'error') 
			return openTracker()
		end
	end

	isEnabled = newToggle

	if isEnabled then
		ESX.ShowNotification(('Successfully enabled your GPS tracker, your frequency is %s.'):format(trackId), 'success') 
		TriggerServerEvent('vh-tracker:add', trackId)
	else
		ESX.ShowNotification('Successfully disabled your GPS tracker.', 'success') 
		TriggerServerEvent('vh-tracker:remove', trackId)
	end

	openTracker()
end

function trackerRemoved()
	if isEnabled then
		ESX.ShowNotification('You no longer have a GPS tracker, so all GPS tracker functionalities have been disabled!', 'error') 
		TriggerServerEvent('vh-tracker:remove', trackId)
		isEnabled = false
	end
end


-- Function exports
exports('openTracker', openTracker)
exports('openTrackIdControl', openTrackIdControl)
exports('toggleTracker', toggleTracker)
exports('trackerRemoved', trackerRemoved)

-- Tracker blips updating
RegisterNetEvent('vh-tracker:update', function(blips)
	for playerId, blip in pairs(createdBlips) do
		if not blips[playerId] then
			RemoveBlip(blip)
			print('removed')
			createdBlips[playerId] = nil
		end

		Wait(0)
	end

	if not isEnabled or not blips then
		return
	end

	for playerId, v in pairs(blips) do

		if playerId ~= serverId then
			if createdBlips[playerId] then

				local createdBlip = createdBlips[playerId]

				SetBlipCoords(createdBlip, v.coords)
				SetBlipSprite(createdBlip, v.vehicle and 326 or 1)
				SetBlipRotation(createdBlip, math.ceil(v.heading))
				SetBlipAsShortRange(createdBlip, true)
				SetBlipColour(createdBlip, 0)
				
				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(v.name)
				EndTextCommandSetBlipName(createdBlip)
			else
				local blip = AddBlipForCoord(v.coords)
				SetBlipSprite(blip, v.vehicle and 326 or 1)
				ShowHeadingIndicatorOnBlip(blip, true)
				SetBlipRotation(blip, math.ceil(v.heading))
				SetBlipScale(blip, 0.6)
				SetBlipAsShortRange(blip, true)
				SetBlipColour(blip, 0)

				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(v.name)
				EndTextCommandSetBlipName(blip)

				createdBlips[playerId] = blip
			end
		end

		Wait(0)
	end
end)
