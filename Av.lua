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

-- Mapping cho stages và maps
local stageMapping = {
    ["Stage1"] = "Planet Namak",
    ["Stage2"] = "Sand Village",
    ["Stage3"] = "Double Dungeon",
    ["Stage4"] = "Shibuya Station",
    ["Stage5"] = "Underground Church",
    ["Stage6"] = "Spirit Society"
}

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
    for _, tab in pairs({MainTab, SummonTab, MapsTab, SettingsTab}) do
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

-- Hệ thống Macro
local MacroSystem = {}
MacroSystem.MacroFolder = "KaihonHubAV/Macros"
MacroSystem.CurrentMacro = nil
MacroSystem.IsRecording = false
MacroSystem.IsPlaying = false
MacroSystem.MacroList = {}
MacroSystem.RecordedActions = {}
MacroSystem.CurrentMacroName = "Macro1"

-- Tạo thư mục macro nếu chưa tồn tại
pcall(function()
    if not isfolder(MacroSystem.MacroFolder) then
        makefolder(MacroSystem.MacroFolder)
    end
end)

-- Hàm để tải danh sách macro
MacroSystem.LoadMacroList = function()
    MacroSystem.MacroList = {}
    pcall(function()
        local files = listfiles(MacroSystem.MacroFolder)
        for _, file in ipairs(files) do
            -- Trích xuất tên file từ đường dẫn đầy đủ
            local fileName = string.match(file, "[^/\\]+$")
            if fileName and string.sub(fileName, -5) == ".json" then
                table.insert(MacroSystem.MacroList, string.sub(fileName, 1, -6))
            end
        end
    end)
    return MacroSystem.MacroList
end

-- Hàm để lưu macro
MacroSystem.SaveMacro = function(macroName, actions)
    local success, err = pcall(function()
        local filePath = MacroSystem.MacroFolder .. "/" .. macroName .. ".json"
        writefile(filePath, game:GetService("HttpService"):JSONEncode(actions))
    end)
    if success then
        Fluent:Notify({
            Title = "Macro Saved",
            Content = "Macro '" .. macroName .. "' đã được lưu thành công!",
            Duration = 3
        })
    else
        warn("Lỗi khi lưu macro:", err)
        Fluent:Notify({
            Title = "Save Error",
            Content = "Không thể lưu macro: " .. tostring(err),
            Duration = 3
        })
    end
end

-- Hàm để tải macro
MacroSystem.LoadMacro = function(macroName)
    local success, content = pcall(function()
        local filePath = MacroSystem.MacroFolder .. "/" .. macroName .. ".json"
        if isfile(filePath) then
            return readfile(filePath)
        end
        return nil
    end)
    
    if success and content then
        local data = game:GetService("HttpService"):JSONDecode(content)
        MacroSystem.CurrentMacro = data
        Fluent:Notify({
            Title = "Macro Loaded",
            Content = "Macro '" .. macroName .. "' đã được tải thành công!",
            Duration = 3
        })
        return true
    else
        Fluent:Notify({
            Title = "Load Error",
            Content = "Không thể tải macro: " .. macroName,
            Duration = 3
        })
        return false
    end
end

-- Hook các sự kiện để ghi lại hành động
local function hookUnitEvents()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if MacroSystem.IsRecording and method == "FireServer" and self.Name == "UnitEvent" and typeof(self) == "Instance" then
            local eventData = args[1]
            local unitData = args[2]
            
            -- Ghi lại hành động dựa trên loại sự kiện
            if eventData == "Render" then
                -- Place unit
                table.insert(MacroSystem.RecordedActions, {
                    type = "place",
                    unitType = unitData[1],
                    slotIndex = unitData[2],
                    position = unitData[3],
                    rotation = unitData[4],
                    timestamp = os.time()
                })
                print("Đã ghi lại: Place unit " .. unitData[1])
                
            elseif eventData == "Upgrade" then
                -- Upgrade unit
                table.insert(MacroSystem.RecordedActions, {
                    type = "upgrade",
                    unitId = unitData,
                    timestamp = os.time()
                })
                print("Đã ghi lại: Upgrade unit " .. unitData)
                
            elseif eventData == "Sell" then
                -- Sell unit
                table.insert(MacroSystem.RecordedActions, {
                    type = "sell",
                    unitId = unitData,
                    timestamp = os.time()
                })
                print("Đã ghi lại: Sell unit " .. unitData)
            end
        end
        
        return oldNamecall(self, ...)
    end)
end

-- Phát lại các hành động đã ghi
local function playMacro(actions)
    if not actions or #actions == 0 then
        Fluent:Notify({
            Title = "Macro Error",
            Content = "Không có hành động nào để phát lại!",
            Duration = 3
        })
        return
    end
    
    -- Sắp xếp các hành động theo thời gian
    table.sort(actions, function(a, b)
        return a.timestamp < b.timestamp
    end)
    
    local firstTime = actions[1].timestamp
    
    -- Phát lại từng hành động
    task.spawn(function()
        for i, action in ipairs(actions) do
            if not MacroSystem.IsPlaying then break end
            
            -- Tính toán độ trễ dựa trên thời gian ghi
            local delay = 0
            if i > 1 then
                delay = (action.timestamp - actions[i-1].timestamp)
            end
            
            wait(delay)
            
            -- Thực hiện hành động
            if action.type == "place" then
                local args = {
                    [1] = "Render",
                    [2] = {
                        [1] = action.unitType,
                        [2] = action.slotIndex,
                        [3] = action.position,
                        [4] = action.rotation
                    }
                }
                game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
                print("Đang phát: Place unit " .. action.unitType)
                
            elseif action.type == "upgrade" then
                local args = {
                    [1] = "Upgrade",
                    [2] = action.unitId
                }
                game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
                print("Đang phát: Upgrade unit " .. action.unitId)
                
            elseif action.type == "sell" then
                local args = {
                    [1] = "Sell",
                    [2] = action.unitId
                }
                game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
                print("Đang phát: Sell unit " .. action.unitId)
            end
        end
        
        MacroSystem.IsPlaying = false
        Fluent:Notify({
            Title = "Macro Completed",
            Content = "Đã phát xong tất cả các hành động!",
            Duration = 3
        })
    end)
end

-- Khởi tạo hook cho các sự kiện
hookUnitEvents()

-- Tạo giao diện Macro
local MacroSection = MacroTab:AddSection("Macro System")

-- Input để đặt tên macro
MacroSection:AddInput("MacroName", {
    Title = "Macro Name",
    Default = MacroSystem.CurrentMacroName,
    Placeholder = "Enter macro name",
    Finished = true,
    Callback = function(Value)
        MacroSystem.CurrentMacroName = Value
    end
})

-- Button để tạo macro mới
MacroSection:AddButton({
    Title = "Create New Macro",
    Callback = function()
        MacroSystem.RecordedActions = {}
        MacroSystem.IsRecording = false
        MacroSystem.IsPlaying = false
        Fluent:Notify({
            Title = "New Macro",
            Content = "Đã tạo macro mới với tên: " .. MacroSystem.CurrentMacroName,
            Duration = 3
        })
    end
})

-- Load macro list
MacroSystem.LoadMacroList()

-- Dropdown để chọn macro
MacroSection:AddDropdown("MacroDropdown", {
    Title = "Select Macro",
    Values = MacroSystem.MacroList,
    Multi = false,
    Default = 1,
    Callback = function(Value)
        MacroSystem.LoadMacro(Value)
    end
})

-- Button để làm mới danh sách macro
MacroSection:AddButton({
    Title = "Refresh Macro List",
    Callback = function()
        local macros = MacroSystem.LoadMacroList()
        Fluent.Options.MacroDropdown:SetValues(macros)
        Fluent:Notify({
            Title = "Macro List",
            Content = "Đã làm mới danh sách macro!",
            Duration = 3
        })
    end
})

-- Toggle để ghi lại macro
MacroSection:AddToggle("RecordMacro", {
    Title = "Record Macro",
    Default = false,
    Callback = function(Value)
        MacroSystem.IsRecording = Value
        
        if MacroSystem.IsRecording then
            MacroSystem.RecordedActions = {}
            Fluent:Notify({
                Title = "Recording Started",
                Content = "Đang ghi lại các hành động cho macro '" .. MacroSystem.CurrentMacroName .. "'",
                Duration = 3
            })
        else
            -- Khi dừng ghi, lưu macro
            if #MacroSystem.RecordedActions > 0 then
                MacroSystem.SaveMacro(MacroSystem.CurrentMacroName, MacroSystem.RecordedActions)
                -- Làm mới danh sách macro
                local macros = MacroSystem.LoadMacroList()
                Fluent.Options.MacroDropdown:SetValues(macros)
            else
                Fluent:Notify({
                    Title = "Empty Macro",
                    Content = "Không có hành động nào được ghi lại!",
                    Duration = 3
                })
            end
        end
    end
})

-- Toggle để phát lại macro
MacroSection:AddToggle("PlayMacro", {
    Title = "Play Macro",
    Default = false,
    Callback = function(Value)
        MacroSystem.IsPlaying = Value
        
        if MacroSystem.IsPlaying then
            if MacroSystem.CurrentMacro then
                Fluent:Notify({
                    Title = "Playback Started",
                    Content = "Đang phát lại macro...",
                    Duration = 3
                })
                playMacro(MacroSystem.CurrentMacro)
            else
                Fluent:Notify({
                    Title = "Playback Error",
                    Content = "Vui lòng chọn một macro để phát lại!",
                    Duration = 3
                })
                MacroSystem.IsPlaying = false
            end
        else
            Fluent:Notify({
                Title = "Playback Stopped",
                Content = "Đã dừng phát lại macro",
                Duration = 3
            })
        end
    end
})
