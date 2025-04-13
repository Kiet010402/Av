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
local MacroTab = Window:AddTab({ Title = "Macro", Icon = "rbxassetid://13311791077" })

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

-- Section Macro
local MacroSection = MacroTab:AddSection("Macro Recorder")

-- Hệ thống quản lý macro
local MacroSystem = {}
MacroSystem.MacroFolder = "KaihonHubAV/Macros"
MacroSystem.CurrentMacro = ""
MacroSystem.MacroList = {}
MacroSystem.IsRecording = false
MacroSystem.IsPlaying = false
MacroSystem.Actions = {}
MacroSystem.MacrosInFolder = {}

-- Tạo thư mục nếu không tồn tại
pcall(function()
    if not isfolder("KaihonHubAV") then
        makefolder("KaihonHubAV")
    end
    
    if not isfolder(MacroSystem.MacroFolder) then
        makefolder(MacroSystem.MacroFolder)
    end
    print("Đã kiểm tra thư mục macro:", MacroSystem.MacroFolder)
end)

-- Hàm tải danh sách macro từ thư mục
function MacroSystem:LoadMacroList()
    MacroSystem.MacrosInFolder = {}
    
    local success, result = pcall(function()
        if not isfolder(MacroSystem.MacroFolder) then
            makefolder(MacroSystem.MacroFolder)
            return {}
        end
        
        local files = {}
        
        -- Thử liệt kê files
        pcall(function()
            files = listfiles(MacroSystem.MacroFolder)
            print("Đã tìm thấy " .. #files .. " files trong thư mục macro")
        end)
        
        for _, file in pairs(files) do
            -- Trích xuất tên file không có đường dẫn và phần mở rộng
            local fileName = string.match(file, "([^/\\]+)%.json$")
            if fileName then
                print("Tìm thấy macro: " .. fileName)
                table.insert(MacroSystem.MacrosInFolder, fileName)
            end
        end
        return MacroSystem.MacrosInFolder
    end)
    
    if not success then
        warn("Lỗi khi tải danh sách macro:", result)
        return {}
    end
    
    return result
end

-- Hàm lưu macro
function MacroSystem:SaveMacro(macroName)
    if macroName == "" then return false end
    
    local macroData = {
        name = macroName,
        actions = MacroSystem.Actions
    }
    
    local success, err = pcall(function()
        local filePath = MacroSystem.MacroFolder .. "/" .. macroName .. ".json"
        local jsonData = game:GetService("HttpService"):JSONEncode(macroData)
        writefile(filePath, jsonData)
        print("Đã lưu macro vào:", filePath)
    end)
    
    if not success then
        warn("Lỗi khi lưu macro:", err)
        return false
    end
    
    return success
end

-- Input cho tên macro
local macroNameInput = MacroTab:AddInput("MacroName", {
    Title = "Macro Name",
    Default = "",
    Placeholder = "Enter macro name...",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        MacroSystem.CurrentMacro = Value
        print("Đã đặt tên macro:", Value)
    end
})

-- Label để hiển thị trạng thái ghi/phát
local ActionDisplay = MacroTab:AddParagraph({
    Title = "Status",
    Content = "No macro selected"
})

-- Nút tạo macro mới
MacroTab:AddButton({
    Title = "Create Macro",
    Callback = function()
        if MacroSystem.CurrentMacro == "" then
            Fluent:Notify({
                Title = "Error",
                Content = "Please enter a macro name",
                Duration = 3
            })
            return
        end
        
        -- Reset action list
        MacroSystem.Actions = {}
        
        -- Lưu macro trống mới
        local success = MacroSystem:SaveMacro(MacroSystem.CurrentMacro)
        
        if success then
            Fluent:Notify({
                Title = "Success",
                Content = "Created new macro: " .. MacroSystem.CurrentMacro,
                Duration = 3
            })
            
            -- Refresh dropdown ngay sau khi tạo macro mới
            local macros = MacroSystem:LoadMacroList()
            if MacroDropdown then
                pcall(function()
                    print("Cập nhật dropdown với", #macros, "macro")
                    if #macros == 0 then
                        MacroDropdown:SetValues({"No macros found"})
                    else
                        MacroDropdown:SetValues(macros)
                    end
                end)
            end
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Failed to create macro",
                Duration = 3
            })
        end
    end
})

-- Tải danh sách macro
local macros = MacroSystem:LoadMacroList() or {}
print("Tải danh sách macro:", #macros, "macros")

-- Dropdown để chọn macro
local MacroDropdown = MacroTab:AddDropdown("MacroDropdown", {
    Title = "Select Macro",
    Values = #macros > 0 and macros or {"No macros found"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        if not Value or Value == "" or Value == "No macros found" then return end
        
        print("Đã chọn macro:", Value)
        local success = MacroSystem:LoadMacro(Value)
        
        if success then
            Fluent:Notify({
                Title = "Success",
                Content = "Loaded macro: " .. Value,
                Duration = 3
            })
            
            -- Update action display
            UpdateActionListDisplay()
            
            -- Update input field
            if macroNameInput then
                pcall(function()
                    macroNameInput:Set(Value)
                end)
            end
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Failed to load macro: " .. Value,
                Duration = 3
            })
        end
    end
})

-- Nút Delete Macro
MacroTab:AddButton({
    Title = "Delete Macro",
    Callback = function()
        if MacroSystem.CurrentMacro == "" then
            Fluent:Notify({
                Title = "Error",
                Content = "No macro selected",
                Duration = 3
            })
            return
        end
        
        local success = MacroSystem:DeleteMacro(MacroSystem.CurrentMacro)
        
        if success then
            Fluent:Notify({
                Title = "Success",
                Content = "Deleted macro: " .. MacroSystem.CurrentMacro,
                Duration = 3
            })
            
            -- Reset current macro
            MacroSystem.CurrentMacro = ""
            MacroSystem.Actions = {}
            if macroNameInput then
                pcall(function()
                    macroNameInput:Set("")
                end)
            end
            
            -- Refresh dropdown immediately
            local macros = MacroSystem:LoadMacroList()
            if MacroDropdown then
                pcall(function()
                    if #macros == 0 then
                        MacroDropdown:SetValues({"No macros found"})
                    else
                        MacroDropdown:SetValues(macros)
                    end
                end)
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

-- Function to update action list display
function UpdateActionListDisplay()
    if not ActionDisplay then return end
    
    pcall(function()
        if #MacroSystem.Actions == 0 then
            ActionDisplay.Title = "Status"
            ActionDisplay.Content = "No actions recorded"
            return
        end
        
        local lastAction = MacroSystem.Actions[#MacroSystem.Actions]
        ActionDisplay.Title = "Status"
        ActionDisplay.Content = "Last action: " .. lastAction.type .. " (Total: " .. #MacroSystem.Actions .. ")"
    end)
end

function MacroSystem:LoadMacro(macroName)
    if macroName == "" then return false end
    
    local success, macroData = pcall(function()
        local filePath = MacroSystem.MacroFolder .. "/" .. macroName .. ".json"
        if not isfile(filePath) then
            warn("File không tồn tại:", filePath)
            return nil
        end
        local fileContent = readfile(filePath)
        return game:GetService("HttpService"):JSONDecode(fileContent)
    end)
    
    if success and macroData then
        MacroSystem.CurrentMacro = macroName
        MacroSystem.Actions = macroData.actions or {}
        print("Đã tải macro thành công:", macroName, "#actions =", #MacroSystem.Actions)
        return true
    end
    
    warn("Lỗi khi tải macro:", macroName)
    return false
end

-- Hàm xóa macro
function MacroSystem:DeleteMacro(macroName)
    if macroName == "" then return false end
    
    local filePath = MacroSystem.MacroFolder .. "/" .. macroName .. ".json"
    local success = pcall(function()
        if isfile(filePath) then
            delfile(filePath)
            print("Đã xóa macro:", filePath)
        else
            warn("File macro không tồn tại:", filePath)
        end
    end)
    
    return success
end

-- Hàm thêm hành động vào macro hiện tại
function MacroSystem:AddAction(actionType, actionData)
    if not MacroSystem.IsRecording then return end
    
    local action = {
        type = actionType,
        data = actionData,
        time = tick() - MacroSystem.RecordStartTime
    }
    
    table.insert(MacroSystem.Actions, action)
    print("Đã thêm hành động:", actionType, "vào macro", MacroSystem.CurrentMacro)
    UpdateActionListDisplay()
end

-- Hàm phát lại macro
function MacroSystem:PlayMacro()
    if MacroSystem.CurrentMacro == "" then
        Fluent:Notify({
            Title = "Error",
            Content = "No macro selected",
            Duration = 3
        })
        return
    end
    
    if #MacroSystem.Actions == 0 then 
        Fluent:Notify({
            Title = "Macro Empty",
            Content = "No actions to play",
            Duration = 3
        })
        return 
    end
    
    MacroSystem.IsPlaying = true
    MacroSystem.PlayStartTime = tick()
    print("Bắt đầu phát macro:", MacroSystem.CurrentMacro, "với", #MacroSystem.Actions, "hành động")
    
    -- Thực hiện các hành động theo thời gian ghi
    for i, action in ipairs(MacroSystem.Actions) do
        spawn(function()
            -- Đợi đến đúng thời điểm thực hiện hành động
            local waitTime = action.time
            wait(waitTime)
            
            -- Kiểm tra xem có đang phát macro không
            if not MacroSystem.IsPlaying then return end
            
            -- Thực hiện hành động tương ứng
            if action.type == "place" then
                local args = {
                    [1] = "Render",
                    [2] = {
                        [1] = action.data.unitName,
                        [2] = action.data.unitId,
                        [3] = action.data.position,
                        [4] = action.data.rotation or 0
                    }
                }
                game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
                print("Thực hiện hành động place:", action.data.unitName)
                
            elseif action.type == "upgrade" then
                local args = {
                    [1] = "Upgrade",
                    [2] = action.data.unitId
                }
                game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
                print("Thực hiện hành động upgrade:", action.data.unitId)
                
            elseif action.type == "sell" then
                local args = {
                    [1] = "Sell",
                    [2] = action.data.unitId
                }
                game:GetService("ReplicatedStorage").Networking.UnitEvent:FireServer(unpack(args))
                print("Thực hiện hành động sell:", action.data.unitId)
            end
            
            -- Cập nhật trạng thái hiện tại
            if ActionDisplay then
                pcall(function()
                    ActionDisplay.Title = "Status"
                    ActionDisplay.Content = "Action: " .. i .. "/" .. #MacroSystem.Actions .. " - " .. action.type
                end)
            end
        end)
    end
    
    -- Dừng macro sau khi hoàn thành
    spawn(function()
        if #MacroSystem.Actions == 0 then return end
        local lastAction = MacroSystem.Actions[#MacroSystem.Actions]
        local waitTime = lastAction and lastAction.time + 1 or 1
        wait(waitTime)
        
        if not MacroSystem.IsPlaying then return end
        
        MacroSystem.IsPlaying = false
        if PlayMacroToggle then
            pcall(function()
                PlayMacroToggle:Set(false)
            end)
        end
        if ActionDisplay then
            pcall(function()
                ActionDisplay.Title = "Status"
                ActionDisplay.Content = "Playback completed"
            end)
        end
        print("Hoàn thành phát macro")
    end)
end

-- Hooks để bắt các sự kiện từ game
local originalNamecall
originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if MacroSystem.IsRecording and method == "FireServer" and self.Name == "UnitEvent" and self.Parent.Name == "Networking" then
        local actionType = args[1]
        
        if actionType == "Render" then -- Place unit
            local unitData = args[2]
            MacroSystem:AddAction("place", {
                unitName = unitData[1],
                unitId = unitData[2],
                position = unitData[3],
                rotation = unitData[4]
            })
            if ActionDisplay then
                pcall(function()
                    ActionDisplay.Title = "Status"
                    ActionDisplay.Content = "Recorded: Place " .. unitData[1]
                end)
            end
            
        elseif actionType == "Upgrade" then -- Upgrade unit
            local unitId = args[2]
            MacroSystem:AddAction("upgrade", {
                unitId = unitId
            })
            if ActionDisplay then
                pcall(function()
                    ActionDisplay.Title = "Status"
                    ActionDisplay.Content = "Recorded: Upgrade unit " .. tostring(unitId)
                end)
            end
            
        elseif actionType == "Sell" then -- Sell unit
            local unitId = args[2]
            MacroSystem:AddAction("sell", {
                unitId = unitId
            })
            if ActionDisplay then
                pcall(function()
                    ActionDisplay.Title = "Status"
                    ActionDisplay.Content = "Recorded: Sell unit " .. tostring(unitId)
                end)
            end
        end
    end
    
    return originalNamecall(self, ...)
end)

-- Toggle Record Macro
local RecordMacroToggle = MacroTab:AddToggle("RecordMacroToggle", {
    Title = "Record Macro",
    Default = false,
    Callback = function(Value)
        MacroSystem.IsRecording = Value
        
        if Value then
            if MacroSystem.CurrentMacro == "" then
                Fluent:Notify({
                    Title = "Error",
                    Content = "Please enter a macro name first",
                    Duration = 3
                })
                RecordMacroToggle:Set(false)
                return
            end
            
            -- Bắt đầu ghi
            MacroSystem.Actions = {}
            MacroSystem.RecordStartTime = tick()
            
            Fluent:Notify({
                Title = "Recording Started",
                Content = "Recording macro: " .. MacroSystem.CurrentMacro,
                Duration = 3
            })
            
            -- Reset display
            if ActionDisplay then
                pcall(function()
                    ActionDisplay.Title = "Status"
                    ActionDisplay.Content = "Recording started... Place, upgrade or sell units"
                end)
            end
        else
            -- Dừng ghi và lưu
            if #MacroSystem.Actions > 0 then
                local success = MacroSystem:SaveMacro(MacroSystem.CurrentMacro)
                
                if success then
                    Fluent:Notify({
                        Title = "Recording Stopped",
                        Content = "Saved " .. #MacroSystem.Actions .. " actions to " .. MacroSystem.CurrentMacro,
                        Duration = 3
                    })
                else
                    Fluent:Notify({
                        Title = "Error",
                        Content = "Failed to save macro",
                        Duration = 3
                    })
                end
            else
                Fluent:Notify({
                    Title = "Recording Stopped",
                    Content = "No actions were recorded",
                    Duration = 3
                })
            end
        end
    end
})

-- Toggle Play Macro
local PlayMacroToggle = MacroTab:AddToggle("PlayMacroToggle", {
    Title = "Play Macro",
    Default = false,
    Callback = function(Value)
        MacroSystem.IsPlaying = Value
        
        if Value then
            Fluent:Notify({
                Title = "Playback Started",
                Content = "Playing macro: " .. MacroSystem.CurrentMacro,
                Duration = 3
            })
            
            MacroSystem:PlayMacro()
        else
            Fluent:Notify({
                Title = "Playback Stopped",
                Content = "Macro playback cancelled",
                Duration = 3
            })
        end
    end
})
