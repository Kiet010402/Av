local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

if not success then
    warn("Lỗi khi tải thư viện Fluent: " .. tostring(err))
    -- Thử tải từ URL dự phòng
    pcall(function()
        Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.lua"))()
        SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)
end

-- Đợi đến khi Fluent được tải hoàn tất
if not Fluent then
    warn("Không thể tải thư viện Fluent!")
    return
end

-- Hệ thống lưu trữ cấu hình
local ConfigSystem = {}
ConfigSystem.FileName = "KaihonAVConfig_" .. game:GetService("Players").LocalPlayer.Name .. ".json"
ConfigSystem.DefaultConfig = {
    -- Maps
    SelectedStage = "Stage1",
    SelectedDifficulty = "Normal",
    SelectedAct = "Act1",
    AutoJoinEnabled = false,
    AutoStartEnabled = false,
    
    -- Summon
    SelectedSummonType = "Special",
    SummonAmount = 1,
    IsSummoning = false
}
ConfigSystem.CurrentConfig = {}

-- Hàm để lưu cấu hình
ConfigSystem.SaveConfig = function()
    local success, err = pcall(function()
        writefile(ConfigSystem.FileName, game:GetService("HttpService"):JSONEncode(ConfigSystem.CurrentConfig))
    end)
    if success then
        print("Đã lưu cấu hình thành công!")
    else
        warn("Lưu cấu hình thất bại:", err)
    end
end

-- Hàm để tải cấu hình
ConfigSystem.LoadConfig = function()
    local success, content = pcall(function()
        if isfile(ConfigSystem.FileName) then
            return readfile(ConfigSystem.FileName)
        end
        return nil
    end)
    
    if success and content then
        local data = game:GetService("HttpService"):JSONDecode(content)
        ConfigSystem.CurrentConfig = data
        return true
    else
        ConfigSystem.CurrentConfig = table.clone(ConfigSystem.DefaultConfig)
        ConfigSystem.SaveConfig()
        return false
    end
end

-- Tải cấu hình khi khởi động
ConfigSystem.LoadConfig()

-- Hệ thống Macro
local MacroSystem = {}
MacroSystem.MacrosFolder = "KaihonAV_Macros"
MacroSystem.CurrentMacro = ""
MacroSystem.Recording = false
MacroSystem.Playing = false
MacroSystem.MacrosList = {}
MacroSystem.RecordedActions = {}
MacroSystem.PlaybackIndex = 1
MacroSystem.SelectedMacro = nil

-- Tạo thư mục macro nếu chưa tồn tại
local success, error = pcall(function()
    if not isfolder(MacroSystem.MacrosFolder) then
        makefolder(MacroSystem.MacrosFolder)
    end
end)
if not success then
    warn("Không thể tạo thư mục macro:", error)
end

-- Hàm để lưu macro
MacroSystem.SaveMacro = function(name, actions)
    local success, err = pcall(function()
        local macroData = {
            name = name,
            actions = actions,
            timestamp = os.time()
        }
        writefile(MacroSystem.MacrosFolder .. "/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(macroData))
    end)
    if success then
        print("Đã lưu macro thành công:", name)
        return true
    else
        warn("Lưu macro thất bại:", err)
        return false
    end
end

-- Hàm để tải macro
MacroSystem.LoadMacro = function(name)
    local success, content = pcall(function()
        local path = MacroSystem.MacrosFolder .. "/" .. name .. ".json"
        if isfile(path) then
            return readfile(path)
        end
        return nil
    end)
    
    if success and content then
        local data = game:GetService("HttpService"):JSONDecode(content)
        print("Đã tải macro:", name)
        return data
    else
        warn("Tải macro thất bại:", name)
        return nil
    end
end

-- Hàm để lấy danh sách tất cả các macro
MacroSystem.GetAllMacros = function()
    local macros = {}
    local success, files = pcall(function()
        return listfiles(MacroSystem.MacrosFolder)
    end)
    
    if success then
        for _, file in ipairs(files) do
            if file:sub(-5) == ".json" then
                local macroName = file:match("([^/\\]+)%.json$")
                table.insert(macros, macroName)
            end
        end
    else
        warn("Không thể lấy danh sách macro")
    end
    
    MacroSystem.MacrosList = macros
    return macros
end

-- Hàm để ghi lại hành động place unit
MacroSystem.RecordPlaceUnit = function(unit, slot, position, rotation)
    if MacroSystem.Recording then
        table.insert(MacroSystem.RecordedActions, {
            type = "place",
            timestamp = os.clock(),
            unit = unit,
            slot = slot,
            position = position,
            rotation = rotation
        })
        print("Đã ghi lại: Place Unit", unit)
    end
end

-- Hàm để ghi lại hành động upgrade unit
MacroSystem.RecordUpgradeUnit = function(unitId)
    if MacroSystem.Recording then
        table.insert(MacroSystem.RecordedActions, {
            type = "upgrade",
            timestamp = os.clock(),
            unitId = unitId
        })
        print("Đã ghi lại: Upgrade Unit", unitId)
    end
end

-- Hàm để ghi lại hành động sell unit
MacroSystem.RecordSellUnit = function(unitId)
    if MacroSystem.Recording then
        table.insert(MacroSystem.RecordedActions, {
            type = "sell",
            timestamp = os.clock(),
            unitId = unitId
        })
        print("Đã ghi lại: Sell Unit", unitId)
    end
end

-- Hook vào các event của game để ghi lại hành động
local unitEvent = game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("UnitEvent")

-- Tạo hook cho UnitEvent
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if MacroSystem.Recording and self == unitEvent and method == "FireServer" then
        local eventType = args[1]
        if eventType == "Render" then
            -- Place Unit
            MacroSystem.RecordPlaceUnit(args[2][1], args[2][2], args[2][3], args[2][4])
        elseif eventType == "Upgrade" then
            -- Upgrade Unit
            MacroSystem.RecordUpgradeUnit(args[2])
        elseif eventType == "Sell" then
            -- Sell Unit
            MacroSystem.RecordSellUnit(args[2])
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Hàm để phát lại macro
MacroSystem.PlayMacro = function()
    if not MacroSystem.SelectedMacro or MacroSystem.Recording then return end
    
    local macroData = MacroSystem.LoadMacro(MacroSystem.SelectedMacro)
    if not macroData then return end
    
    local actions = macroData.actions
    MacroSystem.Playing = true
    MacroSystem.PlaybackIndex = 1
    
    local startTime = os.clock()
    
    -- Tạo một task để phát lại macro
    task.spawn(function()
        while MacroSystem.Playing and MacroSystem.PlaybackIndex <= #actions do
            local action = actions[MacroSystem.PlaybackIndex]
            local currentTime = os.clock() - startTime
            
            if action.timestamp <= currentTime then
                if action.type == "place" then
                    -- Phát lại place unit
                    local args = {
                        [1] = "Render",
                        [2] = {
                            [1] = action.unit,
                            [2] = action.slot,
                            [3] = action.position,
                            [4] = action.rotation
                        }
                    }
                    unitEvent:FireServer(unpack(args))
                    print("Phát lại: Place Unit", action.unit)
                elseif action.type == "upgrade" then
                    -- Phát lại upgrade unit
                    local args = {
                        [1] = "Upgrade",
                        [2] = action.unitId
                    }
                    unitEvent:FireServer(unpack(args))
                    print("Phát lại: Upgrade Unit", action.unitId)
                elseif action.type == "sell" then
                    -- Phát lại sell unit
                    local args = {
                        [1] = "Sell",
                        [2] = action.unitId
                    }
                    unitEvent:FireServer(unpack(args))
                    print("Phát lại: Sell Unit", action.unitId)
                end
                
                MacroSystem.PlaybackIndex = MacroSystem.PlaybackIndex + 1
            end
            
            task.wait(0.01) -- Đợi một chút để không làm tràn task
        end
        
        if MacroSystem.Playing then
            MacroSystem.Playing = false
            Fluent:Notify({
                Title = "Phát Macro",
                Content = "Đã phát hết macro " .. MacroSystem.SelectedMacro,
                Duration = 3
            })
        end
    end)
end

-- Hàm để dừng phát macro
MacroSystem.StopPlayback = function()
    MacroSystem.Playing = false
end

-- Biến lưu trạng thái Maps
local selectedStage = ConfigSystem.CurrentConfig.SelectedStage or "Stage1"
local selectedDifficulty = ConfigSystem.CurrentConfig.SelectedDifficulty or "Normal"
local selectedAct = ConfigSystem.CurrentConfig.SelectedAct or "Act1"
local autoJoinEnabled = ConfigSystem.CurrentConfig.AutoJoinEnabled or false
local autoStartEnabled = ConfigSystem.CurrentConfig.AutoStartEnabled or false

-- Biến lưu trạng thái
local selectedSummonType = ConfigSystem.CurrentConfig.SelectedSummonType or "Special"
local summonAmount = ConfigSystem.CurrentConfig.SummonAmount or 1
local isSummoning = ConfigSystem.CurrentConfig.IsSummoning or false

-- Cấu hình UI
local Window = Fluent:CreateWindow({
    Title = "Kaihon Hub | Anime Vanguards",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tạo tab Main duy nhất
local MainTab = Window:AddTab({ Title = "Main", Icon = "rbxassetid://13311802307" })

-- Tạo tab Summon
local SummonTab = Window:AddTab({ Title = "Summon", Icon = "rbxassetid://13311795744" })

-- Tạo tab Maps
local MapsTab = Window:AddTab({ Title = "Maps", Icon = "rbxassetid://13311793824" })

-- Tạo tab Macro
local MacroTab = Window:AddTab({ Title = "Macro", Icon = "rbxassetid://13311795744" })

-- Tạo tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://13311798537" })

-- Section Summon
local SummonSection = SummonTab:AddSection("Summon Settings")

-- Section Maps - Story
local StorySection = MapsTab:AddSection("Story Maps")

-- Section Macro
local MacroSection = MacroTab:AddSection("Macro Controls")

-- Mapping cho stages và maps
local stageMapping = {
    ["Stage1"] = "Planet Namak",
    ["Stage2"] = "Sand Village",
    ["Stage3"] = "Double Dungeon",
    ["Stage4"] = "Shibuya Station",
    ["Stage5"] = "Underground Church",
    ["Stage6"] = "Spirit Society"
}

-- Input để nhập tên macro
local macroNameInput = ""
MacroSection:AddInput("MacroName", {
    Title = "Macro Name",
    Default = "",
    Placeholder = "Enter macro name...",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        macroNameInput = Value
    end
})

-- Nút để tạo macro mới
MacroSection:AddButton({
    Title = "Create Macro",
    Callback = function()
        if macroNameInput == "" then
            Fluent:Notify({
                Title = "Lỗi",
                Content = "Vui lòng nhập tên cho macro!",
                Duration = 3
            })
            return
        end
        
        MacroSystem.CurrentMacro = macroNameInput
        MacroSystem.RecordedActions = {}
        
        Fluent:Notify({
            Title = "Tạo Macro",
            Content = "Đã tạo macro mới: " .. MacroSystem.CurrentMacro,
            Duration = 3
        })
        
        -- Cập nhật dropdown
        MacroSystem.GetAllMacros()
        local macroDropdown = Fluent.Options.MacroDropdown
        if macroDropdown then
            macroDropdown:SetValues(MacroSystem.MacrosList)
        end
    end
})

-- Dropdown để chọn macro
MacroSection:AddDropdown("MacroDropdown", {
    Title = "Select Macro",
    Values = MacroSystem.GetAllMacros(),
    Multi = false,
    Default = 1,
    Callback = function(Value)
        MacroSystem.SelectedMacro = Value
        print("Selected Macro: " .. Value)
    end
})

-- Toggle để bắt đầu/dừng ghi macro
MacroSection:AddToggle("RecordToggle", {
    Title = "Record Macro",
    Default = false,
    Callback = function(Value)
        if Value then
            if MacroSystem.CurrentMacro == "" then
                Fluent:Notify({
                    Title = "Lỗi",
                    Content = "Vui lòng tạo hoặc chọn một macro trước khi ghi!",
                    Duration = 3
                })
                return false -- Không cho phép bật toggle
            end
            
            MacroSystem.Recording = true
            MacroSystem.RecordedActions = {}
            Fluent:Notify({
                Title = "Ghi Macro",
                Content = "Đang ghi macro: " .. MacroSystem.CurrentMacro,
                Duration = 3
            })
        else
            MacroSystem.Recording = false
            if #MacroSystem.RecordedActions > 0 then
                MacroSystem.SaveMacro(MacroSystem.CurrentMacro, MacroSystem.RecordedActions)
                Fluent:Notify({
                    Title = "Ghi Macro",
                    Content = "Đã lưu macro: " .. MacroSystem.CurrentMacro .. " với " .. #MacroSystem.RecordedActions .. " hành động",
                    Duration = 3
                })
                
                -- Cập nhật dropdown
                MacroSystem.GetAllMacros()
                local macroDropdown = Fluent.Options.MacroDropdown
                if macroDropdown then
                    macroDropdown:SetValues(MacroSystem.MacrosList)
                end
            else
                Fluent:Notify({
                    Title = "Ghi Macro",
                    Content = "Đã dừng ghi macro (không có hành động nào được ghi lại)",
                    Duration = 3
                })
            end
        end
    end
})

-- Toggle để bắt đầu/dừng phát macro
MacroSection:AddToggle("PlayToggle", {
    Title = "Play Macro",
    Default = false,
    Callback = function(Value)
        if Value then
            if not MacroSystem.SelectedMacro then
                Fluent:Notify({
                    Title = "Lỗi",
                    Content = "Vui lòng chọn một macro để phát!",
                    Duration = 3
                })
                return false -- Không cho phép bật toggle
            end
            
            MacroSystem.Playing = true
            MacroSystem.PlayMacro()
            Fluent:Notify({
                Title = "Phát Macro",
                Content = "Đang phát macro: " .. MacroSystem.SelectedMacro,
                Duration = 3
            })
        else
            MacroSystem.StopPlayback()
            Fluent:Notify({
                Title = "Phát Macro",
                Content = "Đã dừng phát macro",
                Duration = 3
            })
        end
    end
})

-- Nút để làm mới danh sách macro
MacroSection:AddButton({
    Title = "Refresh Macro List",
    Callback = function()
        MacroSystem.GetAllMacros()
        local macroDropdown = Fluent.Options.MacroDropdown
        if macroDropdown then
            macroDropdown:SetValues(MacroSystem.MacrosList)
        end
        Fluent:Notify({
            Title = "Làm mới",
            Content = "Đã cập nhật danh sách macro",
            Duration = 3
        })
    end
})

-- Dropdown để chọn Stage
StorySection:AddDropdown("StageDropdown", {
    Title = "Choose Map",
    Values = {"Stage1 (Planet Namak)", "Stage2 (Sand Village)", "Stage3 (Double Dungeon)", 
              "Stage4 (Shibuya Station)", "Stage5 (Underground Church)", "Stage6 (Spirit Society)"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        -- Trích xuất stage từ giá trị đã chọn
        selectedStage = Value:match("Stage%d+")
        ConfigSystem.CurrentConfig.SelectedStage = selectedStage
        ConfigSystem.SaveConfig()
        print("Selected Stage: " .. selectedStage)
    end
})

-- Dropdown để chọn Difficulty
StorySection:AddDropdown("DifficultyDropdown", {
    Title = "Choose Difficulty",
    Values = {"Normal", "Nightmare"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        selectedDifficulty = Value
        ConfigSystem.CurrentConfig.SelectedDifficulty = Value
        ConfigSystem.SaveConfig()
        print("Selected Difficulty: " .. selectedDifficulty)
    end
})

-- Dropdown để chọn Act
StorySection:AddDropdown("ActDropdown", {
    Title = "Choose Act",
    Values = {"Act1", "Act2", "Act3", "Act4", "Act5", "Act6"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        selectedAct = Value
        ConfigSystem.CurrentConfig.SelectedAct = Value
        ConfigSystem.SaveConfig()
        print("Selected Act: " .. selectedAct)
    end
})

-- Toggle để bật/tắt Auto Join
StorySection:AddToggle("AutoJoinToggle", {
    Title = "Auto Join Map",
    Default = ConfigSystem.CurrentConfig.AutoJoinEnabled or false,
    Callback = function(Value)
        autoJoinEnabled = Value
        ConfigSystem.CurrentConfig.AutoJoinEnabled = Value
        ConfigSystem.SaveConfig()
        
        if autoJoinEnabled then
            Fluent:Notify({
                Title = "Auto Join Enabled",
                Content = "Auto joining " .. stageMapping[selectedStage] .. " (" .. selectedDifficulty .. ", " .. selectedAct .. ")",
                Duration = 3
            })
            
            -- Tạo coroutine để tự động tham gia map
            spawn(function()
                while autoJoinEnabled and wait(3) do -- Thử tham gia mỗi 3 giây
                    local args = {
                        [1] = "AddMatch",
                        [2] = {
                            ["Difficulty"] = selectedDifficulty,
                            ["Act"] = selectedAct,
                            ["StageType"] = "Story",
                            ["Stage"] = selectedStage,
                            ["FriendsOnly"] = false
                        }
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("LobbyEvent"):FireServer(unpack(args))
                    print("Attempting to join map: " .. selectedStage .. ", " .. selectedDifficulty .. ", " .. selectedAct)
                end
            end)
        else
            Fluent:Notify({
                Title = "Auto Join Disabled",
                Content = "Stopped auto joining maps",
                Duration = 3
            })
        end
    end
})

-- Toggle để bật/tắt Auto Start
StorySection:AddToggle("AutoStartToggle", {
    Title = "Auto Start",
    Default = ConfigSystem.CurrentConfig.AutoStartEnabled or false,
    Callback = function(Value)
        autoStartEnabled = Value
        ConfigSystem.CurrentConfig.AutoStartEnabled = Value
        ConfigSystem.SaveConfig()
        
        if autoStartEnabled then
            Fluent:Notify({
                Title = "Auto Start Enabled",
                Content = "Will automatically start matches when ready",
                Duration = 3
            })
            
            -- Tạo coroutine để tự động bắt đầu match
            spawn(function()
                while autoStartEnabled and wait(1) do -- Thử bắt đầu mỗi 1 giây
                    local args = {
                        [1] = "StartMatch"
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("LobbyEvent"):FireServer(unpack(args))
                    print("Attempting to start match")
                end
            end)
        else
            Fluent:Notify({
                Title = "Auto Start Disabled",
                Content = "Stopped auto starting matches",
                Duration = 3
            })
        end
    end
})

-- Manual Join Button
StorySection:AddButton({
    Title = "Join Map Now",
    Callback = function()
        local args = {
            [1] = "AddMatch",
            [2] = {
                ["Difficulty"] = selectedDifficulty,
                ["Act"] = selectedAct,
                ["StageType"] = "Story",
                ["Stage"] = selectedStage,
                ["FriendsOnly"] = false
            }
        }

        game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("LobbyEvent"):FireServer(unpack(args))
        
        Fluent:Notify({
            Title = "Joining Map",
            Content = "Attempting to join " .. stageMapping[selectedStage] .. " (" .. selectedDifficulty .. ", " .. selectedAct .. ")",
            Duration = 3
        })
    end
})

-- Dropdown để chọn loại summon
SummonSection:AddDropdown("SummonType", {
    Title = "Select Summon Type",
    Values = {"Special", "Winter"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        selectedSummonType = Value
        ConfigSystem.CurrentConfig.SelectedSummonType = Value
        ConfigSystem.SaveConfig()
        print("Selected summon type: " .. Value)
    end
})

-- Button Skip Summon Animation
SummonSection:AddButton({
    Title = "Skip Summon Animation",
    Callback = function()
        local args = {
            [1] = "Toggle",
            [2] = "SkipSummonAnimation"
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("Settings"):WaitForChild("SettingsEvent"):FireServer(unpack(args))
        
        Fluent:Notify({
            Title = "Summon Animation",
            Content = "Toggled Summon Animation Skip",
            Duration = 3
        })
    end
})

-- Toggle Summon
SummonSection:AddToggle("SummonToggle", {
    Title = "Auto Summon",
    Default = ConfigSystem.CurrentConfig.IsSummoning or false,
    Callback = function(Value)
        isSummoning = Value
        ConfigSystem.CurrentConfig.IsSummoning = Value
        ConfigSystem.SaveConfig()
        
        if isSummoning then
            Fluent:Notify({
                Title = "Auto Summon",
                Content = "Started auto summoning " .. selectedSummonType,
                Duration = 3
            })
            
            -- Tạo một coroutine để thực hiện summon liên tục
            spawn(function()
                while isSummoning and wait(0.5) do -- Chờ 0.5 giây giữa các lần summon
                    local args = {
                        [1] = "SummonMany",
                        [2] = selectedSummonType,
                        [3] = summonAmount
                    }
                    
                    game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("SummonEvent"):FireServer(unpack(args))
                end
            end)
        else
            Fluent:Notify({
                Title = "Auto Summon",
                Content = "Stopped auto summoning",
                Duration = 3
            })
        end
    end
})

-- Manual Summon Button
SummonSection:AddButton({
    Title = "Summon Once",
    Callback = function()
        local args = {
            [1] = "SummonMany",
            [2] = selectedSummonType,
            [3] = summonAmount
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("SummonEvent"):FireServer(unpack(args))
        
        Fluent:Notify({
            Title = "Manual Summon",
            Content = "Summoned " .. summonAmount .. " times of " .. selectedSummonType,
            Duration = 3
        })
    end
})

-- Settings tab
local SettingsSection = SettingsTab:AddSection("Script Settings")

-- Integration with SaveManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Thay đổi cách lưu cấu hình để sử dụng tên người chơi
local playerName = game:GetService("Players").LocalPlayer.Name
InterfaceManager:SetFolder("KaihonHubAV")
SaveManager:SetFolder("KaihonHubAV/" .. playerName)

-- Thêm thông tin vào tab Settings
SettingsTab:AddParagraph({
    Title = "Cấu hình tự động",
    Content = "Cấu hình của bạn đang được tự động lưu theo tên nhân vật: " .. playerName
})

SettingsTab:AddParagraph({
    Title = "Phím tắt",
    Content = "Nhấn LeftControl để ẩn/hiện giao diện"
})

-- Auto Save Config
local function AutoSaveConfig()
    spawn(function()
        while wait(5) do -- Lưu mỗi 5 giây
            pcall(function()
                ConfigSystem.SaveConfig()
            end)
        end
    end)
end

-- Thực thi tự động lưu cấu hình
AutoSaveConfig()

-- Thêm event listener để lưu ngay khi thay đổi giá trị
local function setupSaveEvents()
    for _, tab in pairs({MainTab, SummonTab, MapsTab, MacroTab, SettingsTab}) do
        if tab and tab._components then
            for _, element in pairs(tab._components) do
                if element and element.OnChanged then
                    element.OnChanged:Connect(function()
                        pcall(function()
                            ConfigSystem.SaveConfig()
                        end)
                    end)
                end
            end
        end
    end
end

-- Thiết lập events
setupSaveEvents()

-- Thêm hỗ trợ Logo khi minimize
repeat task.wait(0.25) until game:IsLoaded()
getgenv().Image = "rbxassetid://13099788281" -- ID tài nguyên hình ảnh logo
getgenv().ToggleUI = "LeftControl" -- Phím để bật/tắt giao diện

-- Tạo logo để mở lại UI khi đã minimize
task.spawn(function()
    local success, errorMsg = pcall(function()
        if not getgenv().LoadedMobileUI == true then 
            getgenv().LoadedMobileUI = true
            local OpenUI = Instance.new("ScreenGui")
            local ImageButton = Instance.new("ImageButton")
            local UICorner = Instance.new("UICorner")
            
            -- Kiểm tra môi trường
            if syn and syn.protect_gui then
                syn.protect_gui(OpenUI)
                OpenUI.Parent = game:GetService("CoreGui")
            elseif gethui then
                OpenUI.Parent = gethui()
            else
                OpenUI.Parent = game:GetService("CoreGui")
            end
            
            OpenUI.Name = "OpenUI"
            OpenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            
            ImageButton.Parent = OpenUI
            ImageButton.BackgroundColor3 = Color3.fromRGB(105,105,105)
            ImageButton.BackgroundTransparency = 0.8
            ImageButton.Position = UDim2.new(0.9,0,0.1,0)
            ImageButton.Size = UDim2.new(0,50,0,50)
            ImageButton.Image = getgenv().Image
            ImageButton.Draggable = true
            ImageButton.Transparency = 0.2
            
            UICorner.CornerRadius = UDim.new(0,200)
            UICorner.Parent = ImageButton
            
            -- Khi click vào logo sẽ mở lại UI
            ImageButton.MouseButton1Click:Connect(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true,getgenv().ToggleUI,false,game)
            end)
        end
    end)
    
    if not success then
        warn("Lỗi khi tạo nút Logo UI: " .. tostring(errorMsg))
    end
end)

-- Thông báo khi script đã tải xong
Fluent:Notify({
    Title = "Kaihon Hub đã sẵn sàng",
    Content = "Script đã tải thành công! Đã tải cấu hình cho " .. playerName,
    Duration = 3
})
