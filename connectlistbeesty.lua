script_name("Connect")
script_author("Beesty")
script_version("26.12.2025")

-- РђР’РўРћРћР‘РќРћР’Р›Р•РќР�Р•
local enable_autoupdate = true
local autoupdate_loaded = false
local Update = nil

if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {
        check = function(json_url, prefix, github_url)
            local download_status = require('moonloader').download_status
            local tmpfile = os.tmpname()
            local start_time = os.clock()
            
            if doesFileExist(tmpfile) then
                os.remove(tmpfile)
            end
            
            downloadUrlToFile(json_url, tmpfile, function(id, status, downloaded, total)
                if status == download_status.STATUS_ENDDOWNLOADDATA then
                    if doesFileExist(tmpfile) then
                        local file = io.open(tmpfile, 'r')
                        if file then
                            local json_data = file:read('*a')
                            file:close()
                            os.remove(tmpfile)
                            
                            local success, data = pcall(decodeJson, json_data)
                            if success and data then
                                local update_url = data.updateurl
                                local latest_version = data.latest
                                local current_version = thisScript().version
                                
                                print(prefix .. "РўРµРєСѓС‰Р°СЏ РІРµСЂСЃРёСЏ: " .. current_version)
                                print(prefix .. "РџРѕСЃР»РµРґРЅСЏСЏ РІРµСЂСЃРёСЏ: " .. latest_version)
                                
                                if latest_version ~= current_version then
                                    print(prefix .. "РќР°Р№РґРµРЅРѕ РѕР±РЅРѕРІР»РµРЅРёРµ!")
                                    lua_thread.create(function(prefix, update_url, latest_version, current_version)
                                        sampAddChatMessage(prefix .. 'РќР°Р№РґРµРЅРѕ РѕР±РЅРѕРІР»РµРЅРёРµ!', -1)
                                        sampAddChatMessage(prefix .. 'РўРµРєСѓС‰Р°СЏ: ' .. current_version .. ' -> РќРѕРІР°СЏ: ' .. latest_version, -1)
                                        wait(1000)
                                        
                                        downloadUrlToFile(update_url, thisScript().path, function(id2, status2, downloaded2, total2)
                                            if status2 == download_status.STATUS_DOWNLOADINGDATA then
                                                local percent = math.floor((downloaded2 / total2) * 100)
                                                print(prefix .. "Р—Р°РіСЂСѓР¶РµРЅРѕ: " .. percent .. "%")
                                            elseif status2 == download_status.STATUS_ENDDOWNLOADDATA then
                                                sampAddChatMessage(prefix .. 'РћР±РЅРѕРІР»РµРЅРёРµ СѓСЃРїРµС€РЅРѕ Р·Р°РіСЂСѓР¶РµРЅРѕ!', -1)
                                                sampAddChatMessage(prefix .. 'РџРµСЂРµР·Р°РіСЂСѓР¶Р°РµРј СЃРєСЂРёРїС‚...', -1)
                                                wait(1500)
                                                thisScript():reload()
                                            end
                                        end)
                                    end, prefix, update_url, latest_version, current_version)
                                else
                                    print(prefix .. "РЈ РІР°СЃ РїРѕСЃР»РµРґРЅСЏСЏ РІРµСЂСЃРёСЏ")
                                end
                            else
                                print(prefix .. "РћС€РёР±РєР° РїР°СЂСЃРёРЅРіР° JSON")
                            end
                        else
                            print(prefix .. "РћС€РёР±РєР° С‡С‚РµРЅРёСЏ С„Р°Р№Р»Р°")
                        end
                    end
                elseif status == download_status.STATUS_ERROR then
                    print(prefix .. "РћС€РёР±РєР° Р·Р°РіСЂСѓР·РєРё РёРЅС„РѕСЂРјР°С†РёРё РѕР± РѕР±РЅРѕРІР»РµРЅРёРё")
                end
            end)
            
            while not doesFileExist(tmpfile) and os.clock() - start_time < 10 do
                wait(100)
            end
            
            if os.clock() - start_time >= 10 then
                print(prefix .. 'РўР°Р№РјР°СѓС‚ РїСЂРё РїСЂРѕРІРµСЂРєРµ РѕР±РЅРѕРІР»РµРЅРёР№')
            end
        end
    }]])
    
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/yamik-store/connectionlistarz/refs/heads/main/version.json"
            Update.prefix = "[Connect]: "
            Update.github_url = "https://github.com/yamik-store/connectionlistarz/"
        end
    end
end

require 'moonloader'

local imgui, imgui_load_error = nil, nil
local success, result = pcall(function() return require 'imgui' end)
if success then
    imgui = result
else
    print("РћС€РёР±РєР° Р·Р°РіСЂСѓР·РєРё imgui: " .. tostring(result))
end

-- Р”Р»СЏ Windows-1251 РєРѕРґРёСЂРѕРІРєРё
local encoding = require("encoding")
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local conmenu = imgui.ImBool(false)
local nickname = imgui.ImBuffer(32)
local newServerIP = imgui.ImBuffer(16)
local newServerPort = imgui.ImBuffer(6)
local newServerName = imgui.ImBuffer(32)
local deleteServerIndex = imgui.ImInt(1)

local defaultServers = {
    {'185.169.134.3', 7777,    'Phoenix'},
    {'185.169.134.4', 7777,    'Tucson'},
    {'185.169.134.43', 7777,   'Scottdale'},
    {'185.169.134.44', 7777,   'Chandler'},
    {'185.169.134.45', 7777,   'BrainBurg'},
    {'185.169.134.5', 7777,    'Saint Rose'},
    {'185.169.134.59', 7777,   'Mesa'},
    {'185.169.134.61', 7777,   'Red-Rock'},
    {'185.169.134.107', 7777,  'Yuma'},
    {'185.169.134.109', 7777,  'Surprise'},
    {'185.169.134.166', 7777,  'Prescott'},
    {'185.169.134.171', 7777,  'Glendale'},
    {'185.169.134.172', 7777,  'Kingman'},
    {'185.169.134.173', 7777,  'Winslow'},
    {'185.169.134.174', 7777,  'Payson'},
    {'80.66.82.191', 7777,     'Gilbert'},
    {'80.66.82.190', 7777,     'Show-Low'},
    {'80.66.82.188', 7777,     'Case-Grande'},
    {'80.66.82.168', 7777,     'Page'},
    {'80.66.82.159', 7777,     'Sun-City'},
    {'80.66.82.200', 7777,     'Queen-Creek'},
    {'80.66.82.144', 7777,     'Sedona'},
    {'80.66.82.132', 7777,     'Holiday'},
    {'80.66.82.128', 7777,     'Wednesday'},
    {'80.66.82.113', 7777,     'Yava'},
    {'80.66.82.82', 7777,      'Faraway'},
    {'80.66.82.87', 7777,      'Bumble Bee'},
    {'80.66.82.54', 7777,      'Christmas'},
    {'80.66.82.39', 7777,      'Mirage'},
    {'80.66.82.33', 7777,      'Love'},
    {'80.66.82.22', 7777,      'Drake'},
    {'80.66.82.199', 7777,     'Space'},
}

local servers = {}

local configDir = getWorkingDirectory() .. "\\config\\ConnectList\\"
local serversFile = configDir .. "servers.cfg"
local nicknameFile = configDir .. "nickname.txt"

function createConfigDir()
    if not doesDirectoryExist(configDir) then
        createDirectory(configDir)
    end
end

function loadAllServers()
    createConfigDir()
    servers = {}
    
    if doesFileExist(serversFile) then
        local file = io.open(serversFile, "r")
        if file then
            for line in file:lines() do
                local parts = {}
                for part in line:gmatch("([^,]+)") do
                    table.insert(parts, part:gsub("^%s*(.-)%s*$", "%1"))
                end
                
                if #parts >= 3 then
                    local ip = parts[1]
                    local port_str = parts[2]
                    local name = parts[3]
                    
                    local port = tonumber(port_str)
                    if not port then
                        port = 7777
                    end
                    
                    if ip and port and name and string.len(ip) > 0 and string.len(name) > 0 then
                        table.insert(servers, {
                            ip = ip,
                            port = port,
                            name = name
                        })
                    end
                end
            end
            file:close()
        end
    else
        for _, server in ipairs(defaultServers) do
            table.insert(servers, {
                ip = server[1],
                port = server[2],
                name = server[3]
            })
        end
        saveAllServers()
    end
    
    return #servers
end

function saveAllServers()
    createConfigDir()
    local file = io.open(serversFile, "w")
    if file then
        for _, server in ipairs(servers) do
            file:write(string.format("%s,%d,%s\n", server.ip, server.port, server.name))
        end
        file:close()
        return true
    end
    return false
end

function loadNickname()
    createConfigDir()
    if doesFileExist(nicknameFile) then
        local file = io.open(nicknameFile, "r")
        if file then
            local savedNick = file:read("*line")
            file:close()
            if savedNick and string.len(savedNick) > 0 then
                nickname.v = savedNick
                return savedNick
            end
        end
    end
    return nil
end

function saveNickname(nick)
    createConfigDir()
    local file = io.open(nicknameFile, "w")
    if file then
        file:write(nick)
        file:close()
        return true
    end
    return false
end

function addNewServer(ip, port, name)
    if string.len(ip) == 0 or string.len(name) == 0 then
        return false, "IP Рё РЅР°Р·РІР°РЅРёРµ РЅРµ РјРѕРіСѓС‚ Р±С‹С‚СЊ РїСѓСЃС‚С‹РјРё"
    end
    
    port = tonumber(port)
    if not port or port < 1 or port > 65535 then
        return false, "РќРµРІРµСЂРЅС‹Р№ РїРѕСЂС‚"
    end
    
    for _, server in ipairs(servers) do
        if server.ip == ip and server.port == port then
            return false, "РЎРµСЂРІРµСЂ СѓР¶Рµ СЃСѓС‰РµСЃС‚РІСѓРµС‚"
        end
    end
    
    table.insert(servers, {
        ip = ip,
        port = port,
        name = name
    })
    
    saveAllServers()
    
    return true, "РЎРµСЂРІРµСЂ РґРѕР±Р°РІР»РµРЅ СѓСЃРїРµС€РЅРѕ: " .. name
end

function removeServer(index)
    if index < 1 or index > #servers then
        return false, "РќРµРІРµСЂРЅС‹Р№ РёРЅРґРµРєСЃ"
    end
    
    if #servers <= 1 then
        return false, "РќРµР»СЊР·СЏ СѓРґР°Р»РёС‚СЊ РїРѕСЃР»РµРґРЅРёР№ СЃРµСЂРІРµСЂ"
    end
    
    local serverName = servers[index].name
    table.remove(servers, index)
    saveAllServers()
    
    return true, "РЎРµСЂРІРµСЂ СѓРґР°Р»РµРЅ: " .. serverName
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then
        return
    end
    
    while not isSampAvailable() do
        wait(100)
    end
    
    if enable_autoupdate and autoupdate_loaded and Update then
        lua_thread.create(function()
            wait(3000)
            Update.check(Update.json_url, Update.prefix, Update.github_url)
        end)
    end
    
    local serverCount = loadAllServers()
    
    local savedNick = loadNickname()
    if savedNick then
        sampSetLocalPlayerName(savedNick)
    end
    
    sampAddChatMessage("[CONNECTION] ConnectList v" .. thisScript().version .. " Р·Р°РіСЂСѓР¶РµРЅ!", 0x00FF00)
    sampAddChatMessage(string.format("[CONNECTION] Р—Р°РіСЂСѓР¶РµРЅРѕ СЃРµСЂРІРµСЂРѕРІ: %d", serverCount), 0x00FF00)
    sampAddChatMessage("[CONNECTION] РљРѕРјР°РЅРґС‹: /conlist РёР»Рё /clist", 0x00FF00)
    
    sampRegisterChatCommand("conlist", function()
        conmenu.v = not conmenu.v
        if imgui then
            imgui.Process = conmenu.v
        end
    end)
    
    sampRegisterChatCommand("clist", function()
        conmenu.v = not conmenu.v
        if imgui then
            imgui.Process = conmenu.v
        end
    end)
    
    while true do
        wait(0)
        
        if imgui then
            imgui.ShowCursor = conmenu.v
        end
    end
end

function imgui.OnDrawFrame()
    if not conmenu.v then return end
    
    imgui.SetNextWindowPos(imgui.ImVec2(400, 150), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(450, 550), imgui.Cond.FirstUseEver)
    
    imgui.Begin("ConnectList v" .. thisScript().version .. " | Р’СЃРµ СЃРµСЂРІРµСЂР°", conmenu, imgui.WindowFlags.NoCollapse)
    
    -- Р‘РµР· u8 РґР»СЏ СЂСѓСЃСЃРєРёС… С‚РµРєСЃС‚РѕРІ - Р±СѓРґРµС‚ СЂР°Р±РѕС‚Р°С‚СЊ СЃ Windows-1251
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), "РќРёРєРЅРµР№Рј:")
    imgui.SameLine()
    imgui.PushItemWidth(200)
    imgui.InputText("##nick", nickname)
    
    imgui.SameLine()
    if imgui.Button("РЎРѕС…СЂР°РЅРёС‚СЊ", imgui.ImVec2(100, 25)) then
        if string.len(nickname.v) > 0 then
            sampSetLocalPlayerName(nickname.v)
            if saveNickname(nickname.v) then
                sampAddChatMessage("РќРёРє СЃРѕС…СЂР°РЅРµРЅ: " .. nickname.v, 0x00FF00)
            else
                sampAddChatMessage("РћС€РёР±РєР° СЃРѕС…СЂР°РЅРµРЅРёСЏ РЅРёРєР°", 0xFF0000)
            end
        end
    end
    
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    
    imgui.TextColored(imgui.ImVec4(0, 1, 1, 1), "Р”РѕР±Р°РІРёС‚СЊ СЃРµСЂРІРµСЂ:")
    
    imgui.Text("IP:")
    imgui.SameLine()
    imgui.SetCursorPosX(50)
    imgui.PushItemWidth(150)
    imgui.InputText("##ip", newServerIP)
    
    imgui.SameLine()
    imgui.Text("РџРѕСЂС‚:")
    imgui.SameLine()
    imgui.SetCursorPosX(250)
    imgui.PushItemWidth(80)
    imgui.InputText("##port", newServerPort)
    
    imgui.Text("РќР°Р·РІР°РЅРёРµ:")
    imgui.SameLine()
    imgui.SetCursorPosX(50)
    imgui.PushItemWidth(200)
    imgui.InputText("##name", newServerName)
    
    if imgui.Button("Р”РѕР±Р°РІРёС‚СЊ СЃРµСЂРІРµСЂ", imgui.ImVec2(200, 30)) then
        local success, message = addNewServer(newServerIP.v, newServerPort.v, newServerName.v)
        if success then
            sampAddChatMessage(message, 0x00FF00)
            newServerIP.v = ''
            newServerPort.v = '7777'
            newServerName.v = ''
        else
            sampAddChatMessage("РћС€РёР±РєР°: " .. message, 0xFF0000)
        end
    end
    
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    
    imgui.TextColored(imgui.ImVec4(1, 0.5, 0, 1), "РЈРґР°Р»РёС‚СЊ СЃРµСЂРІРµСЂ:")
    
    local serverNames = {}
    for i, server in ipairs(servers) do
        table.insert(serverNames, string.format("[%d] %s", i, server.name))
    end
    
    imgui.PushItemWidth(300)
    imgui.Combo("##serverlist", deleteServerIndex, serverNames)
    
    imgui.SameLine()
    if imgui.Button("РЈРґР°Р»РёС‚СЊ", imgui.ImVec2(80, 25)) then
        local success, message = removeServer(deleteServerIndex.v)
        if success then
            sampAddChatMessage(message, 0x00FF00)
            if deleteServerIndex.v > #servers then
                deleteServerIndex.v = #servers
            end
        else
            sampAddChatMessage("РћС€РёР±РєР°: " .. message, 0xFF0000)
        end
    end
    
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    
    imgui.TextColored(imgui.ImVec4(0, 1, 0, 1), "РЎРїРёСЃРѕРє СЃРµСЂРІРµСЂРѕРІ:")
    imgui.SameLine()
    imgui.Text(string.format("(%d РІСЃРµРіРѕ)", #servers))
    
    imgui.BeginChild("ServerList", imgui.ImVec2(430, 200), true)
    
    for i, server in ipairs(servers) do
        local buttonText = string.format("%s (%s:%d)", server.name, server.ip, server.port)
        if imgui.Button(buttonText, imgui.ImVec2(410, 25)) then
            sampConnectToServer(server.ip, server.port)
        end
    end
    
    imgui.EndChild()
    
    imgui.Spacing()
    imgui.TextColored(imgui.ImVec4(1, 1, 1, 0.7), "РљРѕРјР°РЅРґС‹: /conlist РёР»Рё /clist")
    imgui.TextColored(imgui.ImVec4(1, 1, 1, 0.7), "Р’СЃРµ СЃРµСЂРІРµСЂР° СЃРѕС…СЂР°РЅСЏСЋС‚СЃСЏ РІ РєРѕРЅС„РёРі")
    
    imgui.End()
end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    
    style.WindowPadding = imgui.ImVec2(10, 10)
    style.WindowRounding = 8
    style.FramePadding = imgui.ImVec2(6, 4)
    style.FrameRounding = 4
    style.ItemSpacing = imgui.ImVec2(8, 6)
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    
    colors[clr.WindowBg] = ImVec4(0.08, 0.08, 0.10, 0.98)
    colors[clr.TitleBg] = ImVec4(0.71, 0.39, 0.12, 0.8)
    colors[clr.TitleBgActive] = ImVec4(0.85, 0.47, 0.15, 1)
    colors[clr.Button] = ImVec4(0.71, 0.39, 0.12, 0.6)
    colors[clr.ButtonHovered] = ImVec4(0.85, 0.47, 0.15, 0.8)
    colors[clr.ButtonActive] = ImVec4(0.95, 0.55, 0.20, 1)
    colors[clr.Text] = ImVec4(1, 1, 1, 1)
end

apply_custom_style()
