--[[ -----------------------------------------------------------
   Delta Executor Exploit – KingHub v1.0
   Features: Fly, XRay, King function (damage teleport)
   Author: Kirill
   ----------------------------------------------------------- ]]

-- KingHub authentication key (replace if needed)
local KING_KEY = "KingHub"

-- Utility: Get the local player and the game services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==========================
-- 1. Fly (King Function)
-- ==========================
local flyEnabled = false
local flySpeed = 100  -- adjust speed as desired

local function toggleFly()
    flyEnabled = not flyEnabled
    if flyEnabled then
        LocalPlayer.Character.Humanoid.PlatformStand = true
    else
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then   -- press F to toggle fly
        toggleFly()
    end
end)

RunService.RenderStepped:Connect(function()
    if not flyEnabled then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local moveDir = Vector3.new(
        (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) -
        (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
        (UserInputService:IsKeyDown(Enum.KeyCode.E) and 1 or 0) -
        (UserInputService:IsKeyDown(Enum.KeyCode.Q) and 1 or 0),
        (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0) -
        (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
    ).Unit

    root.Velocity = moveDir * flySpeed
end)

-- ==========================
-- 2. XRay (ESP)
-- ==========================
local xrayEnabled = false
local espFolder = Instance.new("Folder", workspace)

local function createESP(part)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = part
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 0, 0)   -- red glow
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.Parent = espFolder
end

local function toggleXRay()
    xrayEnabled = not xrayEnabled
    if xrayEnabled then
        for _, p in ipairs(workspace:GetDescendants()) do
            if p:IsA("BasePart") and p.Name == "HumanoidRootPart" then
                createESP(p)
            end
        end
    else
        espFolder:ClearAllChildren()
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then   -- press X to toggle X‑Ray
        toggleXRay()
    end
end)

-- ==========================
-- 3. Teleport & King Damage
-- ==========================
local function teleportAndKill(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer or not targetPlayer.Character then
        warn("Target not found: " .. targetName)
        return
    end

    -- Teleport local player to target
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and targetRoot then
        myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 5, 0)  -- appear above target
    end

    -- Deal damage (King function)
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:TakeDamage(1000)  -- massive damage to ensure kill
    end
end

-- UI for selecting a player (simple console command)
local function onChatMessage(msg)
    if msg:sub(1, 9):lower() == "!teleport" then
        local target = msg:sub(11)  -- expects "!teleport PlayerName"
        if target and target ~= "" then
            teleportAndKill(target)
        else
            warn("Usage: !teleport <PlayerName>")
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(onChatMessage)
end)

-- ==========================
-- Initialization Check
-- ==========================
if KING_KEY ~= "KingHub" then
    warn("Invalid KingHub key – script will not run.")
else
    print("KingHub script loaded – press F to fly, X for X‑Ray, and use !teleport <player> in chat.")
end
