tell application "System Events"
	
	tell process "iPhone Simulator"
		
		tell menu bar 1
			tell menu bar item "Hardware"
				tell menu "Hardware"
					click menu item "Rotate Right"
				end tell
			end tell
		end tell
	end tell
end tell
