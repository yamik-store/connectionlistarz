script_name("Connect")
script_author("Beesty")
script_version("26.12.2025")
-- https://github.com/qrlk/moonloader-script-updater
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Îáíàðóæåíî îáíîâëåíèå. Ïûòàþñü îáíîâèòüñÿ c '..thisScript().version..' íà '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Çàãðóæåíî %d èç %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Çàãðóçêà îáíîâëåíèÿ çàâåðøåíà.')sampAddChatMessage(b..'Îáíîâëåíèå çàâåðøåíî!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Îáíîâëåíèå ïðîøëî íåóäà÷íî. Çàïóñêàþ óñòàðåâøóþ âåðñèþ..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Îáíîâëåíèå íå òðåáóåòñÿ.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Íå ìîãó ïðîâåðèòü îáíîâëåíèå. Ñìèðèòåñü èëè ïðîâåðüòå ñàìîñòîÿòåëüíî íà '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, âûõîäèì èç îæèäàíèÿ ïðîâåðêè îáíîâëåíèÿ. Ñìèðèòåñü èëè ïðîâåðüòå ñàìîñòîÿòåëüíî íà '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "http://raw.githubusercontent.com/yamik-store/connectionlistarz/refs/heads/main/version.json?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/yamik-store/connectionlistarz/"
        end
    end
end

require 'moonloader'

local imgui, imgui_load_error = nil, nil
local success, result = pcall(function() return require 'imgui' end)
if success then
    imgui = result
else
    print("Îøèáêà çàãðóçêè imgui: " .. tostring(result))
end

local encoding = require("encoding")
encoding.default = 'CP1251'
local u8 = encoding.UTF8

local conmenu = imgui.ImBool(false)
local nickname = imgui.ImBuffer(32)
local newServerIP = imgui.ImBuffer(16)
local newServerPort = imgui.ImBuffer(6)
local newServerName = imgui.ImBuffer(32)
local deleteServerIndex = imgui.ImInt(1)

-- Ñòàíäàðòíûå ñåðâåðà (òîëüêî åñëè ôàéëà íåò)
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

local servers = {} -- Îñíîâíîé ñïèñîê

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
    
    -- Î÷èùàåì ñïèñîê
    servers = {}
    
    -- Åñëè ôàéë åñòü - ãðóçèì èç íåãî
    if doesFileExist(serversFile) then
        local file = io.open(serversFile, "r")
        if file then
            for line in file:lines() do
                local ip, port, name = line:match("([^,]+),([^,]+),(.+)$")
                if ip and port and name then
                    -- ×èñòèì ñòðîêè
                    ip = ip:gsub("%s+", "")
                    port = port:gsub("%s+", "")
                    name = name:gsub("%s+$", ""):gsub("^%s+", "")
                    
                    -- Ïðîâåðÿåì ÷òî ïîðò ýòî ÷èñëî
                    local portNumber = tonumber(port)
                    
                    if ip and portNumber and name and string.len(name) > 0 then
                        table.insert(servers, {
                            ip = ip,
                            port = portNumber,
                            name = name
                        })
                    end
                end
            end
            file:close()
        end
    else
        -- Åñëè ôàéëà íåò - èñïîëüçóåì ñòàíäàðòíûå
        for _, server in ipairs(defaultServers) do
            table.insert(servers, {
                ip = server[1],
                port = server[2],
                name = server[3]
            })
        end
        -- È ñîõðàíÿåì èõ â ôàéë
        saveAllServers()
    end
    
    return #servers
end

-- ÑÎÕÐÀÍÅÍÈÅ ÑÅÐÂÅÐÎÂ
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

-- Îñòàëüíûå ôóíêöèè òàêèå æå êàê áûëè...
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
        return false, "IP è íàçâàíèå íå ìîãóò áûòü ïóñòûìè"
    end
    
    port = tonumber(port)
    if not port or port < 1 or port > 65535 then
        return false, "Íåâåðíûé ïîðò"
    end
    
    for _, server in ipairs(servers) do
        if server.ip == ip and server.port == port then
            return false, "Ñåðâåð óæå ñóùåñòâóåò"
        end
    end
    
    table.insert(servers, {
        ip = ip,
        port = port,
        name = name
    })
    
    saveAllServers()
    
    return true, "Ñåðâåð äîáàâëåí óñïåøíî: " .. name
end

function removeServer(index)
    if index < 1 or index > #servers then
        return false, "Íåâåðíûé èíäåêñ"
    end
    
    if #servers <= 1 then
        return false, "Íåëüçÿ óäàëèòü ïîñëåäíèé ñåðâåð"
    end
    
    local serverName = servers[index].name
    
    table.remove(servers, index)
    
    saveAllServers()
    
    return true, "Ñåðâåð óäàëåí: " .. serverName
end

function main()
        if not isSampfuncsLoaded() or not isSampLoaded() then
        return
    end
    
    -- Îæèäàíèå çàãðóçêè SAMP
    while not isSampAvailable() do
        wait(100)
    end
    
    local serverCount = loadAllServers()

    local savedNick = loadNickname()
    if savedNick then
        sampSetLocalPlayerName(savedNick)
    end
    
    sampAddChatMessage("[CONNECTION] ConnectList v2.0 çàãðóæåí!", 0x00FF00)
    sampAddChatMessage(string.format("[CONNECTION] Çàãðóæåíî ñåðâåðîâ: %d", serverCount), 0x00FF00)
    sampAddChatMessage("[CONNECTION] Êîìàíäû: /conlist èëè /clist", 0x00FF00)
    
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

-- Îñòàëüíîé êîä (imgui.OnDrawFrame, apply_custom_style) òàêîé æå êàê áûë...
function imgui.OnDrawFrame()
    if not conmenu.v then return end
    
    imgui.SetNextWindowPos(imgui.ImVec2(400, 150), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(450, 550), imgui.Cond.FirstUseEver)
    
    imgui.Begin(u8"ConnectList v2.0 | Âñå ñåðâåðà", conmenu, imgui.WindowFlags.NoCollapse)
    
    -- Íèêíåéì
    imgui.TextColored(imgui.ImVec4(1, 1, 0, 1), u8"Íèêíåéì:")
    imgui.SameLine()
    imgui.PushItemWidth(200)
    imgui.InputText("##nick", nickname)
    
    imgui.SameLine()
    if imgui.Button(u8"Ñîõðàíèòü", imgui.ImVec2(100, 25)) then
        if string.len(nickname.v) > 0 then
            sampSetLocalPlayerName(nickname.v)
            if saveNickname(nickname.v) then
                sampAddChatMessage(u8"Íèê ñîõðàíåí: " .. nickname.v, 0x00FF00)
            else
                sampAddChatMessage(u8"Îøèáêà ñîõðàíåíèÿ íèêà", 0xFF0000)
            end
        end
    end
    
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    
    -- Äîáàâëåíèå ñåðâåðà
    imgui.TextColored(imgui.ImVec4(0, 1, 1, 1), u8"Äîáàâèòü ñåðâåð:")
    
    imgui.Text(u8"IP:")
    imgui.SameLine()
    imgui.SetCursorPosX(50)
    imgui.PushItemWidth(150)
    imgui.InputText("##ip", newServerIP)
    
    imgui.SameLine()
    imgui.Text(u8"Ïîðò:")
    imgui.SameLine()
    imgui.SetCursorPosX(250)
    imgui.PushItemWidth(80)
    imgui.InputText("##port", newServerPort)
    
    imgui.Text(u8"Íàçâàíèå:")
    imgui.SameLine()
    imgui.SetCursorPosX(50)
    imgui.PushItemWidth(200)
    imgui.InputText("##name", newServerName)
    
    if imgui.Button(u8"Äîáàâèòü ñåðâåð", imgui.ImVec2(200, 30)) then
        local success, message = addNewServer(newServerIP.v, newServerPort.v, newServerName.v)
        if success then
            sampAddChatMessage(message, 0x00FF00)
            newServerIP.v = ''
            newServerPort.v = '7777'
            newServerName.v = ''
        else
            sampAddChatMessage(u8"Îøèáêà: " .. message, 0xFF0000)
        end
    end
    
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    
    -- Óäàëåíèå ñåðâåðà
    imgui.TextColored(imgui.ImVec4(1, 0.5, 0, 1), u8"Óäàëèòü ñåðâåð:")
    
    local serverNames = {}
    for i, server in ipairs(servers) do
        table.insert(serverNames, string.format("[%d] %s", i, server.name))
    end
    
    imgui.PushItemWidth(300)
    imgui.Combo("##serverlist", deleteServerIndex, serverNames)
    
    imgui.SameLine()
    if imgui.Button(u8"Óäàëèòü", imgui.ImVec2(80, 25)) then
        local success, message = removeServer(deleteServerIndex.v)
        if success then
            sampAddChatMessage(message, 0x00FF00)
            if deleteServerIndex.v > #servers then
                deleteServerIndex.v = #servers
            end
        else
            sampAddChatMessage(u8"Îøèáêà: " .. message, 0xFF0000)
        end
    end
    
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    
    -- Ñïèñîê ñåðâåðîâ
    imgui.TextColored(imgui.ImVec4(0, 1, 0, 1), u8"Ñïèñîê ñåðâåðîâ:")
    imgui.SameLine()
    imgui.Text(string.format("(%d âñåãî)", #servers))
    
    imgui.BeginChild("ServerList", imgui.ImVec2(430, 200), true)
    
    for i, server in ipairs(servers) do
        local buttonText = string.format("%s (%s:%d)", server.name, server.ip, server.port)
        if imgui.Button(buttonText, imgui.ImVec2(410, 25)) then
            sampConnectToServer(server.ip, server.port)
        end
    end
    
    imgui.EndChild()
    
    -- Èíôîðìàöèÿ
    imgui.Spacing()
    imgui.TextColored(imgui.ImVec4(1, 1, 1, 0.7), u8"Êîìàíäû: /conlist èëè /clist")
    imgui.TextColored(imgui.ImVec4(1, 1, 1, 0.7), u8"Âñå ñåðâåðà ñîõðàíÿþòñÿ â êîíôèã")
    
    imgui.End()
end

-- Ñòèëü
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
