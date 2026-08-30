Config = {}

Config.Locale = "en" -- "de", "en" (add your own language if you want)

Config.NotifyType = "gta" -- "bulletin", "esx", "gta", "ox", "custom" (next update will fix ox message and esx message) | Recommendation: BULLETIN, GTA! | add your own export in the server.lua

Config.AuthorizedJobs = {
    ["police"] = {
        label = "Los Santos Police Department",
        blipColor = 3, -- Blue
        menuTitle = "LSPD",
        icon = "CHAR_CALL911",
        deleteOther = false -- If set to “false” that job is only allowed to remove its own restricted zones
    },
    ["noose"] = {
        label = "NOOSE Tactical Unit",
        blipColor = 5, -- Yellow
        menuTitle = "NOOSE",
        icon = "CHAR_CALL911",
        deleteOther = true
    },
    ["ambulance"] = {
        label = "San Andreas Medical Services",
        blipColor = 6, -- Light Red
        menuTitle = "SAMS",
        icon = "CHAR_CALL911",
        deleteOther = false
    },
    ["lsfd"] = {
        label = "Los Santos Fire Department",
        blipColor = 1, -- Red
        menuTitle = "LSFD",
        icon = "CHAR_CALL911",
        deleteOther = false
    }
}

Config.RadiusOptions = {
    { label = "10m", value = 10.0 },
    { label = "20m", value = 20.0 },
    { label = "30m", value = 30.0 },
    { label = "50m", value = 50.0 },
    { label = "80m", value = 80.0 },
    { label = "100m", value = 100.0 },
    { label = "150m", value = 150.0 },
    { label = "200m", value = 200.0 },
    { label = "300m", value = 300.0 },
}

Config.TimeOptions = {
    { label = "5 Min", value = 5 },
    { label = "10 Min", value = 10 },
    { label = "20 Min", value = 20 },
    { label = "30 Min", value = 30 },
    { label = "60 Min", value = 60 }
}
