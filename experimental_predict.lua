-- Standalone gamesense UI extracted from output_outlaw_beta (1).lua.
-- This version of the original script contains no prediction algorithm
-- connected to this control. These are labels, not automatic ping checks.
-- Load this file normally; the control appears under LUA -> B.

local predict = ui.new_combobox(
    "LUA", "B",
    "\aFF6363FFExperimental \aCDCDCDFFPredict",
    "Off",
    "High Ping > 60",
    "Low Ping < 45"
)

-- The selected value is persisted by gamesense's normal UI/config system.
-- No command, network, prediction, or Double Tap setting is modified.
return predict
