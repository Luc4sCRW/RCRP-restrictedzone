Config = {}

Config.Locale = 'en' -- 'de', 'en' (add your own language if you want)

Config.NotifyType = 'gta' -- 'bulletin', 'esx', 'gta', 'ox', 'custom' (add your own export in the server.lua)

Config.AuthorizedJobs = {
    ['police'] = true,
    ['noose'] = true -- add or change jobs
}

Config.RadiusOptions = {
    { label = '10m', value = 10.0 },
    { label = '20m', value = 20.0 },
    { label = '30m', value = 30.0 },
    { label = '50m', value = 50.0 },
    { label = '80m', value = 80.0 },
    { label = '100m', value = 100.0 },
    { label = '150m', value = 150.0 },
    { label = '200m', value = 200.0 },
    { label = '300m', value = 300.0 },
}

Config.TimeOptions = {
    { label = '5 Min', value = 5 },
    { label = '10 Min', value = 10 },
    { label = '20 Min', value = 20 },
    { label = '30 Min', value = 30 },
    { label = '60 Min', value = 60 }
}
