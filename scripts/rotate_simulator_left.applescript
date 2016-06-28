tell application "System Events"
	
	tell process "Simulator"
		
		tell menu bar 1
			tell menu bar item "Hardware"
				tell menu "Hardware"
					click menu item "Rotate Left"
				end tell
			end tell
		end tell
	end tell
end tell
