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

-- Tạo tab Settings
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://13311798537" })

-- Tạo tab Macro
local MacroTab = Window:AddTab({ Title = "Macro", Icon = "rbxassetid://13311779094" })

-- Section Summon
local SummonSection = SummonTab:AddSection("Summon Settings")

-- Section Maps - Story
local StorySection = MapsTab:AddSection("Story Maps")

-- Section Macro
local MacroSection = MacroTab:AddSection("Macro Recorder")

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

-- Biến lưu trạng thái Macro
local macroName = ""
local selectedMacro = ""
local isRecording = false
local isPlaying = false
local recordedActions = {}
local macroList = {}
local startRecordTime = 0

-- Hàm để lưu macro vào file
local function saveMacroToFile(name, actions)
    if name == "" then
        Fluent:Notify({
            Title = "Error",
            Content = "Please enter a macro name",
            Duration = 3
        })
        return false
    end
    
    local fileName = "KaihonAV_Macro_" .. name .. ".json"
    local success, err = pcall(function()
        writefile(fileName, game:GetService("HttpService"):JSONEncode(actions))
    end)
    
    if success then
        print("Macro saved to: " .. fileName)
        return true
    else
        warn("Failed to save macro: " .. tostring(err))
        return false
    end
end

-- Hàm để tải macro từ file
local function loadMacroFromFile(name)
    if name == "" then return nil end
    
    local fileName = "KaihonAV_Macro_" .. name .. ".json"
    local success, content = pcall(function()
        if isfile(fileName) then
            return readfile(fileName)
        end
        return nil
    end)
    
    if success and content then
        local data = game:GetService("HttpService"):JSONDecode(content)
        return data
    else
        warn("Failed to load macro: " .. name)
        return nil
    end
end

-- Hàm để làm mới danh sách macro
local function refreshMacroList()
    macroList = {}
    local files = listfiles()
    
    for _, file in ipairs(files) do
        local macroMatch = string.match(file, "KaihonAV_Macro_(.+)%.json$")
        if macroMatch then
            table.insert(macroList, macroMatch)
        end
    end
    
    return macroList
end

-- Hàm thực thi lệnh place unit
local function placeUnit(unitName, unitId, position, rotation)
    local args = {
        [1] = "Render",
        [2] = {
            [1] = unitName,
            [2] = unitId,
            [3] = position,
            [4] = rotation
        }
    }
    
    game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
end

-- Hàm thực thi lệnh upgrade unit
local function upgradeUnit(unitId)
    local args = {
        [1] = "Upgrade",
        [2] = unitId
    }
    
    game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
end

-- Hàm thực thi lệnh sell unit
local function sellUnit(unitId)
    local args = {
        [1] = "Sell",
        [2] = unitId
    }
    
    game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
end

-- Hook UnitEvent để ghi lại các hành động
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if isRecording and method == "FireServer" and self == game:GetService("ReplicatedStorage").Networking.UnitEvent then
        local action = args[1]
        local data = args[2]
        local currentTime = os.time() - startRecordTime
        
        if action == "Render" then
            -- Place unit
            table.insert(recordedActions, {
                type = "place",
                time = currentTime,
                unitName = data[1],
                unitId = data[2],
                position = {
                    x = data[3].X,
                    y = data[3].Y,
                    z = data[3].Z
                },
                rotation = data[4]
            })
            print("Recorded place action: " .. data[1])
        elseif action == "Upgrade" then
            -- Upgrade unit
            table.insert(recordedActions, {
                type = "upgrade",
                time = currentTime,
                unitId = data
            })
            print("Recorded upgrade action for unit: " .. data)
        elseif action == "Sell" then
            -- Sell unit
            table.insert(recordedActions, {
                type = "sell",
                time = currentTime,
                unitId = data
            })
            print("Recorded sell action for unit: " .. data)
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Input để nhập tên macro
local MacroNameInput = MacroTab:AddInput("MacroName", {
    Title = "Macro Name",
    Default = "",
    Placeholder = "Enter macro name",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        macroName = Value
    end
})

-- Nút để tạo macro mới
MacroTab:AddButton({
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
        
        -- Tạo file macro trống
        saveMacroToFile(macroName, {})
        
        -- Làm mới danh sách và cập nhật dropdown
        local newList = refreshMacroList()
        local macroDropdown = Fluent.Options.MacroDropdown
        if macroDropdown then
            macroDropdown:SetValues(newList)
            macroDropdown:SetValue(macroName)
        end
        
        Fluent:Notify({
            Title = "Macro Created",
            Content = "Created new macro: " .. macroName,
            Duration = 3
        })
    end
})

-- Dropdown để chọn macro
local macros = refreshMacroList()
MacroTab:AddDropdown("MacroDropdown", {
    Title = "Select Macro",
    Values = macros,
    Multi = false,
    Default = "",
    Callback = function(Value)
        selectedMacro = Value
        print("Selected macro: " .. Value)
    end
})

-- Toggle để bắt đầu/dừng ghi macro
MacroTab:AddToggle("RecordToggle", {
    Title = "Record Macro",
    Default = false,
    Callback = function(Value)
        isRecording = Value
        
        if isRecording then
            -- Bắt đầu ghi
            recordedActions = {}
            startRecordTime = os.time()
            
            Fluent:Notify({
                Title = "Recording Started",
                Content = "Now recording actions for macro: " .. (selectedMacro ~= "" and selectedMacro or macroName),
                Duration = 3
            })
        else
            -- Dừng ghi và lưu
            local targetName = selectedMacro ~= "" and selectedMacro or macroName
            
            if targetName == "" then
                Fluent:Notify({
                    Title = "Error",
                    Content = "Please enter a macro name or select existing macro",
                    Duration = 3
                })
                return
            end
            
            local success = saveMacroToFile(targetName, recordedActions)
            
            if success then
                Fluent:Notify({
                    Title = "Recording Stopped",
                    Content = "Saved " .. #recordedActions .. " actions to macro: " .. targetName,
                    Duration = 3
                })
                
                -- Làm mới danh sách macro
                local newList = refreshMacroList()
                local macroDropdown = Fluent.Options.MacroDropdown
                if macroDropdown then
                    macroDropdown:SetValues(newList)
                end
            end
        end
    end
})

-- Toggle để phát macro
MacroTab:AddToggle("PlayToggle", {
    Title = "Play Macro",
    Default = false,
    Callback = function(Value)
        isPlaying = Value
        
        if isPlaying then
            -- Bắt đầu phát
            if selectedMacro == "" then
                Fluent:Notify({
                    Title = "Error",
                    Content = "Please select a macro to play",
                    Duration = 3
                })
                isPlaying = false
                return
            end
            
            local actions = loadMacroFromFile(selectedMacro)
            
            if not actions or #actions == 0 then
                Fluent:Notify({
                    Title = "Error",
                    Content = "Macro is empty or failed to load",
                    Duration = 3
                })
                isPlaying = false
                return
            end
            
            Fluent:Notify({
                Title = "Playing Macro",
                Content = "Playing " .. #actions .. " actions from macro: " .. selectedMacro,
                Duration = 3
            })
            
            -- Start a coroutine to play the macro
            task.spawn(function()
                local startTime = os.time()
                
                for i, action in ipairs(actions) do
                    -- Wait until the correct time
                    while isPlaying and (os.time() - startTime) < action.time do
                        task.wait(0.1)
                    end
                    
                    if not isPlaying then break end
                    
                    -- Execute the action
                    if action.type == "place" then
                        local position = Vector3.new(action.position.x, action.position.y, action.position.z)
                        placeUnit(action.unitName, action.unitId, position, action.rotation)
                        print("Placed unit: " .. action.unitName)
                    elseif action.type == "upgrade" then
                        upgradeUnit(action.unitId)
                        print("Upgraded unit: " .. action.unitId)
                    elseif action.type == "sell" then
                        sellUnit(action.unitId)
                        print("Sold unit: " .. action.unitId)
                    end
                    
                    task.wait(0.2) -- Small delay between actions
                end
                
                isPlaying = false
                Fluent:Notify({
                    Title = "Macro Completed",
                    Content = "Finished playing macro: " .. selectedMacro,
                    Duration = 3
                })
            end)
        else
            -- Dừng phát
            Fluent:Notify({
                Title = "Playback Stopped",
                Content = "Stopped playing macro: " .. selectedMacro,
                Duration = 3
            })
        end
    end
})

-- Nút xóa macro
MacroTab:AddButton({
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
        
        local fileName = "KaihonAV_Macro_" .. selectedMacro .. ".json"
        local success, err = pcall(function()
            if isfile(fileName) then
                delfile(fileName)
                return true
            end
            return false
        end)
        
        if success then
            Fluent:Notify({
                Title = "Macro Deleted",
                Content = "Deleted macro: " .. selectedMacro,
                Duration = 3
            })
            
            -- Làm mới danh sách và cập nhật dropdown
            local newList = refreshMacroList()
            local macroDropdown = Fluent.Options.MacroDropdown
            if macroDropdown then
                macroDropdown:SetValues(newList)
                if #newList > 0 then
                    macroDropdown:SetValue(newList[1])
                    selectedMacro = newList[1]
                else
                    macroDropdown:SetValue("")
                    selectedMacro = ""
                end
            end
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Failed to delete macro",
                Duration = 3
            })
        end
    end
})

-- Nút để làm mới danh sách macro
MacroTab:AddButton({
    Title = "Refresh Macro List",
    Callback = function()
        local newList = refreshMacroList()
        local macroDropdown = Fluent.Options.MacroDropdown
        if macroDropdown then
            macroDropdown:SetValues(newList)
        end
        
        Fluent:Notify({
            Title = "Macro List Refreshed",
            Content = "Found " .. #newList .. " macros",
            Duration = 3
        })
    end
})
