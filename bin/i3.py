#!/usr/bin/env python3


from threading import Timer
import i3ipc
import json

batteryIntervalSec = 600

workspaceStatus = "         " #          
batteryStatus = "" # full, charging, discharging
batteryCharge = 1.0 # out of 1.0


def render():
	statusText = workspaceStatus
	if batteryStatus != "full":
		secondaryColor = "ffb86c" if batteryStatus == "discharging" else "8be9fd"
		batteryWidth = round(batteryCharge * len(workspaceStatus))
		statusText = "%{o#ffffff +o}" + statusText[:batteryWidth] \
					 + "%{o#" + secondaryColor + "}" \
					 + statusText[batteryWidth:] + "%{-o}" \
					 + " {0:.0%}".format(batteryCharge)

	print(statusText)


i3 = i3ipc.Connection()

def updateWorkspaceStatus():
	global workspaceStatus

	activeWorkspaces = []
	focusedWorkspace = -1
	for j in i3.get_workspaces():
		activeWorkspaces.append(j.num)
		if j.focused:
			focusedWorkspace = j.num
	statusText = ""
	for i in range(1, 11):
		if i == focusedWorkspace:
			statusText += " "
		elif i in activeWorkspaces:
			statusText += " "
		else:
			statusText += " "
	workspaceStatus = statusText.strip()

# Subscribe to events
def handleWorkspaceUpdate(self, e):
	updateWorkspaceStatus()
	render()


def updateBatteryStatus():
	global batteryStatus, batteryCharge

	with open("/sys/class/power_supply/BAT0/status", 'r') as f:
		batteryStatus = f.readlines()[0].lower().strip()

	if batteryStatus != "full":
		with open("/sys/class/power_supply/BAT0/charge_full", 'r') as f:
			chargeFull = int(f.readlines()[0].strip())
		with open("/sys/class/power_supply/BAT0/charge_now", 'r') as f:
			chargeNow = int(f.readlines()[0].strip())

		batteryCharge = chargeNow / chargeFull

	Timer(batteryIntervalSec, updateBatteryStatus).start()
	render()


# updateWorkspaceStatus()
updateBatteryStatus()

i3.on('workspace::focus', handleWorkspaceUpdate)

# Start the main loop and wait for events to come in.
i3.main()

