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
local MacroTab = Window:AddTab({ Title = "Macro", Icon = "rbxassetid://13311798537" })

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

-- Macro system
local MacroSection = MacroTab:AddSection("Macro System")

-- Biến lưu trạng thái Macro
local macroName = ""
local selectedMacro = ""
local isRecording = false
local isPlaying = false
local macroList = {}
local currentMacro = {}
local macroFolder = "KaihonHubAV/Macros/"

-- Kiểm tra xem executor có hỗ trợ các chức năng file I/O không
local fileSystemSupported = true
local success = pcall(function()
    if not isfolder then fileSystemSupported = false return end
    if not makefolder then fileSystemSupported = false return end
    if not listfiles then fileSystemSupported = false return end
    if not writefile then fileSystemSupported = false return end
    if not readfile then fileSystemSupported = false return end
    if not delfile then fileSystemSupported = false return end
end)

if not success or not fileSystemSupported then
    MacroSection:AddParagraph({
        Title = "Lỗi Hỗ Trợ Tệp",
        Content = "Executor của bạn không hỗ trợ đầy đủ các chức năng tệp cần thiết cho tính năng Macro. Vui lòng sử dụng executor khác như Synapse X, KRNL, hoặc Script-Ware."
    })
end

-- Tạo thư mục lưu Macro nếu chưa tồn tại
local function setupMacroFolder()
    if not fileSystemSupported then return false end
    
    local success, err = pcall(function()
        if not isfolder(macroFolder) then
            makefolder(macroFolder)
        end
    end)
    
    return success
end

-- Lấy danh sách tất cả macro đã lưu
local function getMacroList()
    if not fileSystemSupported then return {} end
    
    local files = {}
    local success, fileList = pcall(function()
        return listfiles(macroFolder)
    end)
    
    if success and fileList then
        for _, file in ipairs(fileList) do
            -- Trích xuất tên file không có đường dẫn và phần mở rộng
            local fileName = string.match(file, "[^/\\]+%.json$")
            if fileName then
                fileName = fileName:sub(1, #fileName - 5) -- Loại bỏ .json
                table.insert(files, fileName)
            end
        end
    end
    
    return files
end

-- Lưu macro vào file
local function saveMacro(name, data)
    if not fileSystemSupported then
        Fluent:Notify({
            Title = "Lỗi lưu macro",
            Content = "Executor của bạn không hỗ trợ các chức năng tệp",
            Duration = 3
        })
        return false
    end
    
    local folderReady = setupMacroFolder()
    if not folderReady then
        Fluent:Notify({
            Title = "Lỗi lưu macro",
            Content = "Không thể tạo thư mục macro",
            Duration = 3
        })
        return false
    end
    
    local success, err = pcall(function()
        writefile(macroFolder .. name .. ".json", game:GetService("HttpService"):JSONEncode(data))
    end)
    
    if success then
        Fluent:Notify({
            Title = "Macro đã lưu",
            Content = "Đã lưu macro " .. name .. " thành công!",
            Duration = 3
        })
        return true
    else
        Fluent:Notify({
            Title = "Lỗi lưu macro",
            Content = "Không thể lưu macro: " .. tostring(err),
            Duration = 3
        })
        return false
    end
end

-- Tải macro từ file
local function loadMacro(name)
    if not fileSystemSupported then return {} end
    
    local success, content = pcall(function()
        if isfile(macroFolder .. name .. ".json") then
            return readfile(macroFolder .. name .. ".json")
        end
        return nil
    end)
    
    if success and content then
        local dataSuccess, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(content)
        end)
        
        if dataSuccess and data then
            Fluent:Notify({
                Title = "Macro đã tải",
                Content = "Đã tải macro " .. name .. " thành công!",
                Duration = 3
            })
            return data
        end
    end
    
    Fluent:Notify({
        Title = "Lỗi tải macro",
        Content = "Không thể tải macro: " .. name,
        Duration = 3
    })
    return {}
end

-- Nhập tên Macro
MacroSection:AddInput("MacroName", {
    Title = "Macro Name",
    Default = "",
    Placeholder = "Enter macro name",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        macroName = Value
    end
})

-- Nút tạo Macro mới
MacroSection:AddButton({
    Title = "Create Macro",
    Callback = function()
        if not fileSystemSupported then
            Fluent:Notify({
                Title = "Lỗi",
                Content = "Executor của bạn không hỗ trợ các chức năng tệp",
                Duration = 3
            })
            return
        end
        
        if macroName == "" then
            Fluent:Notify({
                Title = "Lỗi",
                Content = "Vui lòng nhập tên cho macro!",
                Duration = 3
            })
            return
        end
        
        -- Tạo macro mới
        if saveMacro(macroName, {}) then
            -- Làm mới danh sách macro
            local macroDropdown = Fluent.Options.MacroSelect
            if macroDropdown then
                macroList = getMacroList()
                macroDropdown:SetValues(macroList)
            end
            
            Fluent:Notify({
                Title = "Tạo Macro",
                Content = "Đã tạo macro mới: " .. macroName,
                Duration = 3
            })
        end
    end
})

-- Dropdown để chọn Macro
if fileSystemSupported then
    macroList = getMacroList()
end

MacroSection:AddDropdown("MacroSelect", {
    Title = "Select Macro",
    Values = macroList,
    Multi = false,
    Default = 1,
    Callback = function(Value)
        selectedMacro = Value
        currentMacro = loadMacro(Value)
    end
})

-- Kiểm tra xem executor có hỗ trợ hookmetamethod không
local hookSupported = true
local hookSuccess = pcall(function()
    if not hookmetamethod or not getnamecallmethod then 
        hookSupported = false
    end
end)

if not hookSuccess or not hookSupported then
    MacroSection:AddParagraph({
        Title = "Lỗi Hook Metamethod",
        Content = "Executor của bạn không hỗ trợ hookmetamethod hoặc getnamecallmethod, tính năng ghi macro sẽ không hoạt động."
    })
else
    -- Cách theo dõi unit mới - sử dụng connections thay vì hook
    local unitEventConnection = nil
    
    -- Hàm để bắt đầu theo dõi các sự kiện unit
    local function startUnitEventTracking()
        -- Ngắt kết nối cũ nếu có
        if unitEventConnection then
            unitEventConnection:Disconnect()
            unitEventConnection = nil
        end
        
        -- Kết nối sự kiện namecall cho tất cả RemoteEvents
        unitEventConnection = game:GetService("ReplicatedStorage").DescendantAdded:Connect(function(desc)
            if isRecording and desc:IsA("RemoteEvent") then
                -- Theo dõi tất cả RemoteEvents trong ReplicatedStorage
                local connection
                connection = desc.OnClientEvent:Connect(function(...)
                    local args = {...}
                    -- Kiểm tra xem có phải là unit event không
                    if isRecording and args and #args > 0 then
                        local action = args[1]
                        if action == "Render" or action == "Upgrade" or action == "Sell" then
                            table.insert(currentMacro, {
                                timestamp = tick(),
                                action = action,
                                args = args,
                                path = desc:GetFullName()
                            })
                            print("Đã ghi lại thao tác: " .. action .. " từ " .. desc:GetFullName())
                        end
                    end
                end)
                
                -- Lưu connection để có thể disconnect sau này
                table.insert(unitConnections, connection)
            end
        end)
        
        -- Tự động bắt tất cả RemoteEvents hiện có
        for _, desc in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if desc:IsA("RemoteEvent") then
                local connection
                connection = desc.OnClientEvent:Connect(function(...)
                    local args = {...}
                    -- Kiểm tra xem có phải là unit event không
                    if isRecording and args and #args > 0 then
                        local action = args[1]
                        if action == "Render" or action == "Upgrade" or action == "Sell" then
                            table.insert(currentMacro, {
                                timestamp = tick(),
                                action = action,
                                args = args,
                                path = desc:GetFullName()
                            })
                            print("Đã ghi lại thao tác: " .. action .. " từ " .. desc:GetFullName())
                        end
                    end
                end)
                
                -- Lưu connection để có thể disconnect sau này
                table.insert(unitConnections, connection)
            end
        end
    end
    
    -- Hàm để dừng theo dõi các sự kiện unit
    local function stopUnitEventTracking()
        if unitEventConnection then
            unitEventConnection:Disconnect()
            unitEventConnection = nil
        end
        
        -- Ngắt kết nối tất cả connections
        for _, conn in ipairs(unitConnections) do
            if conn then
                conn:Disconnect()
            end
        end
        
        unitConnections = {}
    end
    
    -- Bảng lưu trữ các connections
    unitConnections = {}
    
    -- Theo dõi tất cả RemoteEvents được kích hoạt từ client
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if isRecording and method == "FireServer" and self:IsA("RemoteEvent") then
            -- Kiểm tra nếu đây là UnitEvent thông qua tên hoặc đường dẫn
            local path = self:GetFullName()
            if path:find("UnitEvent") or path:find("Unit") then
                if args and #args > 0 then
                    local action = args[1]
                    if type(action) == "string" and (action == "Render" or action == "Upgrade" or action == "Sell") then
                        table.insert(currentMacro, {
                            timestamp = tick(),
                            action = action,
                            args = args,
                            path = path
                        })
                        print("Đã ghi lại thao tác: " .. action .. " từ " .. path)
                    end
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    -- Hook mouse input để ghi lại các thao tác click
    local UserInputService = game:GetService("UserInputService")
    local clickConnection = nil
    
    local function startMouseTracking()
        if clickConnection then
            clickConnection:Disconnect()
            clickConnection = nil
        end
        
        clickConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if isRecording and not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
                print("Đã ghi lại click chuột tại vị trí: " .. tostring(input.Position))
                table.insert(currentMacro, {
                    timestamp = tick(),
                    action = "MouseClick",
                    position = input.Position,
                    isMouseEvent = true
                })
            end
        end)
    end
    
    local function stopMouseTracking()
        if clickConnection then
            clickConnection:Disconnect()
            clickConnection = nil
        end
    end
end

-- Toggle để bắt đầu/dừng ghi Macro
MacroSection:AddToggle("RecordMacro", {
    Title = "Record Macro",
    Default = false,
    Callback = function(Value)
        if not fileSystemSupported or not hookSupported then
            Fluent:Notify({
                Title = "Lỗi",
                Content = "Tính năng ghi macro không được hỗ trợ trên executor này",
                Duration = 3
            })
            return
        end
        
        isRecording = Value
        
        if isRecording then
            if selectedMacro == "" then
                Fluent:Notify({
                    Title = "Lỗi",
                    Content = "Vui lòng chọn macro để ghi!",
                    Duration = 3
                })
                isRecording = false
                Fluent.Options.RecordMacro:SetValue(false)
                return
            end
            
            -- Bắt đầu ghi mới
            currentMacro = {}
            
            -- Bắt đầu theo dõi các sự kiện
            if startUnitEventTracking then startUnitEventTracking() end
            if startMouseTracking then startMouseTracking() end
            
            Fluent:Notify({
                Title = "Bắt đầu ghi",
                Content = "Đang ghi lại macro: " .. selectedMacro,
                Duration = 3
            })
        else
            -- Dừng theo dõi các sự kiện
            if stopUnitEventTracking then stopUnitEventTracking() end
            if stopMouseTracking then stopMouseTracking() end
            
            -- Kết thúc ghi và lưu
            if #currentMacro > 0 then
                saveMacro(selectedMacro, currentMacro)
            else
                Fluent:Notify({
                    Title = "Cảnh báo",
                    Content = "Không có thao tác nào được ghi lại",
                    Duration = 3
                })
            end
            
            Fluent:Notify({
                Title = "Kết thúc ghi",
                Content = "Đã lưu " .. #currentMacro .. " thao tác cho macro: " .. selectedMacro,
                Duration = 3
            })
        end
    end
})

-- Toggle để phát lại Macro
MacroSection:AddToggle("PlayMacro", {
    Title = "Play Macro",
    Default = false,
    Callback = function(Value)
        isPlaying = Value
        
        if isPlaying then
            if not fileSystemSupported then
                Fluent:Notify({
                    Title = "Lỗi",
                    Content = "Tính năng phát macro không được hỗ trợ trên executor này",
                    Duration = 3
                })
                isPlaying = false
                Fluent.Options.PlayMacro:SetValue(false)
                return
            end
            
            if selectedMacro == "" then
                Fluent:Notify({
                    Title = "Lỗi",
                    Content = "Vui lòng chọn macro để phát!",
                    Duration = 3
                })
                isPlaying = false
                Fluent.Options.PlayMacro:SetValue(false)
                return
            end
            
            if not currentMacro or #currentMacro == 0 then
                Fluent:Notify({
                    Title = "Lỗi",
                    Content = "Macro không có thao tác nào để phát!",
                    Duration = 3
                })
                isPlaying = false
                Fluent.Options.PlayMacro:SetValue(false)
                return
            end
            
            -- Bắt đầu phát
            Fluent:Notify({
                Title = "Bắt đầu phát",
                Content = "Đang phát macro: " .. selectedMacro .. " (" .. #currentMacro .. " thao tác)",
                Duration = 3
            })
            
            -- Tạo coroutine để phát macro
            spawn(function()
                local startTime = tick()
                
                for i, action in ipairs(currentMacro) do
                    if not isPlaying then break end -- Dừng nếu người dùng tắt Toggle
                    
                    -- Đợi đến thời gian thích hợp nếu không phải thao tác đầu tiên
                    if i > 1 then
                        local prevAction = currentMacro[i-1]
                        local waitTime = action.timestamp - prevAction.timestamp
                        wait(waitTime)
                    end
                    
                    -- Thực hiện thao tác
                    pcall(function()
                        if action.isMouseEvent then
                            -- Giả lập click chuột
                            if action.action == "MouseClick" then
                                game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                                    action.position.X, 
                                    action.position.Y, 
                                    0, -- Button (0 = left)
                                    true, -- Down
                                    game, 
                                    1
                                )
                                wait(0.1) -- Giữ 0.1 giây
                                game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                                    action.position.X, 
                                    action.position.Y, 
                                    0, -- Button (0 = left)
                                    false, -- Up
                                    game, 
                                    1
                                )
                            end
                        else
                            -- Xác định RemoteEvent cần gọi
                            local path = action.path
                            local remoteEvent = nil
                            
                            if path then
                                -- Tìm RemoteEvent theo đường dẫn
                                local pathParts = string.split(path, ".")
                                local current = game
                                for _, part in ipairs(pathParts) do
                                    current = current:FindFirstChild(part)
                                    if not current then break end
                                end
                                
                                if current and current:IsA("RemoteEvent") then
                                    remoteEvent = current
                                end
                            else
                                -- Thử tìm UnitEvent theo cách cũ
                                remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Networking"):FindFirstChild("UnitEvent")
                            end
                            
                            -- Thực thi FireServer nếu tìm thấy RemoteEvent
                            if remoteEvent and action.args and #action.args > 0 then
                                remoteEvent:FireServer(unpack(action.args))
                                print("Đã phát thao tác " .. i .. "/" .. #currentMacro .. ": " .. (action.action or "Unknown"))
                            else
                                print("Không tìm thấy RemoteEvent cho thao tác " .. i)
                            end
                        end
                    end)
                end
                
                -- Kết thúc phát
                isPlaying = false
                if Fluent and Fluent.Options and Fluent.Options.PlayMacro then
                    Fluent.Options.PlayMacro:SetValue(false)
                end
                
                Fluent:Notify({
                    Title = "Kết thúc phát",
                    Content = "Đã phát xong macro: " .. selectedMacro,
                    Duration = 3
                })
            end)
        else
            -- Người dùng đã dừng phát
            Fluent:Notify({
                Title = "Dừng phát",
                Content = "Đã dừng phát macro: " .. selectedMacro,
                Duration = 3
            })
        end
    end
})

-- Nút làm mới danh sách macro
MacroSection:AddButton({
    Title = "Refresh Macro List",
    Callback = function()
        if not fileSystemSupported then
            Fluent:Notify({
                Title = "Lỗi",
                Content = "Executor của bạn không hỗ trợ các chức năng tệp",
                Duration = 3
            })
            return
        end
        
        -- Làm mới danh sách
        local macroDropdown = Fluent.Options.MacroSelect
        if macroDropdown then
            macroList = getMacroList()
            macroDropdown:SetValues(macroList)
            
            Fluent:Notify({
                Title = "Làm mới",
                Content = "Đã làm mới danh sách macro!",
                Duration = 3
            })
        end
    end
})

-- Nút xóa macro hiện tại
MacroSection:AddButton({
    Title = "Delete Current Macro",
    Callback = function()
        if not fileSystemSupported then
            Fluent:Notify({
                Title = "Lỗi",
                Content = "Executor của bạn không hỗ trợ các chức năng tệp",
                Duration = 3
            })
            return
        end
        
        if selectedMacro == "" then
            Fluent:Notify({
                Title = "Lỗi",
                Content = "Vui lòng chọn macro để xóa!",
                Duration = 3
            })
            return
        end
        
        -- Xóa file
        local success = pcall(function()
            delfile(macroFolder .. selectedMacro .. ".json")
        end)
        
        if success then
            -- Làm mới danh sách
            local macroDropdown = Fluent.Options.MacroSelect
            if macroDropdown then
                macroList = getMacroList()
                macroDropdown:SetValues(macroList)
                selectedMacro = ""
                currentMacro = {}
            end
            
            Fluent:Notify({
                Title = "Xóa Macro",
                Content = "Đã xóa macro: " .. selectedMacro,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Lỗi",
                Content = "Không thể xóa macro!",
                Duration = 3
            })
        end
    end
})
