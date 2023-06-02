--!strict
--//HOST
--// The main server script

--//VALUES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local BadgeService = game:GetService("BadgeService")

local serverAssets = ServerStorage.Assets
local remotes = ReplicatedStorage.Remotes

local ds = DataStoreService:GetDataStore("saves")
local dn = DataStoreService:GetDataStore("npcsaves")

local plrAppearances = {}

--//SETUP
PhysicsService:RegisterCollisionGroup("localPlayer")
PhysicsService:RegisterCollisionGroup("players")
PhysicsService:RegisterCollisionGroup("pushable")

PhysicsService:CollisionGroupSetCollidable("players","players",false)
PhysicsService:CollisionGroupSetCollidable("localPlayer","players",false)
PhysicsService:CollisionGroupSetCollidable("players","pushable",false)
PhysicsService:CollisionGroupSetCollidable("localPlayer","pushable",true)

--//TYPES
type plrAppearance = {
    name:string,
    skin:string,
    big:boolean
}

--//FUNCTIONS
function char(plr,plrappearance)
    plr.area.Value = ""

    local CHR = serverAssets.p:Clone()
    CHR.Name = plr.Name
    CHR.n.t.Text = plr.DisplayName
    if workspace.map:FindFirstChildOfClass("SpawnLocation") then
        CHR.Position = workspace.map:FindFirstChildOfClass("SpawnLocation").Position
    end
    CHR.Parent = workspace.char
    repeat task.wait() until CHR:CanSetNetworkOwnership()
    CHR:SetNetworkOwner(plr)
    CHR.CollisionGroup = "players"
end

function updateAppearance(char,appearance: plrAppearance)
    char.b.b.Image = appearance.skin
    if appearance.big == true then
        char.b.b.Size = UDim2.new(1.5,0,0.75,0)
        char.b.b.Position = UDim2.new(-0.25,0,0.25,0)
        char.h.fg1.ImageColor3 = Color3.new(1,0.7,0.1)
        char.h.fg2.ImageColor3 = Color3.new(1,0.7,0.1)
        char.b.crown.Visible = true
        char.h.StudsOffset = Vector3.new(0,2)
        char.n.StudsOffset = Vector3.new(0,2.5)
    end
end

--//REMOTES
remotes.room.OnServerEvent:Connect(function(plr,room)
    plr.area.Value = room
end)

remotes.save.OnServerEvent:Connect(function(p,dt,db)
    ds:SetAsync(p.userId,dt)
    dn:SetAsync(p.userId,db)

    remotes.save:FireClient(p,nil,true)
end)

remotes.load.OnServerEvent:Connect(function(p)
    if ds then
        local dos=ds:GetAsync(p.userId)
        local don=dn:GetAsync(p.userId)
        if dos then dos[6]=don end
        remotes.save:FireClient(p,dos)
    else remotes.save:FireClient(p)
    end 
end)

remotes.badge.OnServerEvent:Connect(function(usID,baID)usID=usID.userId
    BadgeService:AwardBadge(usID,baID)
end)

remotes.hasbadge.OnServerEvent:Connect(function(p: Player,baID,gamepass)
    local has
    if not gamepass then
        has = BadgeService:UserHasBadgeAsync(p.UserId,baID)
    else
        has = MarketplaceService:UserOwnsGamePassAsync(p.UserId,baID)
    end
    if not p:FindFirstChild("badge"..baID) then
        local tag = Instance.new("BoolValue")
        tag.Name = "badge"..baID
        if has then
            tag.Value = true
        end
        tag.Parent = p
    else
        local tag: any = p:FindFirstChild("badge"..baID)
        if has then
            tag.Value = true
        end
    end
    if not has and gamepass then
        MarketplaceService:PromptGamePassPurchase(p,baID)
    end
    remotes.hasbadge:FireClient(p,true)
end)

--appearance
remotes.Appearance.ChangeAppearance.OnServerEvent:Connect(function(plr,appearance:plrAppearance)
    local char = workspace.char:FindFirstChild(plr.Name)
    if not appearance or not char then return end
    updateAppearance(char,appearance)
end)

remotes.Appearance.GetAppearance.OnServerInvoke = function(plr,who)
    repeat task.wait() until plrAppearances[who] ~= nil
    return plrAppearances[who]
end

--reloading
remotes.reload.OnServerEvent:Connect(function(plr)
    local plrAppearance:plrAppearance = plrAppearances[plr.Name]
    plr.area.Value = ""
    if workspace.char:FindFirstChild(plr.Name) then
        workspace.char[plr.Name]:Destroy()
    end
    char(plr,plrAppearance)
end)

--//CONNECTIONS
Players.PlayerAdded:Connect(function(plr)
    local plrAppearance:plrAppearance = {
        name = plr.Name,
        skin = "",
        big = false
    }

    serverAssets.plrData.area:Clone().Parent = plr

    --appearance
    plrAppearances[plrAppearance.name] = plrAppearance

    if MarketplaceService:UserOwnsGamePassAsync(plr.UserId,1671185) then
        print("THE BIG BOY HAS ENTERED THE BUILDING")
        plrAppearance["big"] = true
    end

    char(plr,plrAppearance)
end)

Players.PlayerRemoving:Connect(function(plr)
    plrAppearances[plr.Name] = nil
    if workspace.char:FindFirstChild(plr.Name) then
        workspace.char[plr.Name]:Destroy()
    end
end)

--//map setup
for _,v in pairs(workspace.map:GetChildren())do
    if v.Name=='water'then
        workspace.Terrain:FillBlock(v.CFrame,v.Size,Enum.Material.Water)
        v:Destroy()
    end
end

for _,v in pairs(workspace.zones:GetChildren())do
    v.Transparency = 1
end

for _,v in pairs(workspace.map.push:GetChildren()) do
    if v:FindFirstChild'g' and v:FindFirstChild'p' then
        v.p.Position=v.Position
        v.g.CFrame=v.CFrame-v.Position
    end
    if v:IsA("BasePart") then
        v.CollisionGroup = "pushable"
    end
end