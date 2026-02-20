Locales = {}

function i18n(str, ...)
    local args = {...}
    if not str then return 'Key nil' end

    local localeCfg = Locales[Config.Locale]
    local translation = localeCfg and localeCfg[str] or (Locales['en'] and Locales['en'][str])

    if translation then
        local _, count = translation:gsub("%%s", "")
        if count > 0 and #args == 0 then
            return translation
        end
        return string.format(translation, ...)
    end

    return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
end

function _U(str, ...)
    return i18n(str, ...)
end
