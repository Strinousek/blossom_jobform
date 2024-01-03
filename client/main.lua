IsFormDisplayed = false
CurrentFormId = nil

if(not USE_OX_TARGET) then
    AddTextEntry("BLOSSOM_JOBFORM:FORM_HELP_INTERACT", Core.Locale("FORM_HELP_INTERACT"))
end

if(USE_OX_TARGET) then
    for formId, data in pairs(FORMS) do
        exports.ox_target:addSphereZone({
            coords = data.coords,
            radius = TARGET_DISTANCE * 1.75,
            drawSprite = true,
            options = {
                {
                    label = Core.Locale("FORM_TARGET_INTERACT"),
                    icon = "fas fa-clipboard",
                    distance = TARGET_DISTANCE,
                    onSelect = function()
                        ShowForm(formId)
                    end,
                    canInteract = function()
                        return not IsFormDisplayed
                    end
                }
            }
        })
    end
else
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local distanceToNearestForm = 15000.0
    
            for formId, data in pairs(FORMS) do
                local distance = #(coords - data.coords)
                if(distance < distanceToNearestForm) then
                    distanceToNearestForm = distance
                end

                if(not IsFormDisplayed) then
                    if(distance < FLOAT_NOTIFY_DISTANCE) then
                        FloatNotify(data.coords, "BLOSSOM_JOBFORM:FORM_HELP_INTERACT")
                        if IsControlJustReleased(0, Core.Client.Keys[OPEN_FORM_KEY]) then
                            ShowForm(formId)
                        end
                    end
                end
            end

            if(distanceToNearestForm > LOAD_DISTANCE) then
              Citizen.Wait(2000)
            end
        end
    end)
end

function ShowForm(formId)
    local data, response = Core.Client.TriggerServerCallback("blossom_jobform:getData")
    if(not data) then
        Core.Client.ShowNotification(response, { type = "error" })
        return
    end
    IsFormDisplayed = not IsFormDisplayed
    SetNuiFocus(IsFormDisplayed, IsFormDisplayed)
    SendNUIMessage({
        action = "showForm",
        form = FORMS[formId],
        player = data
    })
    CurrentFormId = formId
end

function FloatNotify(coords, entry)
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(table.unpack(FLOAT_NOTIFY_STYLE))
    BeginTextCommandDisplayHelp(entry)
    EndTextCommandDisplayHelp(2, false, false, -1)
end

RegisterNUICallback("submit", function(data, cb)
    IsFormDisplayed = not IsFormDisplayed
    SetNuiFocus(IsFormDisplayed, IsFormDisplayed)
    TriggerServerEvent("blossom_jobform:postForm", CurrentFormId, data)
    CurrentFormId = nil
    cb({})
end)

RegisterNUICallback("exit", function(data, cb)
    CurrentFormId = nil
    IsFormDisplayed = not IsFormDisplayed
    SetNuiFocus(IsFormDisplayed, IsFormDisplayed)
    cb({})
end)

/*RegisterNUICallback("send_form", function(data)
    SetDisplay(false)
    if data ~= nil then
      local wayjocLength = string.len(data.wayjoc)
      local tuabyLength = string.len(data.tuaby)
      if (wayjocLength < minLength) or (tuabyLength < minLength) then
        ESX.ShowNotification('~r~Your form is too short - '..minLength..' min. characters!')
      else
        if (wayjocLength > maxLength) or (tuabyLength > maxLength) then
          ESX.ShowNotification('~r~Your form is too long - '..maxLength..' max. characters!')
        else
          sendForm(data)
          ESX.ShowNotification('~g~Your form has been sent to - '..data.job)
        end
      end
    else
      ESX.ShowNotification('~r~Your form is empty!')
    end
end)

RegisterNUICallback("exit_form", function(data)
    if data.error ~= nil then
      ESX.ShowNotification(data.error)
    end
    SetDisplay(false)
end)

function sendForm(data)
  TriggerServerEvent('strin_jobform:sendWebhook', data)
end

function DrawText3D(coords, text)
  local onScreen,_x,_y=World3dToScreen2d(coords.x,coords.y,coords.z)
  
  SetTextScale(DRAW_TEXT_SCALE.x, DRAW_TEXT_SCALE.y)
  SetTextFont(DRAW_TEXT_FONT)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 215)
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x,_y)
  if DRAW_RECT then
    local factor = (string.len(text)) / 200
    DrawRect(_x,_y+0.0105, 0.015+ factor, 0.035, 44, 44, 44, 100)
  end
end*/