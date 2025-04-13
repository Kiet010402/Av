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

-- Biến lưu trạng thái Macro
local macroName = ""
local selectedMacro = ""
local isRecording = false
local isPlaying = false
local recordedActions = {}
local currentMacro = nil

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

-- Tạo tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://13311798537" })

-- Tạo tab Macro
local MacroTab = Window:AddTab({ Title = "Macro", Icon = "rbxassetid://13311793824" })

-- Tạo tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://13311798537" })

-- Section Summon
local SummonSection = SummonTab:AddSection("Summon Settings")

-- Section Maps - Story
local StorySection = MapsTab:AddSection("Story Maps")

-- Section Macro
local MacroSection = MacroTab:AddSection("Macro Settings")

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

-- Input để đặt tên macro
MacroSection:AddInput("MacroName", {
    Title = "Macro Name",
    Default = "",
    Placeholder = "Enter macro name",
    Callback = function(Value)
        macroName = Value
    end
})

-- Button để tạo macro mới
MacroSection:AddButton({
    Title = "Create Macro",
    Callback = function()
        if macroName == "" then
            Fluent:Notify({
                Title = "Error",
                Content = "Please enter a macro name",
                Duration = 3
            })
            return
        end
        
        local macroFile = "KaihonAVMacro_" .. macroName .. ".json"
        if isfile(macroFile) then
            Fluent:Notify({
                Title = "Error",
                Content = "Macro name already exists",
                Duration = 3
            })
            return
        end
        
        -- Tạo file macro mới
        local newMacro = {
            name = macroName,
            actions = {}
        }
        
        writefile(macroFile, game:GetService("HttpService"):JSONEncode(newMacro))
        
        Fluent:Notify({
            Title = "Success",
            Content = "Created new macro: " .. macroName,
            Duration = 3
        })
        
        -- Cập nhật dropdown
        UpdateMacroDropdown()
    end
})

-- Hàm cập nhật dropdown macro
local function UpdateMacroDropdown()
    local macros = {}
    for _, file in pairs(listfiles()) do
        if file:match("KaihonAVMacro_(.+)%.json") then
            local name = file:match("KaihonAVMacro_(.+)%.json")
            table.insert(macros, name)
        end
    end
    
    MacroSection:UpdateDropdown("MacroDropdown", {
        Title = "Select Macro",
        Values = macros,
        Multi = false,
        Default = 1,
        Callback = function(Value)
            selectedMacro = Value
            -- Tải macro đã chọn
            LoadMacro(Value)
        end
    })
end

-- Hàm tải macro
local function LoadMacro(macroName)
    local macroFile = "KaihonAVMacro_" .. macroName .. ".json"
    if isfile(macroFile) then
        local content = readfile(macroFile)
        currentMacro = game:GetService("HttpService"):JSONDecode(content)
    end
end

-- Dropdown để chọn macro
MacroSection:AddDropdown("MacroDropdown", {
    Title = "Select Macro",
    Values = {},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        selectedMacro = Value
        LoadMacro(Value)
    end
})

-- Toggle để bật/tắt Record
MacroSection:AddToggle("RecordToggle", {
    Title = "Record Macro",
    Default = false,
    Callback = function(Value)
        isRecording = Value
        if Value then
            recordedActions = {}
            Fluent:Notify({
                Title = "Recording",
                Content = "Started recording macro",
                Duration = 3
            })
        else
            -- Lưu macro khi dừng record
            if currentMacro then
                currentMacro.actions = recordedActions
                local macroFile = "KaihonAVMacro_" .. currentMacro.name .. ".json"
                writefile(macroFile, game:GetService("HttpService"):JSONEncode(currentMacro))
                
                Fluent:Notify({
                    Title = "Recording Stopped",
                    Content = "Saved macro: " .. currentMacro.name,
                    Duration = 3
                })
            end
        end
    end
})

-- Toggle để bật/tắt Play
MacroSection:AddToggle("PlayToggle", {
    Title = "Play Macro",
    Default = false,
    Callback = function(Value)
        isPlaying = Value
        if Value and currentMacro then
            Fluent:Notify({
                Title = "Playing",
                Content = "Started playing macro: " .. currentMacro.name,
                Duration = 3
            })
            
            -- Tạo coroutine để chạy macro
            spawn(function()
                for _, action in pairs(currentMacro.actions) do
                    if not isPlaying then break end
                    
                    if action.type == "place" then
                        local args = {
                            [1] = "Render",
                            [2] = {
                                [1] = action.unitName,
                                [2] = action.level,
                                [3] = action.position,
                                [4] = action.rotation
                            }
                        }
                        game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
                    elseif action.type == "upgrade" then
                        local args = {
                            [1] = "Upgrade",
                            [2] = action.unitId
                        }
                        game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
                    elseif action.type == "sell" then
                        local args = {
                            [1] = "Sell",
                            [2] = action.unitId
                        }
                        game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
                    end
                    
                    wait(0.1) -- Đợi 0.1 giây giữa các action
                end
                
                isPlaying = false
                Fluent:Notify({
                    Title = "Playback Complete",
                    Content = "Finished playing macro: " .. currentMacro.name,
                    Duration = 3
                })
            end)
        else
            Fluent:Notify({
                Title = "Playback Stopped",
                Content = "Stopped playing macro",
                Duration = 3
            })
        end
    end
})

-- Button để xóa macro
MacroSection:AddButton({
    Title = "Delete Macro",
    Callback = function()
        if selectedMacro == "" then
            Fluent:Notify({
                Title = "Error",
                Content = "Please select a macro to delete",
                Duration = 3
            })
            return
        end
        
        local macroFile = "KaihonAVMacro_" .. selectedMacro .. ".json"
        if isfile(macroFile) then
            delfile(macroFile)
            selectedMacro = ""
            currentMacro = nil
            UpdateMacroDropdown()
            
            Fluent:Notify({
                Title = "Success",
                Content = "Deleted macro: " .. selectedMacro,
                Duration = 3
            })
        end
    end
})

-- Hook vào các sự kiện để ghi lại macro
local function HookEvents()
    local UnitEvent = game:GetService("ReplicatedStorage").Networking.UnitEvent
    
    -- Hook sự kiện Place Unit
    local oldPlace = UnitEvent.FireServer
    UnitEvent.FireServer = function(self, ...)
        local args = {...}
        if isRecording and args[1] == "Render" then
            table.insert(recordedActions, {
                type = "place",
                unitName = args[2][1],
                level = args[2][2],
                position = args[2][3],
                rotation = args[2][4]
            })
        end
        return oldPlace(self, ...)
    end
    
    -- Hook sự kiện Upgrade Unit
    local oldUpgrade = UnitEvent.FireServer
    UnitEvent.FireServer = function(self, ...)
        local args = {...}
        if isRecording and args[1] == "Upgrade" then
            table.insert(recordedActions, {
                type = "upgrade",
                unitId = args[2]
            })
        end
        return oldUpgrade(self, ...)
    end
    
    -- Hook sự kiện Sell Unit
    local oldSell = UnitEvent.FireServer
    UnitEvent.FireServer = function(self, ...)
        local args = {...}
        if isRecording and args[1] == "Sell" then
            table.insert(recordedActions, {
                type = "sell",
                unitId = args[2]
            })
        end
        return oldSell(self, ...)
    end
end

-- Khởi tạo hook events
HookEvents()

-- Cập nhật dropdown macro khi khởi động
UpdateMacroDropdown()
