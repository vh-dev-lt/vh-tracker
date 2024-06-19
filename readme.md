GPS Tracker

Players can view and adjust the current GPS tracker frequency.
Options to enable or disable the GPS tracker based on its current state.
Frequency Management:

Allows players to input and validate new GPS tracker frequencies.
Checks if the entered frequency is private and restricts access if necessary.
Notifications:

Provides informative notifications based on actions taken, such as enabling or disabling the tracker.
Alerts players when a GPS tracker has been removed or its functionalities disabled.
Blip Updates:

Dynamically updates map markers (blips) based on GPS tracking data received.
Ensures accurate representation of player locations and vehicle statuses on the map.

--- OX INVENTORY ITEM ---

    ['tracker'] = {
		label = 'GPS tracker',
		weight = 300,
		stack = true,
		close = true,
		description = 'GPS tracker',
		client = { 
			export = 'vh-tracker.openTracker',
			remove = function(count)
				if count <= 0 then
					exports['vh-tracker']:trackerRemoved()
				end
			end,
		}
	},
