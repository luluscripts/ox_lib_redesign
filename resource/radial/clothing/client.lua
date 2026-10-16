local variations = {
	jackets = { male = {}, female = {} },
	hair    = { male = {}, female = {} },
	bags    = { male = {}, female = {} },
	visor   = { male = {}, female = {} },
	gloves  = {
		male = {
			[16]=4,[17]=4,[18]=4,[19]=0,[20]=1,[21]=2,[22]=4,[23]=5,[24]=6,[25]=8,[26]=11,[27]=12,[28]=14,[29]=15,
			[30]=0,[31]=1,[32]=2,[33]=4,[34]=5,[35]=6,[36]=8,[37]=11,[38]=12,[39]=14,[40]=15,[41]=0,[42]=1,[43]=2,
			[44]=4,[45]=5,[46]=6,[47]=8,[48]=11,[49]=12,[50]=14,[51]=15,[52]=0,[53]=1,[54]=2,[55]=4,[56]=5,[57]=6,
			[58]=8,[59]=11,[60]=12,[61]=14,[62]=15,[63]=0,[64]=1,[65]=2,[66]=4,[67]=5,[68]=6,[69]=8,[70]=11,[71]=12,
			[72]=14,[73]=15,[74]=0,[75]=1,[76]=2,[77]=4,[78]=5,[79]=6,[80]=8,[81]=11,[82]=12,[83]=14,[84]=15,[85]=0,
			[86]=1,[87]=2,[88]=4,[89]=5,[90]=6,[91]=8,[92]=11,[93]=12,[94]=14,[95]=15,[96]=4,[97]=4,[98]=4,[99]=0,
			[100]=1,[101]=2,[102]=4,[103]=5,[104]=6,[105]=8,[106]=11,[107]=12,[108]=14,[109]=15,[110]=4,[111]=4,
			[115]=112,[116]=112,[117]=112,[118]=112,[119]=112,[120]=112,[121]=112,[122]=113,[123]=113,[124]=113,
			[125]=113,[126]=113,[127]=113,[128]=113,[129]=114,[130]=114,[131]=114,[132]=114,[133]=114,[134]=114,
			[135]=114,[136]=15,[137]=15,[138]=0,[139]=1,[140]=2,[141]=4,[142]=5,[143]=6,[144]=8,[145]=11,[146]=12,
			[147]=14,[148]=112,[149]=113,[150]=114,[151]=0,[152]=1,[153]=2,[154]=4,[155]=5,[156]=6,[157]=8,[158]=11,
			[159]=12,[160]=14,[161]=112,[162]=113,[163]=114,[165]=4,[166]=4,[167]=4,[168]=4,[170]=15,[171]=0,[172]=1,
			[173]=2,[174]=4,[175]=5,[176]=6,[177]=8,[178]=11,[179]=12,[180]=14,[181]=112,[182]=113,[183]=114,
			[185]=184,[186]=184,[187]=184,[188]=184,[189]=185,[190]=184,[191]=184,[192]=184,[193]=184,[194]=184,
		},
		female = {
			[16]=11,[17]=3,[18]=3,[19]=3,[20]=0,[21]=1,[22]=2,[23]=3,[24]=4,[25]=5,[26]=6,[27]=7,[28]=9,[29]=11,
			[30]=12,[31]=14,[32]=15,[33]=0,[34]=1,[35]=2,[36]=3,[37]=4,[38]=5,[39]=6,[40]=7,[41]=9,[42]=11,[43]=12,
			[44]=14,[45]=15,[46]=0,[47]=1,[48]=2,[49]=3,[50]=4,[51]=5,[52]=6,[53]=7,[54]=9,[55]=11,[56]=12,[57]=14,
			[58]=15,[59]=0,[60]=1,[61]=2,[62]=3,[63]=4,[64]=5,[65]=6,[66]=7,[67]=9,[68]=11,[69]=12,[70]=14,[71]=15,
			[72]=0,[73]=1,[74]=2,[75]=3,[76]=4,[77]=5,[78]=6,[79]=7,[80]=9,[81]=11,[82]=12,[83]=14,[84]=15,[85]=0,
			[86]=1,[87]=2,[88]=3,[89]=4,[90]=5,[91]=6,[92]=7,[93]=9,[94]=11,[95]=12,[96]=14,[97]=15,[98]=0,[99]=1,
			[100]=2,[101]=3,[102]=4,[103]=5,[104]=6,[105]=7,[106]=9,[107]=11,[108]=12,[109]=14,[110]=15,[111]=3,
			[112]=3,[113]=3,[114]=0,[115]=1,[116]=2,[117]=3,[118]=4,[119]=5,[120]=6,[121]=7,[122]=9,[123]=11,
			[124]=12,[125]=14,[126]=15,[127]=3,[128]=3,[132]=129,[133]=129,[134]=129,[135]=129,[136]=129,[137]=129,
			[138]=129,[139]=130,[140]=130,[141]=130,[142]=130,[143]=130,[144]=130,[145]=130,[146]=131,[147]=131,
			[148]=131,[149]=131,[150]=131,[151]=131,[152]=131,[154]=153,[155]=153,[156]=153,[157]=153,[158]=153,
			[159]=153,[160]=153,[162]=161,[163]=161,[164]=161,[165]=161,[166]=161,[167]=161,[168]=161,[169]=15,
			[170]=15,[171]=0,[172]=1,[173]=2,[174]=3,[175]=4,[176]=5,[177]=6,[178]=7,[179]=9,[180]=11,[181]=12,
			[182]=14,[183]=129,[184]=130,[185]=131,[186]=153,[187]=0,[188]=1,[189]=2,[190]=3,[191]=4,[192]=5,
			[193]=6,[194]=7,[195]=9,[196]=11,[197]=12,[198]=14,[199]=129,[200]=130,[201]=131,[202]=153,[203]=161,
			[204]=161,[206]=3,[207]=3,[208]=3,[209]=3,[211]=15,[212]=0,[213]=1,[214]=2,[215]=3,[216]=4,[217]=5,
			[218]=6,[219]=7,[220]=9,[221]=11,[222]=12,[223]=14,[224]=129,[225]=130,[226]=131,[227]=153,[228]=161,
			[230]=229,[231]=229,[232]=229,[233]=229,[234]=229,[235]=229,[236]=229,[237]=229,[238]=229,[239]=229,
		}
	}
}

local function addNewVariation(which, gender, one, two, single)
	local where = variations[which][gender]
	if not single then where[one] = two; where[two] = one
	else where[one] = two end
end

CreateThread(function()
	for _, v in ipairs({
		{9,10},{18,67},{82,67},{44,45},{50,68},{51,69},{52,70},{53,71},{62,72},{65,66},
		{73,74},{76,77},{79,78},{80,81},{91,92},{104,105},{109,110},{116,117},{118,119},
		{123,124},{125,126},{127,128},{130,131},{135,136},{137,138},{139,140},{142,143},
		{147,148},{151,152},
	}) do addNewVariation('visor','male',v[1],v[2]) end
	for _, v in ipairs({
		{43,44},{49,67},{64,65},{65,64},{51,69},{50,68},{52,70},{62,71},{72,73},{75,76},
		{78,77},{79,80},{18,66},{66,81},{81,66},{86,84},{90,91},{103,104},{108,109},
		{115,116},{117,118},{122,123},{124,125},{126,127},{129,130},{134,135},{136,137},
		{138,139},{141,142},{146,147},{150,151},
	}) do addNewVariation('visor','female',v[1],v[2]) end
	for _, v in ipairs({{45,44},{41,40},{82,81},{86,85}}) do
		addNewVariation('bags','male',v[1],v[2])
		addNewVariation('bags','female',v[1],v[2])
	end
	for _, v in ipairs({
		{7,15,true},{43,15,true},{9,43,true},{11,43,true},{15,43,true},{16,43,true},
		{17,43,true},{20,43,true},{22,43,true},{45,43,true},{47,43,true},{49,43,true},
		{51,43,true},{52,43,true},{53,43,true},{56,43,true},{58,43,true},
	}) do addNewVariation('hair','male',v[1],v[2],v[3]) end
	for _, v in ipairs({
		{1,49,true},{2,49,true},{7,49,true},{9,49,true},{10,49,true},{11,48,true},
		{14,53,true},{15,42,true},{21,42,true},{23,42,true},{31,53,true},{39,49,true},
		{40,49,true},{42,53,true},{45,49,true},{48,49,true},{49,48,true},{52,53,true},
		{53,42,true},{54,55,true},{59,42,true},{59,54,true},{68,53,true},{76,48,true},
	}) do addNewVariation('hair','female',v[1],v[2],v[3]) end
	for _, v in ipairs({
		{29,30},{31,32},{42,43},{59,60},{68,69},{74,75},{87,88},{93,94},{99,100},{101,102},
		{103,104},{126,127},{129,130},{131,132},{184,185},{188,189},{194,195},{196,197},
		{198,199},{200,203},{202,205},{206,207},{209,212},{210,211},{217,218},{229,230},
		{232,233},{235,236},{241,242},{251,253},{256,261},{262,263},{265,266},{267,268},
		{279,280},{292,293},{294,295},{296,297},{300,303},{301,302},{305,306},{311,312},
		{314,315},{316,317},{318,319},{321,322},{330,331},{336,337},{339,126},{340,341},
		{343,344},{346,234},{347,260},{348,349},{352,353},{354,355},{359,360},
	}) do addNewVariation('jackets','male',v[1],v[2]) end
	for _, v in ipairs({
		{53,52},{57,58},{62,63},{84,85},{90,91},{92,93},{94,95},{117,118},{120,121},
		{128,129},{187,186},{190,191},{196,197},{198,199},{200,201},{202,205},{204,207},
		{210,211},{213,216},{214,215},{225,226},{227,228},{239,240},{242,243},{244,364},
		{245,246},{249,250},{259,261},{265,270},{271,272},{274,275},{276,277},{280,281},
		{292,293},{305,306},{307,308},{311,314},{312,313},{316,317},{325,326},{327,328},
		{329,330},{332,333},{339,340},{345,346},{351,352},{354,121},{355,356},{357,359},
		{358,360},{362,363},{366,367},{365,269},{370,371},{372,373},{378,379},
	}) do addNewVariation('jackets','female',v[1],v[2]) end
end)

local drawables = {
	['Top']   = { Drawable=11, Table=variations.jackets, Emote={Dict='missmic4',Anim='michael_tux_fidget',Move=51,Dur=1500} },
	['gloves']= { Drawable=3,  Table=variations.gloves,  Remember=true, Emote={Dict='nmt_3_rcm-10',Anim='cs_nigel_dual-10',Move=51,Dur=1200} },
	['Shoes'] = { Drawable=6,  Table={Standalone=true,male=34,female=35}, Emote={Dict='random@domestic',Anim='pickup_low',Move=0,Dur=1200} },
	['Neck']  = { Drawable=7,  Table={Standalone=true,male=0,female=0},   Emote={Dict='clothingtie',Anim='try_tie_positive_a',Move=51,Dur=2100} },
	['Vest']  = { Drawable=9,  Table={Standalone=true,male=0,female=0},   Emote={Dict='clothingtie',Anim='try_tie_negative_a',Move=51,Dur=1200} },
	['Bag']   = { Drawable=5,  Table=variations.bags,   Emote={Dict='anim@heists@ornate_bank@grab_cash',Anim='intro',Move=51,Dur=1600} },
	['Mask']  = { Drawable=1,  Table={Standalone=true,male=0,female=0},   Emote={Dict='mp_masks@standard_car@ds@',Anim='put_on_mask',Move=51,Dur=800} },
	['hair']  = { Drawable=2,  Table=variations.hair,   Remember=true, Emote={Dict='clothingtie',Anim='check_out_a',Move=51,Dur=2000} },
}

local Extras = {
	['Shirt']  = { Drawable=11, Table={Standalone=true,male=0,female=0,Extra={{Drawable=8,Id=0,Tex=0,Name='Extra Undershirt'},{Drawable=3,Id=0,Tex=0,Name='Extra Gloves'},{Drawable=10,Id=0,Tex=0,Name='Extra Decals'}}}, Emote={Dict='clothingtie',Anim='try_tie_negative_a',Move=51,Dur=1200} },
	['Pants']  = { Drawable=4,  Table={Standalone=true,male=21,female=294}, Emote={Dict='re@construction',Anim='out_of_breath',Move=51,Dur=1300} },
	['Bagoff'] = { Drawable=5,  Table={Standalone=true,male=0,female=0},    Emote={Dict='clothingtie',Anim='try_tie_negative_a',Move=51,Dur=1200} },
}

local Props = {
	['visor']   = { Prop=0, Variants=variations.visor, Emote={On={Dict='mp_masks@standard_car@ds@',Anim='put_on_mask',Move=51,Dur=600},Off={Dict='missheist_agency2ahelmet',Anim='take_off_helmet_stand',Move=51,Dur=1200}} },
	['Hat']     = { Prop=0, Emote={On={Dict='mp_masks@standard_car@ds@',Anim='put_on_mask',Move=51,Dur=600},Off={Dict='missheist_agency2ahelmet',Anim='take_off_helmet_stand',Move=51,Dur=1200}} },
	['Glasses'] = { Prop=1, Emote={On={Dict='clothingspecs',Anim='take_off',Move=51,Dur=1400},Off={Dict='clothingspecs',Anim='take_off',Move=51,Dur=1400}} },
	['Ear']     = { Prop=2, Emote={On={Dict='mp_cp_stolen_tut',Anim='b_think',Move=51,Dur=900},Off={Dict='mp_cp_stolen_tut',Anim='b_think',Move=51,Dur=900}} },
	['Watch']   = { Prop=6, Emote={On={Dict='nmt_3_rcm-10',Anim='cs_nigel_dual-10',Move=51,Dur=1200},Off={Dict='nmt_3_rcm-10',Anim='cs_nigel_dual-10',Move=51,Dur=1200}} },
	['Bracelet']= { Prop=7, Emote={On={Dict='nmt_3_rcm-10',Anim='cs_nigel_dual-10',Move=51,Dur=1200},Off={Dict='nmt_3_rcm-10',Anim='cs_nigel_dual-10',Move=51,Dur=1200}} },
}

LastEquipped = {}
Cooldown = false

function IncurCooldown(ms)
	CreateThread(function() Cooldown = true; Wait(ms); Cooldown = false end)
end

function Notify(message, type)
	lib.notify({ description = message, type = type or 'inform' })
end

function IsMpPed(ped)
	local model = GetEntityModel(ped)
	if model == `mp_m_freemode_01` then return 'male' end
	if model == `mp_f_freemode_01` then return 'female' end
	return false
end

local function PlayToggleEmote(e, cb)
	local ped = PlayerPedId()
	RequestAnimDict(e.Dict)
	while not HasAnimDictLoaded(e.Dict) do Wait(10) end
	if IsPedInAnyVehicle(ped) then e.Move = 51 end
	TaskPlayAnim(ped, e.Dict, e.Anim, 3.0, 3.0, e.Dur, e.Move, 0, false, false, false)
	local pause = math.max(e.Dur - 500, 500)
	IncurCooldown(pause)
	Wait(pause)
	cb()
end

function ResetClothing(anim)
	if type(anim) == 'table' then anim = true end
	local Ped = PlayerPedId()
	local e = drawables.Top.Emote
	if anim then TaskPlayAnim(Ped, e.Dict, e.Anim, 3.0, 3.0, 3000, e.Move, 0, false, false, false) end
	for _, v in pairs(LastEquipped) do
		if v then
			if v.Drawable then SetPedComponentVariation(Ped, v.Id, v.Drawable, v.Texture, 0)
			elseif v.Prop then ClearPedProp(Ped, v.Id); SetPedPropIndex(Ped, v.Id, v.Prop, v.Texture, true) end
		end
	end
	LastEquipped = {}
end

RegisterNetEvent('lustt-radial:ResetClothing', ResetClothing)

function ToggleClothing(whic, extra)
	local which = type(whic) == 'table' and tostring(whic.id) or whic
	Wait(50)
	if which == 'Shirt' or which == 'Pants' or which == 'Bagoff' then extra = true end
	if Cooldown then return end
	local Toggle = extra and Extras[which] or drawables[which]
	local Ped = PlayerPedId()
	local Cur = {
		Drawable = GetPedDrawableVariation(Ped, Toggle.Drawable),
		Id = Toggle.Drawable,
		Ped = Ped,
		Texture = GetPedTextureVariation(Ped, Toggle.Drawable),
	}
	local Gender = IsMpPed(Ped)
	if which ~= 'Mask' and not Gender then Notify(Lang:t('info.wrong_ped')); return false end
	local Table = Toggle.Table[Gender]
	if not Toggle.Table.Standalone then
		for k, v in pairs(Table) do
			if not Toggle.Remember then
				if k == Cur.Drawable then
					PlayToggleEmote(Toggle.Emote, function() SetPedComponentVariation(Ped, Toggle.Drawable, v, Cur.Texture, 0) end)
					return true
				end
			else
				if not LastEquipped[which] then
					if k == Cur.Drawable then
						PlayToggleEmote(Toggle.Emote, function()
							LastEquipped[which] = Cur
							SetPedComponentVariation(Ped, Toggle.Drawable, v, Cur.Texture, 0)
						end)
						return true
					end
				else
					local Last = LastEquipped[which]
					PlayToggleEmote(Toggle.Emote, function()
						SetPedComponentVariation(Ped, Toggle.Drawable, Last.Drawable, Last.Texture, 0)
						LastEquipped[which] = false
					end)
					return true
				end
			end
		end
		Notify(Lang:t('info.no_variants'))
		return
	else
		if not LastEquipped[which] then
			if Cur.Drawable ~= Table then
				PlayToggleEmote(Toggle.Emote, function()
					LastEquipped[which] = Cur
					SetPedComponentVariation(Ped, Toggle.Drawable, Table, 0, 0)
					if Toggle.Table.Extra then
						for _, v in pairs(Toggle.Table.Extra) do
							local ExtraCur = { Drawable=GetPedDrawableVariation(Ped,v.Drawable), Texture=GetPedTextureVariation(Ped,v.Drawable), Id=v.Drawable }
							SetPedComponentVariation(Ped, v.Drawable, v.Id, v.Tex, 0)
							LastEquipped[v.Name] = ExtraCur
						end
					end
				end)
				return true
			end
		else
			local Last = LastEquipped[which]
			PlayToggleEmote(Toggle.Emote, function()
				SetPedComponentVariation(Ped, Toggle.Drawable, Last.Drawable, Last.Texture, 0)
				LastEquipped[which] = false
				if Toggle.Table.Extra then
					for _, v in pairs(Toggle.Table.Extra) do
						if LastEquipped[v.Name] then
							Last = LastEquipped[v.Name]
							SetPedComponentVariation(Ped, Last.Id, Last.Drawable, Last.Texture, 0)
							LastEquipped[v.Name] = false
						end
					end
				end
			end)
			return true
		end
	end
	Notify(Lang:t('info.already_wearing'))
	return false
end

RegisterNetEvent('lustt-radial:ToggleClothing', ToggleClothing)

function ToggleProps(whic)
	local which = type(whic) == 'table' and tostring(whic.id) or whic
	Wait(50)
	if Cooldown then return end
	local Prop = Props[which]
	local Ped = PlayerPedId()
	local Cur = { Id=Prop.Prop, Ped=Ped, Prop=GetPedPropIndex(Ped,Prop.Prop), Texture=GetPedPropTextureIndex(Ped,Prop.Prop) }
	if not Prop.Variants then
		if Cur.Prop ~= -1 then
			PlayToggleEmote(Prop.Emote.Off, function() LastEquipped[which] = Cur; ClearPedProp(Ped, Prop.Prop) end)
			return true
		else
			local Last = LastEquipped[which]
			if Last then
				PlayToggleEmote(Prop.Emote.On, function() SetPedPropIndex(Ped, Prop.Prop, Last.Prop, Last.Texture, true) end)
				LastEquipped[which] = false
				return true
			end
		end
		Notify(Lang:t('info.nothing_to_remove'))
		return false
	else
		local Gender = IsMpPed(Ped)
		if not Gender then Notify(Lang:t('info.wrong_ped')); return false end
		local vars = Prop.Variants[Gender]
		for k, v in pairs(vars) do
			if Cur.Prop == k then
				PlayToggleEmote(Prop.Emote.On, function() SetPedPropIndex(Ped, Prop.Prop, v, Cur.Texture, true) end)
				return true
			end
		end
		Notify(Lang:t('info.no_variants'))
		return false
	end
end

RegisterNetEvent('lustt-radial:ToggleProps', ToggleProps)

for k, v in pairs(Config.Commands) do
	RegisterCommand(k, v.Func)
	TriggerEvent('chat:addSuggestion', '/' .. k, v.Desc)
end

if Config.ExtrasEnabled then
	for k, v in pairs(Config.ExtraCommands) do
		RegisterCommand(k, v.Func)
		TriggerEvent('chat:addSuggestion', '/' .. k, v.Desc)
	end
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then ResetClothing() end
end)

RegisterNetEvent('dpc:EquipLast', function()
	local Ped = PlayerPedId()
	for _, v in pairs(LastEquipped) do
		if v then
			if v.Drawable then SetPedComponentVariation(Ped, v.ID, v.Drawable, v.Texture, 0)
			elseif v.Prop then ClearPedProp(Ped, v.ID); SetPedPropIndex(Ped, v.ID, v.Prop, v.Texture, true) end
		end
	end
	LastEquipped = {}
end)

RegisterNetEvent('dpc:ResetClothing', function() LastEquipped = {} end)
