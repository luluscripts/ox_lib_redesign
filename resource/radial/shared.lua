Config = Config or {}

Config.Fliptime = 10000
Config.ExtrasEnabled = true

Config.MenuItems = {
    [1] = {
        id = 'citizen',
        title = 'Genel',
        icon = 'user',
        items = {
            { id = 'getintrunk',          title = 'Bagaja Girin',   icon = 'car',                type = 'client',  event = 'qb-trunk:client:GetIn',             shouldClose = true },
            { id = 'playerout2vehicle',   title = 'Araçtan İndir',  icon = 'car-side',           type = 'client',  event = 'sairon_policejob/outFromVehicleClosest', shouldClose = true },
            { id = 'playerout3232vehicle',title = 'Araca Bindir',   icon = 'car-side',           type = 'client',  event = 'sairon_policejob/putInVehicleClosest',  shouldClose = true },
            {
                id = 'interactions', title = 'Etkileşim', icon = 'triangle-exclamation',
                items = {
                    { id = 'escort_to_front', title = 'Omzuna Al',   icon = 'user-group', type = 'command', event = 'shoulder', shouldClose = true },
                    { id = 'escort_to_back',  title = 'Kucakla',icon = 'user-group', type = 'command', event = 'piggyback', shouldClose = true },
                    { id = 'necktuck',        title = 'Ensesinden Tut', icon = 'user-group', type = 'command', event = 'necktuck', shouldClose = true },
                    { id = 'shouldersit',     title = 'Omzuna Oturt',   icon = 'user-group', type = 'command', event = 'shouldersit', shouldClose = true },
                    { id = 'swing',           title = 'Salıncak',       icon = 'user-group', type = 'command', event = 'swing', shouldClose = true },
                    { id = 'stealplayer',     title = 'Soy',       icon = 'mask',       type = 'client',  event = 'police:client:RobPlayer', shouldClose = true },
                }
            },
        }
    },
    [2] = {
        id = 'allblips',
        title = 'Blipler',
        icon = 'tags',
        items = {
            { id = 'toggle-garage-blips',   title = 'Garajlar',    icon = 'car',             type = 'client', event = 'lusttbabablips:togglegarajcek',  shouldClose = true },
            { id = 'toggle-marina-blips',   title = 'Marina',      icon = 'sailboat',        type = 'client', event = 'lusttbabablips:togglemarinacek', shouldClose = true },
            { id = 'toggle-all-blips',      title = 'Tüm Blipler', icon = 'tags',            type = 'client', event = 'lusttbabablips:toggleAll',       shouldClose = true },
            { id = 'toggle-bank-blips',     title = 'Bankalar',    icon = 'dollar-sign',     type = 'client', event = 'lusttbabablips:togglebank',      shouldClose = true },
            { id = 'toggle-gunshop-blips',  title = 'Gunshoplar',  icon = 'gun',             type = 'client', event = 'lusttbabablips:toggleGunShop',   shouldClose = true },
            { id = 'toggle-shop-blips',     title = 'Marketler',   icon = 'cart-shopping',   type = 'client', event = 'lusttbabablips:toggleMarkets',   shouldClose = true },
            { id = 'toggle-clothing-blips', title = 'Kıyafetçi',   icon = 'shirt',           type = 'client', event = 'lusttbabablips:toggleClothes',   shouldClose = true },
            { id = 'toggleTattoo',          title = 'Dövmeci',     icon = 'pen-nib',         type = 'client', event = 'lusttbabablips:toggleTattoo',    shouldClose = true },
            { id = 'toggle-barber-blips',   title = 'Berber',      icon = 'scissors',        type = 'client', event = 'lusttbabablips:toggleBarber',    shouldClose = true },
        },
    },
    [3] = {
        id = 'clothe',
        title = 'Aksesuarlar',
        icon = 'hat-cowboy',
        items = {
            { id = 'hat',     title = 'Şapka',     icon = 'hat-cowboy-side',  type = 'command', event = 'hat',    shouldClose = true },
            { id = 'glasses', title = 'Gözlük',    icon = 'glasses',          type = 'command', event = 'glasses',shouldClose = true },
            { id = 'mask',    title = 'Maske',     icon = 'masks-theater',    type = 'command', event = 'mask',   shouldClose = true },
            { id = 'reset',   title = 'Reset',     icon = 'rotate-right',     type = 'command', event = 'yenile', shouldClose = true },
            { id = 'ear',     title = 'Küpe',      icon = 'ear-listen',       type = 'command', event = 'ear',    shouldClose = true },
            { id = 'neck',    title = 'Boyunluk',  icon = 'user-tie',         type = 'command', event = 'neck',   shouldClose = true },
            { id = 'shirt',   title = 'Tshirt',    icon = 'shirt',            type = 'command', event = 'shirt',  shouldClose = true },
            { id = 'vest',    title = 'Zırh',      icon = 'vest',             type = 'command', event = 'vest',   shouldClose = true },
            { id = 'mitten',  title = 'Eldiven',   icon = 'mitten',           type = 'command', event = 'gloves', shouldClose = true },
            { id = 'bag',     title = 'Çanta',     icon = 'bag-shopping',     type = 'command', event = 'bagoff', shouldClose = true },
            { id = 'pants',   title = 'Pantolon',  icon = 'socks',            type = 'command', event = 'pants',  shouldClose = true },
            { id = 'shoes',   title = 'Ayakkabı',  icon = 'shoe-prints',      type = 'command', event = 'shoes',  shouldClose = true },
        },
    },
    [4] = {
        id = 'ekolan',
        title = 'Ek Menüler',
        icon = 'folder',
        items = {
            { id = 'fps',    title = 'FPS Menü',       icon = 'battery-quarter', type = 'command', event = 'fpsmenu',   shouldClose = true },
            { id = 'cross',  title = 'Crosshair Menü', icon = 'crosshairs',      type = 'command', event = 'crosshair', shouldClose = true },
            { id = 'araba2', title = 'Araç Kontrol',   icon = 'car',             type = 'command', event = 'carcontrolsrn',shouldClose = true },
            { id = 'araba3', title = 'Carplay',   icon = 'car',             type = 'command', event = 'carplay',shouldClose = true },
        },
    },
    [5] = {
        id = 'animation0',
        title = 'Animasyonlar',
        icon = 'person-walking',
        type = 'client',
        event = 'emotes:openMenu',
        shouldClose = true,
    },
}

Config.JobInteractions = {
    ["police"] = {
        { id = 'emergencybutton', title = 'Acil Durum Butonu', icon = 'bell',            type = 'client',  event = 'lustt:sairon2',                    shouldClose = true },
        { id = 'araccek',        title = 'Araç Çek',          icon = 'car',             type = 'command', event = 'iv',                               shouldClose = true },
        { id = 'mdt',            title = 'MDT',               icon = 'magnifying-glass', type = 'command', event = 'mdt',                              shouldClose = true },
        { id = 'object',         title = 'Obje Koy',          icon = 'traffic-light',   type = 'client',  event = 'sairon-police:lusttbabapro',        shouldClose = true },
        {
            id = 'policeinteraction', title = 'Polis Eylemleri', icon = 'list-check',
            items = {
                { id = 'checkstatus',    title = 'GSR Testi',         icon = 'question',         type = 'client',  event = 'police:client:CheckStatus',       shouldClose = true },
                { id = 'escort',         title = 'Taşı',              icon = 'user-group',        type = 'client',  event = 'police:client:EscortPlayer',      shouldClose = true },
                { id = 'arackit',        title = 'Araç Kilidi Kır',   icon = 'car-burst',         type = 'client',  event = 'police:client:LockBroke',         shouldClose = true },
                { id = 'searchplayer',   title = 'Üstünü Ara',        icon = 'magnifying-glass',  type = 'command', event = '++lusttanimasyonoynat',            shouldClose = true },
                { id = 'jailplayer',     title = 'Hapise Gönder',     icon = 'user-lock',         type = 'command', event = 'jailmenu',                        shouldClose = true },
                { id = 'societyplayer',  title = 'Kamu',              icon = 'broom',             type = 'client',  event = 'police:client:SocietyPlayer',     shouldClose = true },
                { id = 'playerinvehicle',title = 'Araca Bindir',      icon = 'car-side',          type = 'client',  event = 'police:client:PutPlayerInVehicle',shouldClose = true },
                { id = 'playeroutvehicle',title = 'Araçtan İndir',    icon = 'car-side',          type = 'client',  event = 'police:client:SetPlayerOutVehicle',shouldClose = true },
            }
        },
    },
    ["vpd"]     = "police",
    ["fbi"]     = "police",
    ["bcso"]    = "police",
    ["doj"]     = "police",
    ["vespucci"]= "police",
    ["state"]   = "police",
    ["sheriff"] = "police",
    ["ranger"]  = "police",
    ["pbso"]  = "police",
    ["ambulance"] = {
        { id = 'emergencybutton',   title = 'Acil Durum Butonu', icon = 'bell',            type = 'client',  event = 'lustt:sairon2',                       shouldClose = true },
        { id = 'mdt',               title = 'MDT',               icon = 'magnifying-glass', type = 'command', event = 'mdt',                                 shouldClose = true },
        { id = 'playerout22vehicle',title = 'Sedye Çıkar',       icon = 'bed-pulse',        type = 'client',  event = 'lustt-radial:client:TakeStretcher',   shouldClose = true },
        { id = 'playeroutv2ehicle', title = 'Sedyeyi Sil',       icon = 'bed-pulse',        type = 'client',  event = 'lustt-radial:client:RemoveStretcher', shouldClose = true },
        {
            id = 'ambeylemleri', title = 'Doktor Eylemleri', icon = 'list-check',
            items = {
                { id = 'checkstatus',     title = 'GSR Testi',       icon = 'question',        type = 'client',  event = 'police:client:CheckStatus',        shouldClose = true },
                { id = 'escort',          title = 'Taşı',            icon = 'user-group',       type = 'client',  event = 'police:client:EscortPlayer',       shouldClose = true },
                { id = 'arackit',         title = 'Araç Kilidi Kır', icon = 'car-burst',        type = 'client',  event = 'police:client:LockBroke',          shouldClose = true },
                { id = 'searchplayer',    title = 'Üstünü Ara',      icon = 'magnifying-glass', type = 'command', event = '++lusttanimasyonoynat',             shouldClose = true },
                { id = 'playerinvehicle', title = 'Araca Bindir',    icon = 'car-side',         type = 'client',  event = 'police:client:PutPlayerInVehicle', shouldClose = true },
                { id = 'playeroutvehicle',title = 'Araçtan İndir',   icon = 'car-side',         type = 'client',  event = 'police:client:SetPlayerOutVehicle',shouldClose = true },
            }
        },
    },
    ["weazel"] = {
        { id = 'newsmic',   title = 'Mikrofon',       icon = 'microphone-lines', type = 'command', event = 'e newsmic',  shouldClose = true },
        { id = 'newscam',   title = 'Kamera',         icon = 'video',            type = 'command', event = 'e newscam',  shouldClose = true },
        { id = 'newsbmic',  title = 'Boomer Mikrofon',icon = 'microphone-lines', type = 'command', event = 'e newsbmic', shouldClose = true },
        { id = 'camera',    title = 'Küçük Kamera',   icon = 'camera-retro',     type = 'command', event = 'e camera',   shouldClose = true },
        { id = 'broadcast', title = 'Broadcast',      icon = 'clapperboard',     type = 'command', event = 'weazel',     shouldClose = true },
    },
    ["taxi"] = {
        { id = 'togglemeter', title = 'Göster/Gizle Metre', icon = 'eye-slash',     type = 'client', event = 'qb-taxi:client:toggleMeter', shouldClose = false },
        { id = 'togglemouse', title = 'Başlat/Durdur Metre',icon = 'hourglass-start',type = 'client', event = 'qb-taxi:client:enableMeter', shouldClose = true },
        { id = 'npc_mission', title = 'NPC Görevi',          icon = 'taxi',          type = 'client', event = 'qb-taxi:client:DoTaxiNpc',   shouldClose = true },
    },
    ["tow"] = {
        { id = 'togglenpc', title = 'Toggle NPC',  icon = 'toggle-on',    type = 'client', event = 'jobs:client:ToggleNpc',  shouldClose = true },
        { id = 'towvehicle',title = 'Araç Çek',    icon = 'truck-pickup', type = 'client', event = 'qb-tow:client:TowVehicle',shouldClose = true },
    },
    ["mechanic"] = {
        { id = 'towvehicle', title = 'Araç Çek', icon = 'truck-pickup', type = 'client', event = 'qb-tow:client:TowVehicle', shouldClose = true },
    },
    ["hotdog"] = {
        { id = 'togglesell', title = 'Toggle Satış', icon = 'hotdog', type = 'client', event = 'qb-hotdogjob:client:ToggleSell', shouldClose = true },
    },
    ["lawyer"] = {
        { id = 'emergencybutton', title = 'Acil Durum Butonu', icon = 'bell',     type = 'client',  event = 'lustt:sairon2',             shouldClose = true },
        { id = 'araccek',        title = 'Araç Çek',           icon = 'car',      type = 'command', event = 'iv',                        shouldClose = true },
        { id = 'arackit',        title = 'Araç Kilidi Kır',    icon = 'car-burst',type = 'client',  event = 'police:client:LockBroke',   shouldClose = true },
    },
}

Config.TrunkClasses = {
    [0]  = { allowed = true,  x = 0.0, y = -1.5, z = 0.0  },
    [1]  = { allowed = true,  x = 0.0, y = -2.0, z = 0.0  },
    [2]  = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [3]  = { allowed = true,  x = 0.0, y = -1.5, z = 0.0  },
    [4]  = { allowed = true,  x = 0.0, y = -2.0, z = 0.0  },
    [5]  = { allowed = true,  x = 0.0, y = -2.0, z = 0.0  },
    [6]  = { allowed = true,  x = 0.0, y = -2.0, z = 0.0  },
    [7]  = { allowed = true,  x = 0.0, y = -2.0, z = 0.0  },
    [8]  = { allowed = false, x = 0.0, y = -1.0, z = 0.25 },
    [9]  = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [10] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [11] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [12] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [13] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [14] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [15] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [16] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [17] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [18] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [19] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [20] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
    [21] = { allowed = true,  x = 0.0, y = -1.0, z = 0.25 },
}

if not Lang then
    local _phrases = {
        ['info.wrong_ped']             = "Bu ped modeli bu seçeneği desteklemiyor",
        ['info.no_variants']           = "Bu için herhangi bir varyant bulunmuyor",
        ['info.already_wearing']       = "Zaten bunu giyiyorsun",
        ['info.nothing_to_remove']     = "Kaldıracak bir şey yok",
        ['info.switched_seats']        = "%{seat} koltuğuna geçtiniz",
        ['error.no_vehicle_found']     = "Araç bulunamadı",
        ['error.cant_enter_trunk']     = "Bu bagaja giremezsiniz",
        ['error.already_in_trunk']     = "Zaten bagajdasınız",
        ['error.someone_in_trunk']     = "Bagajda zaten biri var",
        ['error.trunk_closed']         = "Bagaj kapalı",
        ['error.not_kidnapped']        = "Bu kişiyi kaçırmadınız",
        ['error.race_harness_on']      = "Yarış kemeri takılı, geçiş yapamazsınız",
        ['error.seat_occupied']        = "Bu koltuk dolu",
        ['error.vehicle_driving_fast'] = "Araç çok hızlı gidiyor",
        ['error.no_people_nearby']     = "Yakınlarda oyuncu yok",
        ['error.stretcher_in_use']     = "Bu sedye kullanımda",
        ['error.far_away']             = "Çok uzaktasınız",
        ['error.obj_not_found']        = "Nesne oluşturulamadı",
        ['success.entered_trunk']      = "Bagajdasınız",
        ['success.extra_activated']    = "Extra %{extra} etkinleştirildi",
        ['error.extra_deactivated']    = "Extra %{extra} devre dışı bırakıldı",
        ['error.extra_not_present']    = "Bu araçta extra %{extra} yok",
        ['error.not_driver']           = "Arabanın sürücüsü değilsiniz",
        ['progress.flipping_car']      = "Araç çevriliyor...",
        ['general.get_out_trunk_button']          = "[E] Bagajdan çık",
        ['general.close_trunk_button']            = "[G] Bagajı kapat",
        ['general.open_trunk_button']             = "[G] Bagajı aç",
        ['general.push_stretcher_button']         = "[E] - Sedyeyi İt",
        ['general.stop_pushing_stretcher_button'] = "~g~E~w~ - Durdurun",
        ['general.lay_stretcher_button']          = "[G] - Sedyeye Yat",
        ['general.push_position_drawtext']        = "Buraya İt",
        ['general.get_off_stretcher_button']      = "[G] - Sedyeden Kalk",
        ['general.getintrunk_command_desc']        = "Bagaja Gir",
        ['general.putintrunk_command_desc']        = "Oyuncuyu Bagaja Koy",
    }
    Lang = {
        t = function(self, key, args)
            local str = _phrases[key] or key
            if args then
                for k, v in pairs(args) do
                    str = str:gsub('%%{' .. k .. '}', tostring(v))
                end
            end
            return str
        end
    }
end

Config.Commands = {
    ["top"]      = { Func = function() ToggleClothing("Top")          end, Desc = "Gömleği giy/çıkar" },
    ["eldiven"]  = { Func = function() ToggleClothing("gloves")       end, Desc = "Eldivenleri giy/çıkar" },
    ["visor"]    = { Func = function() ToggleProps("visor")           end, Desc = "Vizörü aç/kapat" },
    ["bag"]      = { Func = function() ToggleClothing("Bag")          end, Desc = "Çantayı giy/çıkar" },
    ["shoes"]    = { Func = function() ToggleClothing("Shoes")        end, Desc = "Ayakkabıyı giy/çıkar" },
    ["vest"]     = { Func = function() ToggleClothing("Vest")         end, Desc = "Zırhı giy/çıkar" },
    ["hair"]     = { Func = function() ToggleClothing("hair")         end, Desc = "Saçı değiştir" },
    ["hat"]      = { Func = function() ToggleProps("Hat")             end, Desc = "Şapkayı giy/çıkar" },
    ["glasses"]  = { Func = function() ToggleProps("Glasses")         end, Desc = "Gözlüğü tak/çıkar" },
    ["ear"]      = { Func = function() ToggleProps("Ear")             end, Desc = "Küpeyi tak/çıkar" },
    ["neck"]     = { Func = function() ToggleClothing("Neck")         end, Desc = "Boyunluğu tak/çıkar" },
    ["watch"]    = { Func = function() ToggleProps("Watch")           end, Desc = "Saati tak/çıkar" },
    ["bracelet"] = { Func = function() ToggleProps("Bracelet")        end, Desc = "Bileziği tak/çıkar" },
    ["mask"]     = { Func = function() ToggleClothing("Mask")         end, Desc = "Maskeyi tak/çıkar" },
    ["gloves"]   = { Func = function() ToggleClothing("gloves")       end, Desc = "Eldiveni giy/çıkar" },
    ["üst"]      = { Func = function() ToggleClothing("Top")          end, Desc = "Gömleği giy/çıkar" },
    ["eldiven"]  = { Func = function() ToggleClothing("gloves")       end, Desc = "Eldivenleri giy/çıkar" },
    ["vizör"]    = { Func = function() ToggleProps("visor")           end, Desc = "Vizörü aç/kapat" },
    ["çanta"]    = { Func = function() ToggleClothing("Bag")          end, Desc = "Çantayı giy/çıkar" },
    ["ayakkabı"] = { Func = function() ToggleClothing("Shoes")        end, Desc = "Ayakkabıyı giy/çıkar" },
    ["zırh"]     = { Func = function() ToggleClothing("Vest")         end, Desc = "Zırhı giy/çıkar" },
    ["saç"]      = { Func = function() ToggleClothing("hair")         end, Desc = "Saçı değiştir" },
    ["şapka"]    = { Func = function() ToggleProps("Hat")             end, Desc = "Şapkayı giy/çıkar" },
    ["gözlük"]   = { Func = function() ToggleProps("Glasses")         end, Desc = "Gözlüğü tak/çıkar" },
    ["küpe"]     = { Func = function() ToggleProps("Ear")             end, Desc = "Küpeyi tak/çıkar" },
    ["boyunluk"] = { Func = function() ToggleClothing("Neck")         end, Desc = "Boyunluğu tak/çıkar" },
    ["saat"]     = { Func = function() ToggleProps("Watch")           end, Desc = "Saati tak/çıkar" },
    ["bilezik"]  = { Func = function() ToggleProps("Bracelet")        end, Desc = "Bileziği tak/çıkar" },
    ["maske"]    = { Func = function() ToggleClothing("Mask")         end, Desc = "Maskeyi tak/çıkar" },
    ["eldiven"]  = { Func = function() ToggleClothing("gloves")       end, Desc = "Eldiveni giy/çıkar" },
}

local bags = { [40] = true, [41] = true, [44] = true, [45] = true }

Config.ExtraCommands = {
    ["pants"] = {
        Func = function() ToggleClothing("Pants", true) end,
        Desc = "Pantolonu giy/çıkar",
    },
    ["shirt"] = {
        Func = function() ToggleClothing("Shirt", true) end,
        Desc = "Tişörtü giy/çıkar",
    },
    ["bagoff"] = {
        Func = function() ToggleClothing("Bagoff", true) end,
        Desc = "Çantayı tak/çıkar",
    },
}
