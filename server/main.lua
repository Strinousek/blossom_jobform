local Cooldowns = {}

RegisterNetEvent("blossom_jobform:postForm", function(formId, data)
	if(
		type(formId) ~= "string" or 
		type(data) ~= "table" or 
		not FORMS[formId] or 
		not FORM_WEBHOOKS[formId] or
		(type(data?.contact) ~= "string") or 
		(type(data?.questions) ~= "table")
	) then
		return
	end
	local _source = source

	local player = Core.Server.GetPlayerFromId(source)
	if(not player) then
		return
	end

	local identifier = player.identifier or player.PlayerData.license
	if(Cooldowns[identifier]) then
		if(FRAMEWORK == "ESX") then
			player.showNotification(Core.Locale("PLAYER_ON_COOLDOWN"))
		else
			player.Functions.Notify(Core.Locale("PLAYER_ON_COOLDOWN"))
		end
		return
	end

	local isNearForm = IsPlayerNearForm(_source, formId)
	if(not isNearForm) then
		if(FRAMEWORK == "ESX") then
			player.showNotification(Core.Locale("PLAYER_NOT_NEAR"))
		else
			player.Functions.Notify(Core.Locale("PLAYER_NOT_NEAR"))
		end
		return
	end

	if(data.contact:len() == 0) then
		if(FRAMEWORK == "ESX") then
			player.showNotification(Core.Locale("NO_CONTACT"))
		else
			player.Functions.Notify(Core.Locale("NO_CONTACT"))
		end
		return
	end

	local validatedQuestions, errorMessages = ValidateQuestions(formId, data.questions)
	if(#errorMessages > 0) then
		for i=1, #errorMessages do
			if(FRAMEWORK == "ESX") then
				player.showNotification(errorMessages[i])
			else
				player.Functions.Notify(errorMessages[i])
			end
		end
		return
	end

	local playerInfo = GetPlayerInfo(_source, player)

	local logParts = {}
	if(not playerInfo?.playerName) then
		table.insert(logParts, Core.Locale("FIRST_NAME", playerInfo.firstName))
		table.insert(logParts, Core.Locale("FIRST_NAME", playerInfo.lastName))
	else
		table.insert(logParts, Core.Locale("PLAYER_NAME", playerInfo.playerName))
	end
	
	table.insert(logParts, Core.Locale("CONTACT", data.contact))

	for questionKey, questionAnswer in pairs(validatedQuestions) do
		table.insert(logParts, FORMS[formId].questions[questionKey].label.."\n"..questionAnswer)
	end

	Core.Server.SendWebhook(FORM_WEBHOOKS[formId], FORMS[formId].label, table.concat(logParts, "\n\n"))
	
	if(FRAMEWORK == "ESX") then
		player.showNotification(Core.Locale("FORM_SENT"))
	else
		player.Functions.Notify(Core.Locale("FORM_SENT"))
	end

	Cooldowns[identifier] = true
	SetTimeout(FORM_COOLDOWN, function()
		Cooldowns[identifier] = nil
	end)
end)

function ValidateQuestions(formId, questions)
	local form = FORMS[formId]
	local validQuestions = {}
	local errorMessages = {}
	for questionKey, questionAnswer in pairs(questions) do
		local question = form.questions[questionKey]
		if(not question) then
			table.insert(errorMessages, Core.Locale("QUESTION_DOESNT_EXIST"))
			break
		elseif(type(questionAnswer) ~= "string") then
			table.insert(errorMessages, Core.Locale("QUESTION_INVALID_ANSWER", question.label))
			break
		elseif(question.minLength and questionAnswer:len() < question.minLength) then
			table.insert(errorMessages, Core.Locale("QUESTION_TOO_SHORT_ANSWER", question.label))
			break
		elseif(question.maxLength and questionAnswer:len() > question.maxLength) then
			table.insert(errorMessages, Core.Locale("QUESTION_TOO_LONG_ANSWER", question.label))
			break
		else
			validQuestions[questionKey] = questionAnswer
		end
	end
	return validQuestions, errorMessages
end

function IsPlayerNearForm(playerId, formId)
	if(ONESYNC) then
		local ped = GetPlayerPed(playerId)
		local coords = GetEntityCoords(ped)
		local distance = #(coords - FORMS[formId].coords)
		if(distance > LOAD_DISTANCE) then
			return false
		end
	end
	return true
end

Core.Server.RegisterCallback("blossom_jobform:getData", function(source)
	local player = Core.Server.GetPlayerFromId(source)
	if(not player) then
		return false, Core.Locale("PLAYER_NOT_FOUND")
	end
	return GetPlayerInfo(source, player)
end)

function GetPlayerInfo(playerId, player)
	local data = {}
	if(USE_IDENTITY) then
		data.firstName = (FRAMEWORK == "ESX") and (player.get("firstName") or player.get("firstname")) or player.PlayerData.charinfo.firstname
		data.lastName = (FRAMEWORK == "ESX") and (player.get("lastName") or player.get("lastname")) or player.PlayerData.charinfo.lastname
		data.contact = (FRAMEWORK == "ESX") and (ESX_GET_PLAYER_CONTACT(player.identifier) or "") or player.PlayerData.charinfo.phone
	else
		data.playerName = GetPlayerName(playerId)
		data.contact = (FRAMEWORK == "ESX") and (ESX_GET_PLAYER_CONTACT(player.identifier) or "") or player.PlayerData.charinfo.phone
	end
	return data
end
/*

function getInfo(source)

	local identifier = getPlayersIdentifier(source)
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local info = result[1]

		return info
	else
		return nil
	end
end

function getPlayersIdentifier(id)
	if ESX_VERSION >= 1.2 then
		local identifier = GetPlayerIdentifiers(id)[2]
		local cutIdentifier = string.gsub(identifier, "license:", "")
		return cutIdentifier
	else
		local identifier = GetPlayerIdentifiers(id)[1]
		return identifier
	end
end

ESX.RegisterServerCallback('strin_jobform:getInfo', function(source, cb) 
	local info = getInfo(source)
    cb(info)
end)

RegisterServerEvent('strin_jobform:sendWebhook')
AddEventHandler('strin_jobform:sendWebhook', function(data)
	local job = data.job
	local label = data.label
	local info = getInfo(source)
	local headers = {
		['Content-Type'] = 'application/json'
	}
	local data = {
		["username"] = label,
		["embeds"] = {{
		  	["color"] = 3447003,
		  	['description'] = '📝**Person Information**📝\nFirstname: '..info['firstname']..'\nLastname: '..info['lastname']..'\nDate of Birth: '..info['dateofbirth']..'\nGender: '..info['sex']..'\nPhone Number: '..info['phone_number']..'\n \nWhy are you joining our company?\n'..data.wayjoc..'\n \nTell us about yourself\n'..data.tuaby,
		  	["footer"] = {
			  	["text"] = GetPlayerName(source)
		  	}
		}}
	}
	PerformHttpRequest(WEBHOOKS[job], function(err, text, headers) end, 'POST', json.encode(data), headers)
end)*/