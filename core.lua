Core = {}
Core.Framework = FRAMEWORK == "ESX" and exports["es_extended"]:getSharedObject() or exports['qb-core']:GetCoreObject()

Core.Locales = load(LoadResourceFile(GetCurrentResourceName(), ("locales/%s.lua"):format(LOCALE)))()

Core.Locale = function(localeKey, ...)
    return Core.Locales[localeKey]:format(...)
end

if(not IsDuplicityVersion()) then
    Core.Client = {}
    
    Core.Client.TriggerServerCallback = function(name, cb, ...)
        local p = nil
        if(not cb) then p = promise.new() end
        if(FRAMEWORK == "ESX") then
            Core.Framework.TriggerServerCallback(name, function(...)
                if(p) then
                    p:resolve({...})
                else
                    cb(table.unpack({...}))
                end
            end, ...)
        else
            Core.Framework.Functions.TriggerCallback(name, function(...)
                if(p) then
                    p:resolve({...})
                else
                    cb(table.unpack({...}))
                end
            end, ...)
        end
        if(p) then
            return table.unpack(Citizen.Await(p))
        end
    end

    Core.Client.Keys = {
        ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
        ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
        ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
        ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
        ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
        ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
        ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
        ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
        ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
    }

    -- properties = { type = "inform" | "error" | "success" } 
    Core.Client.ShowNotification = function(message, properties)
        if(FRAMEWORK == "ESX") then
            Core.Framework.ShowNotification(message)
            return
        end

        Core.Framework.Functions.Notify(message)
    end
else
    Core.Server = {}

    Core.Server.RegisterCallback = function(name, cb)
        if(FRAMEWORK == "ESX") then
            Core.Framework.RegisterServerCallback(name, function(source, frameworkCb, ...)
                frameworkCb(cb(source, ...))
            end)
        else
            Core.Framework.Functions.CreateCallback(name, function(source, frameworkCb, ...)
                frameworkCb(cb(source, ...))
            end)
        end
    end

    Core.Server.GetPlayerFromId = function(playerId)
        local playerId = tonumber(playerId)
        if(not playerId) then
            return
        end
        local player = FRAMEWORK == "ESX" and Core.Framework.GetPlayerFromId(playerId) or Core.Framework.Functions.GetPlayer(playerId)
        if(not player) then
            return
        end

        return player
    end

    Core.Server.Avatar = "https://png.pngtree.com/png-clipart/20210312/original/pngtree-cherry-blossom-with-leaves-png-image_6078514.png"

    Core.Server.SendWebhook = function(webhook, title, message)
        local embedMessage = {
            {
                ["title"] = title,
                ["description"] =  ""..message.."",
                ["color"] = color,
                ["footer"] ={
                    ["text"] = os.date("%c").." (Server Time).",
                },
            }
        }
        PerformHttpRequest(webhook,
        function(err, text, headers)end, 'POST', json.encode({username = "Blossom Scripts", avatar_url= Core.Server.Avatar ,embeds = embedMessage}), { ['Content-Type']= 'application/json' })
    end
end