if GetResourceKvpInt('reset_locale') ~= 1 then
    DeleteResourceKvp('locale')
    SetResourceKvpInt('reset_locale', 1)
end

---@generic T
---@param fn fun(key): unknown
---@param key string
---@param default? T
---@return T
local function safeGetKvp(fn, key, default)
    local ok, result = pcall(fn, key)

    if not ok then
        return DeleteResourceKvp(key)
    end

    return result or default
end

local defaultTheme = { accent = '#FF6FAE', text = '#F8F6FA', bg = '#17151C', opacity = 100 }

local function isHex(v) return type(v) == 'string' and v:match('^#%x%x%x%x%x%x$') ~= nil end

local function normalizeTheme(t)
    t = type(t) == 'table' and t or {}
    return {
        accent = isHex(t.accent) and t.accent:upper() or defaultTheme.accent,
        text = isHex(t.text) and t.text:upper() or defaultTheme.text,
        bg = isHex(t.bg) and t.bg:upper() or defaultTheme.bg,
        opacity = math.max(40, math.min(100, tonumber(t.opacity) or defaultTheme.opacity)),
    }
end

local function loadTheme()
    local raw = safeGetKvp(GetResourceKvpString, 'ui_theme')
    return normalizeTheme(raw and json.decode(raw) or nil)
end

local settings = {
    default_locale = GetConvar('ox:locale', 'tr'),
    notification_position = safeGetKvp(GetResourceKvpString, 'notification_position', 'top'),
    notification_audio = safeGetKvp(GetResourceKvpInt, 'notification_audio') == 1,
    ui_theme = loadTheme(),
}

local userLocales = GetConvarInt('ox:userLocales', 1) == 1

settings.locale = userLocales and safeGetKvp(GetResourceKvpString, 'locale') or settings.default_locale

local function set(key, value)
    if settings[key] == value then return false end

    settings[key] = value
    local valueType = type(value)

    if valueType == 'nil' then
        DeleteResourceKvp(key)
    elseif valueType == 'string' then
        SetResourceKvp(key, value)
    elseif valueType == 'table' then
        SetResourceKvp(key, json.encode(value))
    elseif valueType == 'number' then
        SetResourceKvpInt(key, value)
    elseif valueType == 'boolean' then
        SetResourceKvpInt(key, value and 1 or 0)
    else
        return false
    end

    return true
end

RegisterNUICallback('uiReady', function(_, cb)
    cb(settings.ui_theme)
end)

local function L(key, fallback)
    local text = locale(key)
    if not text or text == key then return fallback end
    return text
end

RegisterCommand('ox_lib', function()
    local inputSettings = {
        {
            type = 'checkbox',
            label = locale('ui.settings.notification_audio'),
            checked = settings.notification_audio,
        },
        {
            type = 'select',
            label = locale('ui.settings.notification_position'),
            options = {
                { label = locale('ui.position.top-right'),    value = 'top-right' },
                { label = locale('ui.position.top'),          value = 'top' },
                { label = locale('ui.position.top-left'),     value = 'top-left' },
                { label = locale('ui.position.center-right'), value = 'center-right' },
                { label = locale('ui.position.center-left'),  value = 'center-left' },
                { label = locale('ui.position.bottom-right'), value = 'bottom-right' },
                { label = locale('ui.position.bottom'),       value = 'bottom' },
                { label = locale('ui.position.bottom-left'),  value = 'bottom-left' },
            },
            default = settings.notification_position,
            required = true,
            icon = 'message',
        },
        {
            type = 'color',
            label = L('ui.settings.ui_accent', 'Accent color'),
            description = L('ui.settings.ui_accent_description', 'Buttons, highlights and icons'),
            default = settings.ui_theme.accent,
        },
        {
            type = 'color',
            label = L('ui.settings.ui_text', 'Text color'),
            default = settings.ui_theme.text,
        },
        {
            type = 'color',
            label = L('ui.settings.ui_bg', 'Background color'),
            default = settings.ui_theme.bg,
        },
        {
            type = 'slider',
            label = L('ui.settings.ui_opacity', 'Background opacity'),
            min = 40,
            max = 100,
            step = 5,
            default = settings.ui_theme.opacity,
        },
        {
            type = 'button',
            label = L('ui.settings.ui_reset', 'Reset colors to default'),
            resets = {
                { index = 2, value = defaultTheme.accent },
                { index = 3, value = defaultTheme.text },
                { index = 4, value = defaultTheme.bg },
                { index = 5, value = defaultTheme.opacity },
            },
        },
    }

    if userLocales then
        table.insert(inputSettings,
            {
                type = 'select',
                label = locale('ui.settings.locale'),
                searchable = true,
                description = locale('ui.settings.locale_description', settings.locale),
                options = GlobalState['ox_lib:locales'],
                default = settings.locale,
                required = true,
                icon = 'book',
            })
    end

    local input = lib.inputDialog(locale('settings'), inputSettings) --[[@as table?]]

    if not input then return end

    ---@type boolean, string, string, string, string, number, boolean, string
    local notification_audio, notification_position, accent, text, bg, opacity, _, locale = table.unpack(input)

    if userLocales and locale and set('locale', locale) then lib.setLocale(locale) end

    set('notification_position', notification_position)
    set('notification_audio', notification_audio)

    local theme = normalizeTheme({ accent = accent, text = text, bg = bg, opacity = opacity })
    if set('ui_theme', theme) then
        SendNUIMessage({ action = 'setTheme', data = theme })
    end
end)

RegisterCommand('ox_lib_resetui', function()
    local theme = normalizeTheme(nil)
    set('ui_theme', theme)
    SendNUIMessage({ action = 'setTheme', data = theme })
end)

return settings
