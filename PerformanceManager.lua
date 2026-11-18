-- Create NarsEdv | Performance Manager (Updated & Fixed)
local executorEnv = getfenv() :: any

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

while not Players.LocalPlayer do
    task.wait()
end
local LocalPlayer = Players.LocalPlayer

local function warnMsg(message)
    warn("[Performance Manager] " .. tostring(message))
end

local genv = nil
pcall(function()
    if type(executorEnv.getgenv) == "function" then
        genv = executorEnv.getgenv()
    end
end)

if genv and type(genv.__PerformanceManager) == "table" and type(genv.__PerformanceManager.Shutdown) == "function" then
    pcall(genv.__PerformanceManager.Shutdown)
end

local function resolveHost(): Instance
    local getHiddenUi = executorEnv.gethui or executorEnv.get_hidden_gui
    if type(getHiddenUi) == "function" then
        local ok, hidden = pcall(getHiddenUi)
        if ok and typeof(hidden) == "Instance" then
            return hidden
        end
    end

    local ok, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok and typeof(coreGui) == "Instance" then
        return coreGui
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local host = resolveHost()

local Theme = {
    Background = Color3.fromHex("#0C0C0C"),
    Surface = Color3.fromHex("#121212"),
    SecondarySurface = Color3.fromHex("#181818"),
    Hover = Color3.fromHex("#242424"),
    Press = Color3.fromHex("#1E1E1E"),
    Border = Color3.fromHex("#262626"),
    Divider = Color3.fromHex("#262626"),
    Header = Color3.fromHex("#222222"),
    HeaderDivider = Color3.fromHex("#161616"),
    MutedText = Color3.fromHex("#8C8C8C"),
    PrimaryText = Color3.fromHex("#EBEBEB"),
    Active = Color3.fromHex("#FFFFFF"),

    ToggleOn = Color3.fromHex("#FFFFFF"),
    ToggleOff = Color3.fromHex("#242424"),
    ScrollTrack = Color3.fromHex("#121212"),
    ScrollHandle = Color3.fromHex("#4A4A4A"),
    ResizeActive = Color3.fromHex("#FFFFFF"),

    BtnScan = Color3.fromHex("#C4C4C4"),
    BtnScanHover = Color3.fromHex("#D8D8D8"),
    BtnScanPress = Color3.fromHex("#AEAEAE"),
    BtnScanText = Color3.fromHex("#0C0C0C"),

    BtnRestore = Color3.fromHex("#222222"),
    BtnRestoreHover = Color3.fromHex("#2E2E2E"),
    BtnRestorePress = Color3.fromHex("#181818"),
    BtnRestoreText = Color3.fromHex("#EBEBEB"),

    BtnRejoin = Color3.fromHex("#525252"),
    BtnRejoinHover = Color3.fromHex("#646464"),
    BtnRejoinPress = Color3.fromHex("#424242"),
    BtnRejoinText = Color3.fromHex("#FFFFFF"),

    BtnServerHop = Color3.fromHex("#DCDCDC"),
    BtnServerHopHover = Color3.fromHex("#FFFFFF"),
    BtnServerHopPress = Color3.fromHex("#C0C0C0"),
    BtnServerHopText = Color3.fromHex("#0C0C0C"),

    BtnSmallServer = Color3.fromHex("#161616"),
    BtnSmallServerHover = Color3.fromHex("#242424"),
    BtnSmallServerPress = Color3.fromHex("#101010"),
    BtnSmallServerText = Color3.fromHex("#EBEBEB")
}

local Icon = {
    Logo = "rbxassetid://122926744824622",
    ArrowLeft = "rbxassetid://92473583511724",
    ArrowRight = "rbxassetid://73780377692148",
    ArrowUp = "rbxassetid://117796781690923",
    ArrowDown = "rbxassetid://136612013728069",
    Close = "rbxassetid://110786993356448",
    Minimal = "rbxassetid://118026365011536",
    Maximize = "rbxassetid://134243273101015",
    Search = "rbxassetid://121018724060431",
    Checklist = "rbxassetid://95183312173858",
    Clear = "rbxassetid://115818216820315",
    Copy = "rbxassetid://78979572434545",

    ToggleOn = "rbxassetid://96479131758775",
    ToggleOff = "rbxassetid://118026365011536",
    AntiLag = "rbxassetid://132810618000212",
    HidePlayer = "rbxassetid://98944176636447",
    Server = "rbxassetid://114238209622913",
    Rejoin = "rbxassetid://117913330389477",
    ServerHop = "rbxassetid://97545944739523",
    SmallServer = "rbxassetid://139309232226438"
}

local function generateName()
    local chars = {}
    for i = 1, 24 do
        chars[i] = string.char(math.random(65, 90))
    end
    return "_PM_" .. table.concat(chars)
end

local GUI: {[string]: any} = {
    Toggles = {},
    Dropdowns = {},
    Resize = {},
    Cards = {}
}

local Core = {
    StateManager = {},
    InstanceTracker = {},
    OriginalPropertiesStorage = {},
    Connections = {},
    Running = true
}

local AntiLag = {
    ParticleManager = {},
    LightingManager = {},
    LightManager = {},
    CharacterEffectManager = {},
    EnvironmentManager = {},
    TextureManager = {},
    GraphicsManager = {},
    VisualManager = {},
    RenderingManager = {},
    RestoreManager = {}
}

local HidePlayers = {
    PlayerScanner = {},
    PlayerSelector = {},
    PlayerCard = {},
    ExclusionManager = {},
    PlayerVisibilityManager = {},
    AutoRefresh = {}
}

local ServerManager = {
    Busy = false,
    StatusText = "Ready"
}

local State = Core.StateManager
local Tracker = Core.InstanceTracker
local Storage = Core.OriginalPropertiesStorage

local CategorySources = {
    "Particle",
    "Lighting",
    "Light",
    "Character",
    "Environment",
    "Texture",
    "Shadow",
    "LowGraphics",
    "Weather",
    "MeshControl",
    "TextureQuality",
    "DecalVisibility",
    "ParticleDensity",
    "TransparencyControl",
    "LocalEffects",
    "TerrainDecoration",
    "TerrainWater",
    "TerrainGrass",
    "CloudsControl",
    "ReflectanceControl",
    "CastShadowControl",
    "Preset"
}

State.Toggles = {
    AntiLag = false,
    Particle = false,
    Lighting = false,
    Light = false,
    Character = false,
    Environment = false,
    Texture = false,
    Shadow = false,
    LowGraphics = false,
    Weather = false,

    MeshSpecial = false,
    MeshPart = false,
    MeshVisibility = false,
    TextureMap = false,
    MaterialVariant = false,
    DecalVisibility = false,
    LocalEffects = false,
    TerrainDecoration = false,
    TerrainWater = false,
    TerrainGrass = false,
    CloudsControl = false,
    ReflectanceControl = false,
    CastShadowControl = false,

    HidePlayers = false,
    HidePlayerNames = false,
    HidePlayerAccessories = false,
    HidePlayerEffects = false
}

State.Options = {
    GraphicsPreset = "Default",
    ParticleVisibility = "Full",
    ParticleDensity = "100%",
    TextureQuality = "Default",
    TransparencyMode = "Default"
}

State.HideEnabled = false
State.Excluded = {}
State.Restoring = false

function State.Reset()
    for key in pairs(State.Toggles) do
        State.Toggles[key] = false
    end
    State.Options.GraphicsPreset = "Default"
    State.Options.ParticleVisibility = "Full"
    State.Options.ParticleDensity = "100%"
    State.Options.TextureQuality = "Default"
    State.Options.TransparencyMode = "Default"
    State.HideEnabled = false
    State.Excluded = {}
end

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    Core.Connections[#Core.Connections + 1] = connection
    return connection
end

local function disconnectList(list)
    if not list then
        return
    end
    for i = #list, 1, -1 do
        local conn = list[i]
        list[i] = nil
        if conn then
            pcall(function()
                conn:Disconnect()
            end)
        end
    end
end

Storage.Data = {}
Storage.Index = {}
Storage.Permanent = {}
Storage.Releasing = {}

local function isAlive(instance)
    if typeof(instance) ~= "Instance" then
        return false
    end
    if Storage.Permanent[instance] then
        return true
    end
    local ok, result = pcall(function()
        return instance:IsDescendantOf(game)
    end)
    return ok and result == true
end

local ProtectedServices = {}
pcall(function()
    ProtectedServices.CoreGui = game:GetService("CoreGui")
end)
pcall(function()
    ProtectedServices.StarterGui = game:GetService("StarterGui")
end)

local function isProtectedGui(instance, allowCharacterBillboard)
    if typeof(instance) ~= "Instance" then
        return true
    end
    local okWs, inWorkspace = pcall(instance.IsDescendantOf, instance, Workspace)
    if okWs and inWorkspace then
        if instance:IsA("ScreenGui") or instance:IsA("PluginGui") then
            return true
        end
        if instance:FindFirstAncestorOfClass("ScreenGui") or instance:FindFirstAncestorOfClass("PlayerGui") then
            return true
        end
        if not allowCharacterBillboard and (instance:IsA("GuiBase2d") or instance:IsA("BillboardGui") or instance:IsA("SurfaceGui")) then
            return true
        end
        if not allowCharacterBillboard and (instance:FindFirstAncestorOfClass("BillboardGui") or instance:FindFirstAncestorOfClass("SurfaceGui")) then
            return true
        end
        return false
    end

    if GUI.Screen and (instance == GUI.Screen or instance:IsDescendantOf(GUI.Screen)) then
        return true
    end
    if ProtectedServices.CoreGui and (instance == ProtectedServices.CoreGui or instance:IsDescendantOf(ProtectedServices.CoreGui)) then
        return true
    end
    if ProtectedServices.StarterGui and (instance == ProtectedServices.StarterGui or instance:IsDescendantOf(ProtectedServices.StarterGui)) then
        return true
    end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui and (instance == playerGui or instance:IsDescendantOf(playerGui)) then
        return true
    end

    if instance:IsA("ScreenGui") or instance:IsA("PluginGui") then
        return true
    end
    if instance:FindFirstAncestorOfClass("ScreenGui") or instance:FindFirstAncestorOfClass("PlayerGui") then
        return true
    end
    if not allowCharacterBillboard and (instance:IsA("GuiBase2d") or instance:IsA("BillboardGui") or instance:IsA("SurfaceGui")) then
        return true
    end
    if not allowCharacterBillboard and (instance:FindFirstAncestorOfClass("BillboardGui") or instance:FindFirstAncestorOfClass("SurfaceGui")) then
        return true
    end

    return false
end

local function rawGetProp(instance, property)
    return instance[property]
end

local function rawSetProp(instance, property, value)
    instance[property] = value
end

local getHiddenProp = executorEnv.gethiddenproperty
local setHiddenProp = executorEnv.sethiddenproperty
local UnreadableProps = {}
local UnwritableProps = {}

local function readProperty(instance, property)
    local cacheKey = instance.ClassName .. ":" .. property
    if UnreadableProps[cacheKey] then
        return false, nil
    end
    local ok, value = pcall(rawGetProp, instance, property)
    if ok then
        return true, value
    end
    if type(getHiddenProp) == "function" then
        local okHidden, hiddenValue = pcall(getHiddenProp, instance, property)
        if okHidden then
            return true, hiddenValue
        end
    end
    UnreadableProps[cacheKey] = true
    return false, nil
end

local function writeProperty(instance, property, value)
    local cacheKey = instance.ClassName .. ":" .. property
    if UnwritableProps[cacheKey] then
        return false
    end
    local ok = pcall(rawSetProp, instance, property, value)
    if ok then
        Storage.FrameWrites = (Storage.FrameWrites or 0) + 1
        return true
    end
    if type(setHiddenProp) == "function" then
        local okHidden = pcall(setHiddenProp, instance, property, value)
        if okHidden then
            Storage.FrameWrites = (Storage.FrameWrites or 0) + 1
            return true
        end
    end
    UnwritableProps[cacheKey] = true
    return false
end

local function indexRecord(source, record)
    local set = Storage.Index[source]
    if not set then
        set = {}
        Storage.Index[source] = set
    end
    set[record] = true
end

function Storage.Apply(instance, property, value, source)
    if not isAlive(instance) then
        return false
    end

    local props = Storage.Data[instance]
    local record = props and props[property]

    if record then
        if not record.Sources[source] then
            record.Sources[source] = true
            record.SourceOrder[#record.SourceOrder + 1] = source
            indexRecord(source, record)
        end
        record.SourceValues[source] = value
        local ok, current = readProperty(instance, property)
        if ok and current ~= value then
            if writeProperty(instance, property, value) then
                record.Applied = value
            end
        else
            record.Applied = value
        end
        return true
    end

    local ok, current = readProperty(instance, property)
    if not ok then
        return false
    end
    if current == value then

        return false
    end
    if not writeProperty(instance, property, value) then
        return false
    end

    record = {
        Instance = instance,
        Property = property,
        Original = current,
        Applied = value,
        Category = source,
        Owner = "PerformanceManager",
        Sources = {[source] = true},
        SourceValues = {[source] = value},
        SourceOrder = {source}
    }

    if not props then
        props = {}
        Storage.Data[instance] = props
    end
    props[property] = record
    indexRecord(source, record)
    return true
end

function Storage.GetOriginal(instance, property)
    local props = Storage.Data[instance]
    local record = props and props[property]
    if record then
        return true, record.Original
    end
    return readProperty(instance, property)
end

Storage.ReleaseQueue = {}
Storage.ReleaseWorkerRunning = false
Storage.ReleaseActive = {}
Storage.FrameWrites = 0

local function yieldFrame()
    Storage.FrameWrites = 0
    local ok = pcall(function()
        RunService.Heartbeat:Wait()
    end)
    if not ok then
        task.wait()
    end
end

function Storage.Release(source)
    local set = Storage.Index[source]
    if not set then
        return
    end
    Storage.Index[source] = nil
    Storage.Releasing[source] = true

    local records = {}
    for record in pairs(set) do
        records[#records + 1] = record
    end

    local ok, err = pcall(function()
        local sliceStart = os.clock()
        for index, record in ipairs(records) do
            record.Sources[source] = nil
            record.SourceValues[source] = nil
            for i = #record.SourceOrder, 1, -1 do
                if record.SourceOrder[i] == source then
                    table.remove(record.SourceOrder, i)
                end
            end

            local instance = record.Instance
            if next(record.Sources) == nil then
                if isAlive(instance) then
                    local readOk, current = readProperty(instance, record.Property)
                    if readOk and current == record.Applied then
                        writeProperty(instance, record.Property, record.Original)
                    end
                end
                local props = Storage.Data[instance]
                if props then
                    props[record.Property] = nil
                    if next(props) == nil then
                        Storage.Data[instance] = nil
                    end
                end
            else
                local fallbackSource = record.SourceOrder[#record.SourceOrder]
                local fallbackVal = fallbackSource and record.SourceValues[fallbackSource]
                if fallbackVal ~= nil and isAlive(instance) then
                    if writeProperty(instance, record.Property, fallbackVal) then
                        record.Applied = fallbackVal
                    end
                end
            end

            if index % 45 == 0 or Storage.FrameWrites >= 35 or (os.clock() - sliceStart) >= 0.0018 then
                yieldFrame()
                sliceStart = os.clock()
            end
        end
    end)

    Storage.Releasing[source] = nil
    if not ok then
        warnMsg(err)
    end
end

function Storage.EnqueueRelease(source)
    if not Storage.Index[source] then
        return
    end
    if not Storage.ReleaseActive[source] then
        Storage.ReleaseActive[source] = true
        Storage.ReleaseQueue[#Storage.ReleaseQueue + 1] = source
    end
    if Storage.ReleaseWorkerRunning then
        return
    end
    Storage.ReleaseWorkerRunning = true

    task.spawn(function()
        while #Storage.ReleaseQueue > 0 do
            local nextSource = table.remove(Storage.ReleaseQueue, 1)
            Storage.ReleaseActive[nextSource] = nil
            Storage.Release(nextSource)
            yieldFrame()
        end
        Storage.ReleaseWorkerRunning = false
    end)
end

function Storage.Cleanup()
    for instance, props in pairs(Storage.Data) do
        if not isAlive(instance) then
            for _, record in pairs(props) do
                for source in pairs(record.Sources) do
                    local set = Storage.Index[source]
                    if set then
                        set[record] = nil
                    end
                end
            end
            Storage.Data[instance] = nil
        end
    end
end

Tracker.Processed = {}

function Tracker.Mark(source, instance)
    local set = Tracker.Processed[source]
    if not set then
        set = setmetatable({}, {__mode = "k"})
        Tracker.Processed[source] = set
    end
    if set[instance] then
        return false
    end
    set[instance] = true
    return true
end

function Tracker.Reset(source)
    Tracker.Processed[source] = nil
end

function Tracker.ResetAll()
    Tracker.Processed = {}
end

function Tracker.Clean()
    for _, set in pairs(Tracker.Processed) do
        for instance in pairs(set) do
            if not isAlive(instance) then
                set[instance] = nil
            end
        end
    end
end

local ParticleProps = {
    ParticleEmitter = "Enabled",
    Trail = "Enabled",
    Beam = "Enabled",
    Fire = "Enabled",
    Smoke = "Enabled",
    Sparkles = "Enabled",
    Explosion = "Visible"
}

local PostEffects = {
    BloomEffect = true,
    BlurEffect = true,
    ColorCorrectionEffect = true,
    DepthOfFieldEffect = true,
    SunRaysEffect = true
}

local LightClasses = {
    PointLight = true,
    SpotLight = true,
    SurfaceLight = true
}

local MaterialSkip = {
    [Enum.Material.Neon] = true,
    [Enum.Material.Glass] = true,
    [Enum.Material.ForceField] = true,
    [Enum.Material.Water] = true,
    [Enum.Material.Air] = true
}

local PartCache = {}

local function isPart(instance)
    local className = instance.ClassName
    local cached = PartCache[className]
    if cached == nil then
        cached = instance:IsA("BasePart") and className ~= "Terrain"
        PartCache[className] = cached
    end
    return cached
end

local CharacterCache = {}

local function refreshCharacterCache()
    local nextSet = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            nextSet[character] = true
        end
    end
    CharacterCache = nextSet
end

refreshCharacterCache()

local function isOtherPlayerCharacter(instance)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and (instance == character or instance:IsDescendantOf(character)) then
                return true
            end
        end
    end
    return false
end

local function belongsToAnyCharacter(instance)
    local p = instance
    while p and p ~= Workspace and p ~= game do
        if CharacterCache[p] then
            return true
        end
        p = p.Parent
    end
    return false
end

local function getCharacters()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character then
            list[#list + 1] = character
        end
    end
    return list
end

local function getMaterialService()
    local ok, service = pcall(function()
        return game:GetService("MaterialService")
    end)
    if ok and typeof(service) == "Instance" then
        return service
    end
    return nil
end

local function getTerrain()
    return Workspace:FindFirstChildOfClass("Terrain")
end

function AntiLag.ParticleManager.Process(instance, source)
    local property = ParticleProps[instance.ClassName]
    if not property or isProtectedGui(instance, false) then
        return
    end
    if Tracker.Mark(source, instance) then
        Storage.Apply(instance, property, false, source)
    end
end

function AntiLag.LightingManager.Process(instance, source)
    local className = instance.ClassName
    if PostEffects[className] then
        if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
            Storage.Apply(instance, "Enabled", false, source)
        end
    elseif source == "Lighting" then
        if className == "Atmosphere" then
            if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
                Storage.Apply(instance, "Density", 0, source)
                Storage.Apply(instance, "Haze", 0, source)
                Storage.Apply(instance, "Glare", 0, source)
            end
        elseif className == "Sky" then
            if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
                Storage.Apply(instance, "CelestialBodiesShown", false, source)
                Storage.Apply(instance, "StarCount", 0, source)
            end
        end
    end
end

function AntiLag.LightManager.Process(instance, source)
    if not LightClasses[instance.ClassName] or isProtectedGui(instance, false) then
        return
    end
    if Tracker.Mark(source, instance) then
        Storage.Apply(instance, "Enabled", false, source)
    end
end

function AntiLag.CharacterEffectManager.Process(instance, source, scoped)
    local className = instance.ClassName
    local property = ParticleProps[className]
    if not property and className == "Highlight" then
        property = "Enabled"
    end
    if not property or isProtectedGui(instance, false) then
        return
    end
    if not scoped and not belongsToAnyCharacter(instance) then
        return
    end
    if Tracker.Mark(source, instance) then
        Storage.Apply(instance, property, false, source)
    end
end

function AntiLag.EnvironmentManager.Process(instance, source)
    local className = instance.ClassName
    if className == "Clouds" then
        if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
            Storage.Apply(instance, "Enabled", false, source)
        end
    elseif className == "Terrain" then
        if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
            Storage.Apply(instance, "Decoration", false, source)
            Storage.Apply(instance, "WaterWaveSize", 0, source)
            Storage.Apply(instance, "WaterWaveSpeed", 0, source)
            Storage.Apply(instance, "WaterReflectance", 0, source)
        end
    end
end

function AntiLag.TextureManager.Process(instance, source)
    local className = instance.ClassName
    if className == "Decal" or className == "Texture" then
        if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
            Storage.Apply(instance, "Transparency", 1, source)
        end
    elseif className == "SurfaceAppearance" or className == "MaterialVariant" then
        if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
            Storage.Apply(instance, "NormalMap", "", source)
            Storage.Apply(instance, "MetalnessMap", "", source)
            Storage.Apply(instance, "RoughnessMap", "", source)
        end
    elseif className == "SpecialMesh" then
        if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
            Storage.Apply(instance, "TextureId", "", source)
        end
    end
end

function AntiLag.GraphicsManager.ProcessShadow(instance, source)
    if not isPart(instance) or isProtectedGui(instance, false) then
        return
    end
    if Tracker.Mark(source, instance) then
        Storage.Apply(instance, "CastShadow", false, source)
    end
end

function AntiLag.GraphicsManager.ProcessLow(instance, source)
    local className = instance.ClassName
    if ParticleProps[className] then
        AntiLag.ParticleManager.Process(instance, source)
    elseif PostEffects[className] then
        AntiLag.LightingManager.Process(instance, source)
    elseif isPart(instance) then
        if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
            Storage.Apply(instance, "CastShadow", false, source)
            Storage.Apply(instance, "Reflectance", 0, source)
            local ok, material = readProperty(instance, "Material")
            if ok and not MaterialSkip[material] then
                Storage.Apply(instance, "Material", Enum.Material.SmoothPlastic, source)
            end
        end
    end
end

function AntiLag.VisualManager.ProcessWeather(instance, source)
    local className = instance.ClassName
    if className == "Clouds" then
        if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
            Storage.Apply(instance, "Enabled", false, source)
        end
    elseif className == "Atmosphere" then
        if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
            Storage.Apply(instance, "Density", 0, source)
            Storage.Apply(instance, "Haze", 0, source)
        end
    elseif className == "Terrain" then
        if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
            Storage.Apply(instance, "WaterWaveSize", 0, source)
            Storage.Apply(instance, "WaterWaveSpeed", 0, source)
        end
    elseif className == "ParticleEmitter" then
        local lowerName = string.lower(instance.Name)
        if string.find(lowerName, "rain", 1, true)
            or string.find(lowerName, "snow", 1, true)
            or string.find(lowerName, "fog", 1, true)
            or string.find(lowerName, "wind", 1, true)
            or string.find(lowerName, "weather", 1, true)
            or string.find(lowerName, "storm", 1, true) then
            if not isProtectedGui(instance, false) and Tracker.Mark(source, instance) then
                Storage.Apply(instance, "Enabled", false, source)
            end
        end
    end
end

function AntiLag.RenderingManager.ProcessMesh(instance, source)
    local className = instance.ClassName
    if className ~= "SpecialMesh" and className ~= "MeshPart" then
        return
    end
    if isProtectedGui(instance, false) or belongsToAnyCharacter(instance) then
        return
    end
    if State.Toggles.MeshSpecial and className == "SpecialMesh" then
        if Tracker.Mark(source, instance) then
            Storage.Apply(instance, "TextureId", "", source)
        end
    elseif State.Toggles.MeshPart and className == "MeshPart" then
        if Tracker.Mark(source, instance) then
            Storage.Apply(instance, "RenderFidelity", Enum.RenderFidelity.Performance, source)
            Storage.Apply(instance, "CastShadow", false, source)
        end
    end
    if State.Toggles.MeshVisibility then
        if className == "MeshPart" then
            if Tracker.Mark(source .. "_Vis", instance) then
                Storage.Apply(instance, "LocalTransparencyModifier", 1, source)
            end
        elseif className == "SpecialMesh" and instance.Parent and isPart(instance.Parent) then
            if Tracker.Mark(source .. "_Vis", instance.Parent) then
                Storage.Apply(instance.Parent, "LocalTransparencyModifier", 1, source)
            end
        end
    end
end

function AntiLag.RenderingManager.ProcessTextureQuality(instance, source)
    local mode = State.Options.TextureQuality
    if mode == "Default" and not State.Toggles.TextureMap and not State.Toggles.MaterialVariant then
        return
    end
    local className = instance.ClassName
    if className ~= "Texture" and className ~= "SurfaceAppearance" and className ~= "MaterialVariant" then
        return
    end
    if isProtectedGui(instance, false) then
        return
    end
    if (State.Toggles.TextureMap or mode ~= "Default") and (className == "Texture" or className == "SurfaceAppearance") then
        if Tracker.Mark(source, instance) then
            if className == "SurfaceAppearance" then
                Storage.Apply(instance, "NormalMap", "", source)
                Storage.Apply(instance, "MetalnessMap", "", source)
                Storage.Apply(instance, "RoughnessMap", "", source)
                if mode == "Minimal" then
                    Storage.Apply(instance, "ColorMap", "", source)
                end
            elseif className == "Texture" then
                if mode == "Minimal" or State.Toggles.TextureMap then
                    Storage.Apply(instance, "Transparency", 1, source)
                elseif mode == "Reduced" then
                    Storage.Apply(instance, "Transparency", 0.65, source)
                end
            end
        end
    elseif (State.Toggles.MaterialVariant or mode ~= "Default") and className == "MaterialVariant" then
        if Tracker.Mark(source, instance) then
            Storage.Apply(instance, "NormalMap", "", source)
            Storage.Apply(instance, "MetalnessMap", "", source)
            Storage.Apply(instance, "RoughnessMap", "", source)
            if mode == "Minimal" then
                Storage.Apply(instance, "ColorMap", "", source)
            end
        end
    end
end

function AntiLag.RenderingManager.ProcessDecalVisibility(instance, source)
    local className = instance.ClassName
    if className ~= "Decal" and className ~= "Texture" then
        return
    end
    if isProtectedGui(instance, false) or belongsToAnyCharacter(instance) then
        return
    end
    if Tracker.Mark(source, instance) then
        Storage.Apply(instance, "Transparency", 1, source)
    end
end

function AntiLag.RenderingManager.ProcessParticleDensity(instance, source)
    local className = instance.ClassName
    if not ParticleProps[className] then
        return
    end
    if isProtectedGui(instance, false) then
        return
    end
    local visMode = State.Options.ParticleVisibility
    local densityStr = State.Options.ParticleDensity

    local factor = 1
    if visMode == "Hidden" or densityStr == "0%" then
        factor = 0
    elseif visMode == "Reduced" then
        factor = 0.25
    elseif densityStr == "50%" then
        factor = 0.5
    elseif densityStr == "25%" then
        factor = 0.25
    end

    if factor >= 1 then
        return
    end

    if Tracker.Mark(source, instance) then
        if factor == 0 then
            Storage.Apply(instance, ParticleProps[className], false, source)
        elseif className == "ParticleEmitter" then
            local ok, origRate = Storage.GetOriginal(instance, "Rate")
            if ok and type(origRate) == "number" then
                Storage.Apply(instance, "Rate", math.max(1, math.floor(origRate * factor)), source)
            end
        end
    end
end

function AntiLag.RenderingManager.ProcessTransparencyControl(instance, source)
    local mode = State.Options.TransparencyMode
    if mode == "Default" or not isPart(instance) then
        return
    end
    if isProtectedGui(instance, false) or belongsToAnyCharacter(instance) then
        return
    end
    if Tracker.Mark(source, instance) then
        local ok, trans = readProperty(instance, "Transparency")
        if ok and type(trans) == "number" and trans > 0 and trans < 1 then
            if mode == "Simplify" then
                Storage.Apply(instance, "Reflectance", 0, source)
                Storage.Apply(instance, "CastShadow", false, source)
                local okMat, mat = readProperty(instance, "Material")
                if okMat and mat == Enum.Material.Glass then
                    Storage.Apply(instance, "Material", Enum.Material.SmoothPlastic, source)
                end
            elseif mode == "Hide" then
                Storage.Apply(instance, "LocalTransparencyModifier", 1, source)
            end
        end
    end
end

function AntiLag.RenderingManager.ProcessLocalEffects(instance, source)
    local className = instance.ClassName
    local prop = ParticleProps[className]
    if not prop and className == "Highlight" then
        prop = "Enabled"
    end
    if not prop or isProtectedGui(instance, false) then
        return
    end
    if Tracker.Mark(source, instance) then
        Storage.Apply(instance, prop, false, source)
    end
end

function AntiLag.RenderingManager.ProcessTerrainDecoration(instance, source)
    if instance.ClassName == "Terrain" and Tracker.Mark(source, instance) then
        Storage.Apply(instance, "Decoration", false, source)
    end
end

function AntiLag.RenderingManager.ProcessTerrainWater(instance, source)
    if instance.ClassName == "Terrain" and Tracker.Mark(source, instance) then
        Storage.Apply(instance, "WaterWaveSize", 0, source)
        Storage.Apply(instance, "WaterWaveSpeed", 0, source)
        Storage.Apply(instance, "WaterReflectance", 0, source)
    end
end

function AntiLag.RenderingManager.ProcessTerrainGrass(instance, source)
    if instance.ClassName == "Terrain" and Tracker.Mark(source, instance) then
        Storage.Apply(instance, "Decoration", false, source)
    end
end

function AntiLag.RenderingManager.ProcessClouds(instance, source)
    if instance.ClassName == "Clouds" and Tracker.Mark(source, instance) then
        Storage.Apply(instance, "Enabled", false, source)
    end
end

function AntiLag.RenderingManager.ProcessReflectance(instance, source)
    if not isPart(instance) or isProtectedGui(instance, false) then
        return
    end
    if Tracker.Mark(source, instance) then
        Storage.Apply(instance, "Reflectance", 0, source)
    end
end

function AntiLag.RenderingManager.ProcessCastShadow(instance, source)
    if not isPart(instance) or isProtectedGui(instance, false) then
        return
    end
    if Tracker.Mark(source, instance) then
        Storage.Apply(instance, "CastShadow", false, source)
    end
end

local Processors = {
    Particle = function(instance)
        AntiLag.ParticleManager.Process(instance, "Particle")
    end,
    Lighting = function(instance)
        AntiLag.LightingManager.Process(instance, "Lighting")
    end,
    Light = function(instance)
        AntiLag.LightManager.Process(instance, "Light")
    end,
    Character = function(instance, scoped)
        AntiLag.CharacterEffectManager.Process(instance, "Character", scoped)
    end,
    Environment = function(instance)
        AntiLag.EnvironmentManager.Process(instance, "Environment")
    end,
    Texture = function(instance)
        AntiLag.TextureManager.Process(instance, "Texture")
    end,
    Shadow = function(instance)
        AntiLag.GraphicsManager.ProcessShadow(instance, "Shadow")
    end,
    LowGraphics = function(instance)
        AntiLag.GraphicsManager.ProcessLow(instance, "LowGraphics")
    end,
    Weather = function(instance)
        AntiLag.VisualManager.ProcessWeather(instance, "Weather")
    end,
    MeshControl = function(instance)
        AntiLag.RenderingManager.ProcessMesh(instance, "MeshControl")
    end,
    TextureQuality = function(instance)
        AntiLag.RenderingManager.ProcessTextureQuality(instance, "TextureQuality")
    end,
    DecalVisibility = function(instance)
        AntiLag.RenderingManager.ProcessDecalVisibility(instance, "DecalVisibility")
    end,
    ParticleDensity = function(instance)
        AntiLag.RenderingManager.ProcessParticleDensity(instance, "ParticleDensity")
    end,
    TransparencyControl = function(instance)
        AntiLag.RenderingManager.ProcessTransparencyControl(instance, "TransparencyControl")
    end,
    LocalEffects = function(instance)
        AntiLag.RenderingManager.ProcessLocalEffects(instance, "LocalEffects")
    end,
    TerrainDecoration = function(instance)
        AntiLag.RenderingManager.ProcessTerrainDecoration(instance, "TerrainDecoration")
    end,
    TerrainWater = function(instance)
        AntiLag.RenderingManager.ProcessTerrainWater(instance, "TerrainWater")
    end,
    TerrainGrass = function(instance)
        AntiLag.RenderingManager.ProcessTerrainGrass(instance, "TerrainGrass")
    end,
    CloudsControl = function(instance)
        AntiLag.RenderingManager.ProcessClouds(instance, "CloudsControl")
    end,
    ReflectanceControl = function(instance)
        AntiLag.RenderingManager.ProcessReflectance(instance, "ReflectanceControl")
    end,
    CastShadowControl = function(instance)
        AntiLag.RenderingManager.ProcessCastShadow(instance, "CastShadowControl")
    end
}

local function workspaceAndMaterialRoots()
    local list = {Workspace}
    local service = getMaterialService()
    if service then
        list[#list + 1] = service
    end
    return list
end

local function terrainRoot()
    local t = getTerrain()
    if t then
        return {t}
    end
    return {}
end

local Roots = {
    Particle = function()
        return {Workspace}
    end,
    Lighting = function()
        local list = {Lighting}
        local camera = Workspace.CurrentCamera
        if camera then
            list[#list + 1] = camera
        end
        return list
    end,
    Light = function()
        return {Workspace}
    end,
    Character = getCharacters,
    Environment = function()
        local list = {}
        local t = getTerrain()
        if t then
            list[#list + 1] = t
        end
        for _, child in ipairs(Workspace:GetChildren()) do
            if child:IsA("Clouds") then
                list[#list + 1] = child
            end
        end
        return list
    end,
    Texture = workspaceAndMaterialRoots,
    Shadow = function()
        return {Workspace}
    end,
    LowGraphics = function()
        return {Workspace, Lighting}
    end,
    Weather = function()
        local list = {Workspace, Lighting}
        local t = getTerrain()
        if t then
            list[#list + 1] = t
        end
        return list
    end,
    MeshControl = function()
        return {Workspace}
    end,
    TextureQuality = workspaceAndMaterialRoots,
    DecalVisibility = function()
        return {Workspace}
    end,
    ParticleDensity = function()
        return {Workspace}
    end,
    TransparencyControl = function()
        return {Workspace}
    end,
    LocalEffects = function()
        return {Workspace}
    end,
    TerrainDecoration = terrainRoot,
    TerrainWater = terrainRoot,
    TerrainGrass = terrainRoot,
    CloudsControl = function()
        local list = {}
        local t = getTerrain()
        if t then
            for _, child in ipairs(t:GetChildren()) do
                if child:IsA("Clouds") then
                    list[#list + 1] = child
                end
            end
        end
        for _, child in ipairs(Workspace:GetChildren()) do
            if child:IsA("Clouds") then
                list[#list + 1] = child
            end
        end
        return list
    end,
    ReflectanceControl = function()
        return {Workspace}
    end,
    CastShadowControl = function()
        return {Workspace}
    end
}

local Statics = {
    Shadow = function(source)
        Storage.Apply(Lighting, "GlobalShadows", false, source)
    end,
    CastShadowControl = function(source)
        Storage.Apply(Lighting, "GlobalShadows", false, source)
    end,
    LowGraphics = function(source)
        Storage.Apply(Lighting, "GlobalShadows", false, source)
        Storage.Apply(Lighting, "ShadowSoftness", 0, source)
        local ok, rendering = pcall(function()
            return settings().Rendering
        end)
        if ok and typeof(rendering) == "Instance" then
            Storage.Permanent[rendering] = true
            Storage.Apply(rendering, "QualityLevel", Enum.QualityLevel.Level01, source)
        end
    end
}

local function isSourceActive(source)
    if source == "Particle" or source == "Lighting" or source == "Light" or source == "Character"
        or source == "Environment" or source == "Texture" or source == "Shadow" or source == "LowGraphics"
        or source == "Weather" then
        return State.Toggles.AntiLag and State.Toggles[source] == true
    elseif source == "MeshControl" then
        return State.Toggles.MeshSpecial or State.Toggles.MeshPart or State.Toggles.MeshVisibility
    elseif source == "TextureQuality" then
        return State.Options.TextureQuality ~= "Default" or State.Toggles.TextureMap or State.Toggles.MaterialVariant
    elseif source == "DecalVisibility" then
        return State.Toggles.DecalVisibility
    elseif source == "ParticleDensity" then
        return State.Options.ParticleVisibility ~= "Full" or State.Options.ParticleDensity ~= "100%"
    elseif source == "TransparencyControl" then
        return State.Options.TransparencyMode ~= "Default"
    elseif source == "LocalEffects" then
        return State.Toggles.LocalEffects
    elseif source == "TerrainDecoration" then
        return State.Toggles.TerrainDecoration
    elseif source == "TerrainWater" then
        return State.Toggles.TerrainWater
    elseif source == "TerrainGrass" then
        return State.Toggles.TerrainGrass
    elseif source == "CloudsControl" then
        return State.Toggles.CloudsControl
    elseif source == "ReflectanceControl" then
        return State.Toggles.ReflectanceControl
    elseif source == "CastShadowControl" then
        return State.Toggles.CastShadowControl
    end
    return false
end

local WorkspaceBatchSources = {
    Particle = true,
    Light = true,
    Texture = true,
    Shadow = true,
    LowGraphics = true,
    Weather = true,
    MeshControl = true,
    TextureQuality = true,
    DecalVisibility = true,
    ParticleDensity = true,
    TransparencyControl = true,
    LocalEffects = true,
    ReflectanceControl = true,
    CastShadowControl = true
}

local Engine = {
    Generation = {},
    Queue = {},
    QueuedSet = {},
    WorkerRunning = false
}

local function isSourceStale(source, generation)
    return not Core.Running
        or State.Restoring
        or Engine.Generation[source] ~= generation
        or not isSourceActive(source)
end

local function traverseRootIncremental(root, visitFn, shouldStopFn)
    local stack = {root}
    local sp = 1
    local counter = 0
    local sliceStart = os.clock()

    while sp > 0 do
        if shouldStopFn() then
            return false
        end

        local node = stack[sp]
        stack[sp] = nil
        sp = sp - 1

        visitFn(node)
        counter = counter + 1

        local okKids, children = pcall(node.GetChildren, node)
        if okKids and type(children) == "table" then
            for i = #children, 1, -1 do
                sp = sp + 1
                stack[sp] = children[i]
            end
        end

        if Storage.FrameWrites >= 35 or (counter % 60 == 0 and (os.clock() - sliceStart) >= 0.0018) then
            yieldFrame()
            sliceStart = os.clock()
            if shouldStopFn() then
                return false
            end
        end
    end

    return true
end

local function waitReleaseForSource(source, generation)
    while Storage.Releasing[source] or Storage.ReleaseActive[source] do
        if not Core.Running or Engine.Generation[source] ~= generation then
            return false
        end
        yieldFrame()
    end
    return true
end

local function processSingleSource(source, generation)
    if not waitReleaseForSource(source, generation) then
        return
    end
    if isSourceStale(source, generation) then
        return
    end

    refreshCharacterCache()

    local static = Statics[source]
    if static then
        local ok, err = pcall(static, source)
        if not ok then
            warnMsg(err)
        end
        yieldFrame()
    end

    if isSourceStale(source, generation) then
        return
    end

    local processor = Processors[source]
    local rootFn = Roots[source]
    if not processor or not rootFn then
        return
    end

    local okRoots, roots = pcall(rootFn)
    if not okRoots or type(roots) ~= "table" then
        return
    end

    for _, root in ipairs(roots) do
        if isSourceStale(source, generation) then
            return
        end
        local completed = traverseRootIncremental(root, function(instance)
            pcall(processor, instance, true)
        end, function()
            return isSourceStale(source, generation)
        end)
        if not completed then
            return
        end
        yieldFrame()
    end
end

local function processWorkspaceBatch(batchItems)
    refreshCharacterCache()

    local activeItems = {}
    for _, item in ipairs(batchItems) do
        local source = item.Source
        local gen = item.Generation
        if waitReleaseForSource(source, gen) and not isSourceStale(source, gen) then
            local static = Statics[source]
            if static then
                pcall(static, source)
                yieldFrame()
            end
            if not isSourceStale(source, gen) then
                activeItems[#activeItems + 1] = item
            end
        end
    end

    if #activeItems == 0 then
        return
    end

    local matService = getMaterialService()
    local auxVisited = {}
    local auxRoots = {}
    for _, item in ipairs(activeItems) do
        local s = item.Source
        if s == "LowGraphics" or s == "Weather" then
            if not auxVisited[Lighting] then
                auxVisited[Lighting] = true
                auxRoots[#auxRoots + 1] = Lighting
            end
        end
        if (s == "Texture" or s == "TextureQuality") and matService and not auxVisited[matService] then
            auxVisited[matService] = true
            auxRoots[#auxRoots + 1] = matService
        end
    end

    for _, auxRoot in ipairs(auxRoots) do
        traverseRootIncremental(auxRoot, function(instance)
            for _, item in ipairs(activeItems) do
                if not isSourceStale(item.Source, item.Generation) then
                    local proc = Processors[item.Source]
                    if proc then
                        pcall(proc, instance, true)
                    end
                end
            end
        end, function()
            return not Core.Running or State.Restoring
        end)
        yieldFrame()
    end

    local terrain = getTerrain()
    if terrain then
        for _, item in ipairs(activeItems) do
            if item.Source == "Weather" and not isSourceStale(item.Source, item.Generation) then
                pcall(Processors.Weather, terrain, true)
                yieldFrame()
            end
        end
    end

    traverseRootIncremental(Workspace, function(instance)
        for _, item in ipairs(activeItems) do
            local s = item.Source
            if not isSourceStale(s, item.Generation) then
                local proc = Processors[s]
                if proc then
                    pcall(proc, instance, true)
                end
            end
        end
    end, function()
        if not Core.Running or State.Restoring then
            return true
        end
        for _, item in ipairs(activeItems) do
            if not isSourceStale(item.Source, item.Generation) then
                return false
            end
        end
        return true
    end)
end

function Engine.Run(source)
    local generation = (Engine.Generation[source] or 0) + 1
    Engine.Generation[source] = generation

    if not Engine.QueuedSet[source] then
        Engine.QueuedSet[source] = true
        Engine.Queue[#Engine.Queue + 1] = source
    end

    if Engine.WorkerRunning then
        return
    end
    Engine.WorkerRunning = true

    task.spawn(function()
        while Core.Running and not State.Restoring and #Engine.Queue > 0 do
            local nextSource = table.remove(Engine.Queue, 1)
            Engine.QueuedSet[nextSource] = nil

            if WorkspaceBatchSources[nextSource] then

                local batch = {{Source = nextSource, Generation = Engine.Generation[nextSource] or 0}}
                local i = 1
                while i <= #Engine.Queue do
                    local s = Engine.Queue[i]
                    if WorkspaceBatchSources[s] then
                        table.remove(Engine.Queue, i)
                        Engine.QueuedSet[s] = nil
                        batch[#batch + 1] = {Source = s, Generation = Engine.Generation[s] or 0}
                    else
                        i = i + 1
                    end
                end
                if #batch > 1 then
                    processWorkspaceBatch(batch)
                else
                    processSingleSource(nextSource, batch[1].Generation)
                end
            else
                local gen = Engine.Generation[nextSource] or 0
                processSingleSource(nextSource, gen)
            end
            yieldFrame()
        end
        Engine.WorkerRunning = false
    end)
end

function Engine.Stop(source)
    Engine.Generation[source] = (Engine.Generation[source] or 0) + 1
    Engine.QueuedSet[source] = nil
    for i = #Engine.Queue, 1, -1 do
        if Engine.Queue[i] == source then
            table.remove(Engine.Queue, i)
        end
    end
    Tracker.Reset(source)
    Storage.EnqueueRelease(source)
end

AntiLag.WatchQueue = {}
AntiLag.WatchSet = setmetatable({}, {__mode = "k"})
AntiLag.WatchWorkerRunning = false

local function drainWatchQueue()
    if AntiLag.WatchWorkerRunning then
        return
    end
    AntiLag.WatchWorkerRunning = true

    task.spawn(function()
        local sliceStart = os.clock()
        local processed = 0
        while Core.Running and not State.Restoring and AntiLag.WatchConnections and #AntiLag.WatchQueue > 0 do
            local instance = table.remove(AntiLag.WatchQueue, 1)
            AntiLag.WatchSet[instance] = nil

            if isAlive(instance) then
                for _, source in ipairs(CategorySources) do
                    if source ~= "Preset" and isSourceActive(source) and not Storage.Releasing[source] then
                        local proc = Processors[source]
                        if proc then
                            pcall(proc, instance, false)
                        end
                    end
                end
            end

            processed = processed + 1
            if Storage.FrameWrites >= 25 or (processed % 25 == 0 and (os.clock() - sliceStart) >= 0.0012) then
                yieldFrame()
                sliceStart = os.clock()
                refreshCharacterCache()
            end
        end
        AntiLag.WatchWorkerRunning = false
    end)
end

function AntiLag.StartWatch()
    if AntiLag.WatchConnections then
        return
    end

    local function onAdded(instance)
        if not Core.Running or State.Restoring then
            return
        end
        if not AntiLag.WatchSet[instance] then
            AntiLag.WatchSet[instance] = true
            AntiLag.WatchQueue[#AntiLag.WatchQueue + 1] = instance
            drainWatchQueue()
        end
    end

    AntiLag.WatchConnections = {
        Workspace.DescendantAdded:Connect(onAdded),
        Lighting.DescendantAdded:Connect(onAdded)
    }
end

function AntiLag.StopWatch()
    if AntiLag.WatchConnections then
        disconnectList(AntiLag.WatchConnections)
        AntiLag.WatchConnections = nil
    end
    AntiLag.WatchQueue = {}
    AntiLag.WatchSet = setmetatable({}, {__mode = "k"})
end

function AntiLag.Activate()
    AntiLag.StartWatch()
    for _, source in ipairs(CategorySources) do
        if source ~= "Preset" and isSourceActive(source) then
            Engine.Run(source)
        end
    end
end

function AntiLag.SetMaster(value)
    State.Toggles.AntiLag = value and true or false
    if State.Toggles.AntiLag then
        AntiLag.Activate()
    else
        for _, source in ipairs({"Particle", "Lighting", "Light", "Character", "Environment", "Texture", "Shadow", "LowGraphics", "Weather"}) do
            Engine.Stop(source)
        end
    end
end

function AntiLag.SetCategory(key, value)
    State.Toggles[key] = value and true or false
    if State.Toggles[key] and not State.Toggles.AntiLag then
        State.Toggles.AntiLag = true
        if GUI.Toggles.AntiLag then
            GUI.Toggles.AntiLag:Set(true, true)
        end
        AntiLag.Activate()
        return
    end
    if State.Toggles.AntiLag then
        if State.Toggles[key] then
            Engine.Run(key)
        else
            Engine.Stop(key)
        end
    end
end

function AntiLag.Rescan()
    AntiLag.StartWatch()
    for _, source in ipairs(CategorySources) do
        if source ~= "Preset" and isSourceActive(source) then
            Tracker.Reset(source)
            Engine.Run(source)
        end
    end
end

function AntiLag.RenderingManager.RefreshSource(source)
    AntiLag.StartWatch()
    Engine.Stop(source)
    if isSourceActive(source) then
        Engine.Run(source)
    end
end

function AntiLag.RenderingManager.SetToggle(key, source, value)
    State.Toggles[key] = value and true or false
    AntiLag.RenderingManager.RefreshSource(source)
end

local GraphicsPresets = {
    Default = {
        Toggles = {
            AntiLag = false,
            Particle = false,
            Lighting = false,
            Light = false,
            Character = false,
            Environment = false,
            Texture = false,
            Shadow = false,
            LowGraphics = false,
            Weather = false,
            MeshSpecial = false,
            MeshPart = false,
            MeshVisibility = false,
            TextureMap = false,
            MaterialVariant = false,
            DecalVisibility = false,
            LocalEffects = false,
            TerrainDecoration = false,
            TerrainWater = false,
            TerrainGrass = false,
            CloudsControl = false,
            ReflectanceControl = false,
            CastShadowControl = false
        },
        Options = {
            ParticleVisibility = "Full",
            ParticleDensity = "100%",
            TextureQuality = "Default",
            TransparencyMode = "Default"
        },
        QualityLevel = nil
    },
    Balanced = {
        Toggles = {
            AntiLag = true,
            Particle = false,
            Lighting = true,
            Light = false,
            Character = false,
            Environment = false,
            Texture = false,
            Shadow = true,
            LowGraphics = false,
            Weather = false,
            MeshSpecial = false,
            MeshPart = true,
            MeshVisibility = false,
            TextureMap = false,
            MaterialVariant = false,
            DecalVisibility = false,
            LocalEffects = false,
            TerrainDecoration = false,
            TerrainWater = true,
            TerrainGrass = false,
            CloudsControl = false,
            ReflectanceControl = true,
            CastShadowControl = false
        },
        Options = {
            ParticleVisibility = "Reduced",
            ParticleDensity = "50%",
            TextureQuality = "Default",
            TransparencyMode = "Simplify"
        },
        QualityLevel = Enum.QualityLevel.Level04
    },
    Performance = {
        Toggles = {
            AntiLag = true,
            Particle = true,
            Lighting = true,
            Light = true,
            Character = true,
            Environment = true,
            Texture = false,
            Shadow = true,
            LowGraphics = false,
            Weather = true,
            MeshSpecial = false,
            MeshPart = true,
            MeshVisibility = false,
            TextureMap = true,
            MaterialVariant = true,
            DecalVisibility = false,
            LocalEffects = true,
            TerrainDecoration = true,
            TerrainWater = true,
            TerrainGrass = true,
            CloudsControl = true,
            ReflectanceControl = true,
            CastShadowControl = true
        },
        Options = {
            ParticleVisibility = "Hidden",
            ParticleDensity = "25%",
            TextureQuality = "Reduced",
            TransparencyMode = "Simplify"
        },
        QualityLevel = Enum.QualityLevel.Level02
    },
    ["Ultra Performance"] = {
        Toggles = {
            AntiLag = true,
            Particle = true,
            Lighting = true,
            Light = true,
            Character = true,
            Environment = true,
            Texture = true,
            Shadow = true,
            LowGraphics = true,
            Weather = true,
            MeshSpecial = true,
            MeshPart = true,
            MeshVisibility = false,
            TextureMap = true,
            MaterialVariant = true,
            DecalVisibility = true,
            LocalEffects = true,
            TerrainDecoration = true,
            TerrainWater = true,
            TerrainGrass = true,
            CloudsControl = true,
            ReflectanceControl = true,
            CastShadowControl = true
        },
        Options = {
            ParticleVisibility = "Hidden",
            ParticleDensity = "0%",
            TextureQuality = "Minimal",
            TransparencyMode = "Simplify"
        },
        QualityLevel = Enum.QualityLevel.Level01
    }
}

local syncVisualControls = function() end

function AntiLag.VisualManager.MarkCustom()
    if State.Options.GraphicsPreset ~= "Custom" then
        State.Options.GraphicsPreset = "Custom"
        if GUI.Dropdowns.GraphicsPreset then
            GUI.Dropdowns.GraphicsPreset:Set("Custom", true)
        end
    end
end

function AntiLag.VisualManager.ApplyPreset(presetName)
    State.Options.GraphicsPreset = presetName
    if presetName == "Custom" then
        return
    end

    local config = GraphicsPresets[presetName]
    if not config then
        return
    end

    Engine.Stop("Preset")

    for key, val in pairs(config.Toggles) do
        State.Toggles[key] = val
    end
    for key, val in pairs(config.Options) do
        State.Options[key] = val
    end

    syncVisualControls()

    if presetName == "Default" then
        for _, source in ipairs(CategorySources) do
            Engine.Stop(source)
        end
        return
    end

    if config.QualityLevel then
        local ok, rendering = pcall(function()
            return settings().Rendering
        end)
        if ok and typeof(rendering) == "Instance" then
            Storage.Permanent[rendering] = true
            Storage.Apply(rendering, "QualityLevel", config.QualityLevel, "Preset")
        end
    end

    AntiLag.StartWatch()
    for _, source in ipairs(CategorySources) do
        if source ~= "Preset" then
            if isSourceActive(source) then
                Tracker.Reset(source)
                Engine.Run(source)
            else
                Engine.Stop(source)
            end
        end
    end
end

local PV = HidePlayers.PlayerVisibilityManager
local Selector = HidePlayers.PlayerSelector
local PlayerCard = HidePlayers.PlayerCard
local Exclusion = HidePlayers.ExclusionManager
local AutoRefresh = HidePlayers.AutoRefresh

PV.Watchers = {}

local function hideSource(userId, channel)
    return "Hide_" .. channel .. "_" .. tostring(userId)
end

local function isAccessoryDescendant(instance, character)
    local p = instance
    while p and p ~= character do
        if p:IsA("Accessory") or p:IsA("Hat") then
            return true
        end
        p = p.Parent
    end
    return false
end

function PV.Process(instance, userId, character)
    if isProtectedGui(instance, true) then
        return
    end

    local className = instance.ClassName
    local particleProp = ParticleProps[className]
    local inAccessory = isAccessoryDescendant(instance, character)

    if State.Toggles.HidePlayerNames or State.HideEnabled then
        if className == "Humanoid" then
            Storage.Apply(instance, "DisplayDistanceType", Enum.HumanoidDisplayDistanceType.None, hideSource(userId, "Names"))
        elseif className == "BillboardGui" then
            Storage.Apply(instance, "Enabled", false, hideSource(userId, "Names"))
        end
    end

    if State.Toggles.HidePlayerAccessories and inAccessory then
        if isPart(instance) then
            Storage.Apply(instance, "LocalTransparencyModifier", 1, hideSource(userId, "Accessories"))
        elseif className == "Decal" or className == "Texture" then
            Storage.Apply(instance, "Transparency", 1, hideSource(userId, "Accessories"))
        end
    end

    if State.Toggles.HidePlayerEffects or State.HideEnabled then
        if className == "Highlight" or particleProp then
            Storage.Apply(instance, particleProp or "Enabled", false, hideSource(userId, "Effects"))
        end
    end

    if State.HideEnabled then
        if className == "Decal" or className == "Texture" then
            Storage.Apply(instance, "Transparency", 1, hideSource(userId, "Body"))
        elseif isPart(instance) then
            Storage.Apply(instance, "LocalTransparencyModifier", 1, hideSource(userId, "Body"))
        end
    end
end

function PV.ReleaseChannels(userId, channels)
    for _, ch in ipairs(channels) do
        Storage.EnqueueRelease(hideSource(userId, ch))
    end
end

function PV.Release(player)
    local userId = player.UserId
    local watcher = PV.Watchers[userId]
    if watcher then
        pcall(function()
            watcher.Connection:Disconnect()
        end)
        PV.Watchers[userId] = nil
    end
    PV.ReleaseChannels(userId, {"Body", "Names", "Accessories", "Effects"})
end

local function anyPlayerHideActive()
    return State.HideEnabled
        or State.Toggles.HidePlayerNames
        or State.Toggles.HidePlayerAccessories
        or State.Toggles.HidePlayerEffects
end

function PV.SyncPlayer(player)
    if player == LocalPlayer or not isAlive(player) then
        return
    end
    local userId = player.UserId

    if State.Excluded[userId] or not anyPlayerHideActive() then
        PV.Release(player)
        return
    end

    local inactive = {}
    if not State.HideEnabled then
        inactive[#inactive + 1] = "Body"
    end
    if not (State.Toggles.HidePlayerNames or State.HideEnabled) then
        inactive[#inactive + 1] = "Names"
    end
    if not State.Toggles.HidePlayerAccessories then
        inactive[#inactive + 1] = "Accessories"
    end
    if not (State.Toggles.HidePlayerEffects or State.HideEnabled) then
        inactive[#inactive + 1] = "Effects"
    end
    if #inactive > 0 then
        PV.ReleaseChannels(userId, inactive)
    end

    local character = player.Character
    if not character then
        return
    end

    local ok, descendants = pcall(character.GetDescendants, character)
    if ok then
        local sliceStart = os.clock()
        for idx, instance in ipairs(descendants) do
            pcall(PV.Process, instance, userId, character)
            if idx % 120 == 0 or (os.clock() - sliceStart) >= 0.0025 then
                yieldFrame()
                sliceStart = os.clock()
                if not Core.Running or State.Restoring or State.Excluded[userId] or not anyPlayerHideActive() then
                    return
                end
            end
        end
    end

    local watcher = PV.Watchers[userId]
    if watcher and watcher.Character ~= character then
        pcall(function()
            watcher.Connection:Disconnect()
        end)
        PV.Watchers[userId] = nil
        watcher = nil
    end

    if not watcher then
        PV.Watchers[userId] = {
            Character = character,
            Connection = character.DescendantAdded:Connect(function(instance)
                if Core.Running and not State.Restoring and not State.Excluded[userId] and anyPlayerHideActive() then
                    pcall(PV.Process, instance, userId, character)
                end
            end)
        }
    end
end

function PV.Apply(player)
    task.spawn(PV.SyncPlayer, player)
end

PV.ApplyGeneration = 0

function PV.ApplyAll()
    PV.ApplyGeneration = PV.ApplyGeneration + 1
    local gen = PV.ApplyGeneration
    local snapshot = Players:GetPlayers()
    task.spawn(function()
        for _, player in ipairs(snapshot) do
            if not Core.Running or PV.ApplyGeneration ~= gen then
                return
            end
            PV.SyncPlayer(player)
            yieldFrame()
        end
    end)
end

function PV.ReleaseWatchers()
    for userId, watcher in pairs(PV.Watchers) do
        pcall(function()
            watcher.Connection:Disconnect()
        end)
        PV.Watchers[userId] = nil
    end
end

function Exclusion.Toggle(userId)
    if State.Excluded[userId] then
        State.Excluded[userId] = nil
    else
        State.Excluded[userId] = true
    end
    local player = Players:GetPlayerByUserId(userId)
    if player then
        PV.Apply(player)
    end
    Selector.RefreshStatus()
end

AutoRefresh.PlayerConns = {}

function AutoRefresh.Track(player)
    if player == LocalPlayer or AutoRefresh.PlayerConns[player.UserId] then
        return
    end

    AutoRefresh.PlayerConns[player.UserId] = {
        player.CharacterAdded:Connect(function()
            refreshCharacterCache()
            task.defer(function()
                if Core.Running and player.Parent == Players then
                    PV.Apply(player)
                    Selector.RefreshStatus()
                end
            end)
        end),
        player.CharacterRemoving:Connect(function()
            PV.Release(player)
            task.defer(refreshCharacterCache)
        end)
    }
end

function AutoRefresh.Untrack(player)
    local conns = AutoRefresh.PlayerConns[player.UserId]
    if conns then
        disconnectList(conns)
        AutoRefresh.PlayerConns[player.UserId] = nil
    end
end

function AutoRefresh.Start()
    for _, player in ipairs(Players:GetPlayers()) do
        AutoRefresh.Track(player)
    end
    refreshCharacterCache()

    connect(LocalPlayer.CharacterAdded, function()
        refreshCharacterCache()
    end)

    connect(LocalPlayer.CharacterRemoving, function()
        task.defer(refreshCharacterCache)
    end)

    connect(Players.PlayerAdded, function(player)
        if not Core.Running then
            return
        end
        AutoRefresh.Track(player)
        refreshCharacterCache()
        PV.Apply(player)
        Selector.Refresh()
    end)

    connect(Players.PlayerRemoving, function(player)
        AutoRefresh.Untrack(player)
        PV.Release(player)
        State.Excluded[player.UserId] = nil
        task.defer(function()
            if Core.Running then
                refreshCharacterCache()
                Selector.Refresh()
            end
        end)
    end)
end

function AutoRefresh.StopAll()
    for userId, conns in pairs(AutoRefresh.PlayerConns) do
        disconnectList(conns)
        AutoRefresh.PlayerConns[userId] = nil
    end
end

function ServerManager.SetStatus(text, isError)
    ServerManager.StatusText = text
    if isError then
        warnMsg(text)
    end
end

local function create(className, properties, parent)
    local instance = Instance.new(className)
    instance.Name = generateName()
    for property, value in pairs(properties) do
        instance[property] = value
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

local function tween(instance, duration, properties)
    local object = TweenService:Create(
        instance,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    )
    object:Play()
    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 4)
    }, parent)
end

local function stroke(parent, color, enabled)
    return create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Enabled = enabled ~= false
    }, parent)
end

local function ensurePadding(parent, left, top, right, bottom)
    local existing = parent:FindFirstChildOfClass("UIPadding")
    if existing then
        existing.PaddingLeft = UDim.new(0, left or 5)
        existing.PaddingTop = UDim.new(0, top or 5)
        existing.PaddingRight = UDim.new(0, right or 0)
        existing.PaddingBottom = UDim.new(0, bottom or 0)
        return existing
    end
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 5),
        PaddingTop = UDim.new(0, top or 5),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0)
    }, parent)
end

local function listLayout(parent, gap)
    return create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, gap or 4)
    }, parent)
end

local function bindHover(button, idle, hover, press)
    button.MouseEnter:Connect(function()
        tween(button, 0.12, {BackgroundColor3 = hover})
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.12, {BackgroundColor3 = idle})
    end)
    button.MouseButton1Down:Connect(function()
        tween(button, 0.08, {BackgroundColor3 = press})
    end)
    button.MouseButton1Up:Connect(function()
        tween(button, 0.08, {BackgroundColor3 = hover})
    end)
end

local function makeLabel(parent, text, properties)
    local props = {
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = text,
        TextColor3 = Theme.PrimaryText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }
    for key, value in pairs(properties or {}) do
        props[key] = value
    end
    return create("TextLabel", props, parent)
end

local function makeSubTitle(parent, text, order)
    return makeLabel(parent, text, {
        Size = UDim2.new(1, 0, 0, 18),
        TextColor3 = Theme.MutedText,
        TextSize = 10,
        Font = Enum.Font.BuilderSansMedium,
        LayoutOrder = order
    })
end

local function makeButton(parent, text, order, style)
    local s = style or {}
    local idle = s.Idle or Theme.SecondarySurface
    local hover = s.Hover or Theme.Hover
    local press = s.Press or Theme.Press
    local textColor = s.Text or Theme.PrimaryText

    local button = create("TextButton", {
        Size = s.Size or UDim2.new(1, 0, 0, 30),
        Position = s.Position or UDim2.new(),
        BackgroundColor3 = idle,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.BuilderSansMedium,
        Text = s.Icon and "" or text,
        TextColor3 = textColor,
        TextSize = s.TextSize or 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = order or 0
    }, parent)
    corner(button, 4)
    stroke(button, s.Border or Theme.Border)
    bindHover(button, idle, hover, press)

    if s.Icon then
        create("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 8, 0.5, 0),
            Size = UDim2.fromOffset(13, 13),
            BackgroundTransparency = 1,
            Image = s.Icon,
            ImageColor3 = textColor
        }, button)

        local label = makeLabel(button, text, {
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -32, 1, 0),
            Font = Enum.Font.BuilderSansMedium,
            TextColor3 = textColor,
            TextSize = s.TextSize or 12,
            TextTruncate = Enum.TextTruncate.AtEnd
        })

        return button, label
    end

    return button
end

local function makeButtonRow(parent, order, leftText, leftStyle, rightText, rightStyle)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        LayoutOrder = order
    }, parent)

    local ls = leftStyle or {}
    ls.Size = UDim2.new(0.5, -3, 1, 0)
    ls.Position = UDim2.new(0, 0, 0, 0)

    local rs = rightStyle or {}
    rs.Size = UDim2.new(0.5, -3, 1, 0)
    rs.Position = UDim2.new(0.5, 3, 0, 0)

    local left = makeButton(row, leftText, 1, ls)
    local right = makeButton(row, rightText, 2, rs)
    return left, right, row
end

local function createToggle(parent, text, order, key, callback)
    local row = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.SecondarySurface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = order
    }, parent)
    corner(row, 4)
    bindHover(row, Theme.SecondarySurface, Theme.Hover, Theme.Press)

    makeLabel(row, text, {
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -52, 1, 0),
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local track = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(34, 18),
        BackgroundColor3 = Theme.ToggleOff,
        BorderSizePixel = 0
    }, row)
    corner(track, 9)

    local knob = create("Frame", {
        Position = UDim2.new(0, 2, 0.5, -7),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Theme.MutedText,
        BorderSizePixel = 0
    }, track)
    corner(knob, 7)

    local icon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        Image = Icon.ToggleOff,
        ImageColor3 = Theme.Background
    }, knob)

    local toggle = {Value = false, Frame = row}

    function toggle:Set(value, silent)
        self.Value = value and true or false
        if self.Value then
            icon.Image = Icon.ToggleOn
            icon.ImageColor3 = Theme.Active
            tween(track, 0.15, {BackgroundColor3 = Theme.ToggleOn})
            tween(knob, 0.15, {Position = UDim2.new(0, 18, 0.5, -7), BackgroundColor3 = Theme.Background})
        else
            icon.Image = Icon.ToggleOff
            icon.ImageColor3 = Theme.Background
            tween(track, 0.15, {BackgroundColor3 = Theme.ToggleOff})
            tween(knob, 0.15, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Theme.MutedText})
        end
        if not silent and callback then
            callback(self.Value)
        end
    end

    row.MouseButton1Click:Connect(function()
        toggle:Set(not toggle.Value)
    end)

    if key then
        GUI.Toggles[key] = toggle
    end
    return toggle
end

local function createCheckbox(parent, initialValue, onChanged)
    local box = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = ""
    }, parent)
    corner(box, 4)
    local boxStroke = stroke(box, Theme.Border)

    local checkIcon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Image = Icon.Checklist,
        ImageColor3 = Theme.Background,
        ImageTransparency = 1,
        Visible = false
    }, box)

    local cb = {Value = initialValue and true or false}

    function cb:Set(value, silent)
        self.Value = value and true or false
        if self.Value then
            checkIcon.Visible = true
            tween(box, 0.12, {BackgroundColor3 = Theme.Active})
            tween(boxStroke, 0.12, {Color = Theme.Active})
            tween(checkIcon, 0.12, {ImageTransparency = 0, Size = UDim2.fromOffset(12, 12)})
        else
            tween(box, 0.12, {BackgroundColor3 = Theme.Surface})
            tween(boxStroke, 0.12, {Color = Theme.Border})
            local t = tween(checkIcon, 0.1, {ImageTransparency = 1, Size = UDim2.fromOffset(8, 8)})
            t.Completed:Connect(function()
                if not self.Value and checkIcon.Parent then
                    checkIcon.Visible = false
                end
            end)
        end
        if not silent and onChanged then
            onChanged(self.Value)
        end
    end

    box.MouseButton1Click:Connect(function()
        cb:Set(not cb.Value)
    end)

    cb:Set(cb.Value, true)
    return cb, box
end

local function createDropdown(parent, labelText, order, options, initialValue, key, onSelect)
    local wrapper = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.SecondarySurface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = order
    }, parent)
    corner(wrapper, 4)
    stroke(wrapper, Theme.Border)
    listLayout(wrapper, 0)

    local headerBtn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.SecondarySurface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = 1
    }, wrapper)
    corner(headerBtn, 4)
    bindHover(headerBtn, Theme.SecondarySurface, Theme.Hover, Theme.Press)

    local titleLbl = makeLabel(headerBtn, labelText, {
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(0.50, -8, 1, 0),
        TextColor3 = Theme.MutedText,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local valueLbl = makeLabel(headerBtn, tostring(initialValue or options[1] or ""), {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -26, 0, 0),
        Size = UDim2.new(0.50, -30, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = Theme.PrimaryText,
        Font = Enum.Font.BuilderSansMedium,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local arrow = create("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Image = Icon.ArrowDown,
        ImageColor3 = Theme.PrimaryText
    }, headerBtn)

    local listClip = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = 2
    }, wrapper)

    local listInner = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, listClip)
    listLayout(listInner, 4)
    ensurePadding(listInner, 5, 5, 5, 5)

    local dd = {
        Value = initialValue or options[1],
        Expanded = false,
        OptionButtons = {},
        Title = titleLbl,
        Frame = wrapper
    }

    local function syncSelectionVisual()
        for optName, btn in pairs(dd.OptionButtons) do
            local active = optName == dd.Value
            btn.BackgroundColor3 = active and Theme.Hover or Theme.Surface
            btn.TextColor3 = active and Theme.Active or Theme.MutedText
        end
        valueLbl.Text = tostring(dd.Value)
    end

    for idx, optName in ipairs(options) do
        local optBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.BuilderSansMedium,
            Text = "  " .. tostring(optName),
            TextColor3 = Theme.MutedText,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = idx
        }, listInner)
        corner(optBtn, 3)
        stroke(optBtn, Theme.Border)
        optBtn.MouseEnter:Connect(function()
            if dd.Value ~= optName then
                tween(optBtn, 0.1, {BackgroundColor3 = Theme.Hover})
            end
        end)
        optBtn.MouseLeave:Connect(function()
            if dd.Value ~= optName then
                tween(optBtn, 0.1, {BackgroundColor3 = Theme.Surface})
            end
        end)
        optBtn.MouseButton1Click:Connect(function()
            dd:Set(optName)
            dd:SetExpanded(false)
        end)
        dd.OptionButtons[optName] = optBtn
    end

    function dd:SetExpanded(open)
        self.Expanded = open and true or false
        if self.Expanded then
            arrow.Image = Icon.ArrowUp
            local h = listInner.AbsoluteSize.Y
            if h <= 0 then
                h = (#options * 28) + 6
            end
            listClip.AutomaticSize = Enum.AutomaticSize.None
            local t = tween(listClip, 0.16, {Size = UDim2.new(1, 0, 0, h)})
            t.Completed:Connect(function()
                if self.Expanded and listClip.Parent then
                    listClip.AutomaticSize = Enum.AutomaticSize.Y
                    listClip.Size = UDim2.new(1, 0, 0, 0)
                end
            end)
        else
            arrow.Image = Icon.ArrowDown
            local currentH = listClip.AbsoluteSize.Y
            listClip.AutomaticSize = Enum.AutomaticSize.None
            listClip.Size = UDim2.new(1, 0, 0, currentH)
            tween(listClip, 0.16, {Size = UDim2.new(1, 0, 0, 0)})
        end
    end

    function dd:Set(val, silent)
        self.Value = val
        syncSelectionVisual()
        if not silent and onSelect then
            onSelect(val)
        end
    end

    headerBtn.MouseButton1Click:Connect(function()
        dd:SetExpanded(not dd.Expanded)
    end)

    syncSelectionVisual()
    if key then
        GUI.Dropdowns[key] = dd
    end
    return dd
end

local function createExpandableCard(parent, title, order, defaultExpanded, iconImage)
    local card = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = order
    }, parent)
    listLayout(card, 0)

    local header = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = 1
    }, card)
    bindHover(header, Theme.Background, Theme.Hover, Theme.Press)

    if iconImage then
        create("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 8, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            Image = iconImage,
            ImageColor3 = Theme.PrimaryText
        }, header)
    end

    local titleOffset = iconImage and 28 or 8
    local titleLabel = makeLabel(header, title, {
        Position = UDim2.fromOffset(titleOffset, 0),
        Size = UDim2.new(1, -(titleOffset + 26), 1, 0),
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 14,
        TextColor3 = Theme.PrimaryText,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local arrow = create("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        Image = Icon.ArrowDown,
        ImageColor3 = Theme.PrimaryText
    }, header)

    local clipFrame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = 2
    }, card)

    local inner = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, clipFrame)
    listLayout(inner, 6)
    ensurePadding(inner, 5, 5, 5, 5)

    local cardObj = {
        Card = card,
        Header = header,
        TitleLabel = titleLabel,
        Container = inner,
        Expanded = defaultExpanded and true or false
    }

    local function applyState(animate)
        if cardObj.Expanded then
            arrow.Image = Icon.ArrowUp
            if animate then
                local targetH = inner.AbsoluteSize.Y
                if targetH <= 0 then
                    clipFrame.AutomaticSize = Enum.AutomaticSize.Y
                    clipFrame.Size = UDim2.new(1, 0, 0, 0)
                    return
                end
                clipFrame.AutomaticSize = Enum.AutomaticSize.None
                local t = tween(clipFrame, 0.18, {Size = UDim2.new(1, 0, 0, targetH)})
                t.Completed:Connect(function()
                    if cardObj.Expanded and clipFrame.Parent then
                        clipFrame.AutomaticSize = Enum.AutomaticSize.Y
                        clipFrame.Size = UDim2.new(1, 0, 0, 0)
                    end
                end)
            else
                clipFrame.AutomaticSize = Enum.AutomaticSize.Y
                clipFrame.Size = UDim2.new(1, 0, 0, 0)
            end
        else
            arrow.Image = Icon.ArrowDown
            if animate then
                local currentH = clipFrame.AbsoluteSize.Y
                clipFrame.AutomaticSize = Enum.AutomaticSize.None
                clipFrame.Size = UDim2.new(1, 0, 0, currentH)
                tween(clipFrame, 0.18, {Size = UDim2.new(1, 0, 0, 0)})
            else
                clipFrame.AutomaticSize = Enum.AutomaticSize.None
                clipFrame.Size = UDim2.new(1, 0, 0, 0)
            end
        end
    end

    function cardObj:SetExpanded(value, animate)
        self.Expanded = value and true or false
        applyState(animate ~= false)
    end

    header.MouseButton1Click:Connect(function()
        cardObj:SetExpanded(not cardObj.Expanded, true)
    end)

    applyState(false)
    return cardObj
end

local function createScroller(parent)
    local holder = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1)
    }, parent)

    local scroll = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -15, 1, 0),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ClipsDescendants = true
    }, holder)

    local bar = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 15, 1, 0),
        BackgroundColor3 = Theme.ScrollTrack,
        BorderSizePixel = 0
    }, holder)

    local up = create("ImageButton", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(15, 15),
        BackgroundTransparency = 1,
        Image = Icon.ArrowUp,
        ImageColor3 = Theme.MutedText,
        AutoButtonColor = false
    }, bar)

    local down = create("ImageButton", {
        Position = UDim2.new(0, 0, 1, -15),
        Size = UDim2.fromOffset(15, 15),
        BackgroundTransparency = 1,
        Image = Icon.ArrowDown,
        ImageColor3 = Theme.MutedText,
        AutoButtonColor = false
    }, bar)

    local track = create("Frame", {
        Position = UDim2.fromOffset(0, 15),
        Size = UDim2.new(1, 0, 1, -30),
        BackgroundColor3 = Theme.ScrollTrack,
        BorderSizePixel = 0
    }, bar)

    local handle = create("Frame", {
        Size = UDim2.new(0, 15, 0, 55),
        BackgroundColor3 = Theme.ScrollHandle,
        BorderSizePixel = 0
    }, track)

    local function maxScroll()
        return math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
    end

    local function getHandleHeight(trackHeight)
        if trackHeight <= 0 then
            return 0
        end
        return math.min(55, trackHeight)
    end

    local function update()
        local trackHeight = track.AbsoluteSize.Y
        local limit = maxScroll()
        local handleHeight = getHandleHeight(trackHeight)
        handle.Size = UDim2.new(0, 15, 0, handleHeight)
        handle.Visible = limit > 0 and trackHeight > 0
        local ratio = 0
        if limit > 0 then
            ratio = math.clamp(scroll.CanvasPosition.Y / limit, 0, 1)
        end
        handle.Position = UDim2.fromOffset(0, math.floor((trackHeight - handleHeight) * ratio))
    end

    scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(update)
    scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(update)
    scroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(update)
    track:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)

    local holdDirection = 0
    local holdConnection = nil
    local dragging = false
    local dragStartY = 0
    local dragStartHandle = 0

    local function scrollBy(amount)
        scroll.CanvasPosition = Vector2.new(0, math.clamp(scroll.CanvasPosition.Y + amount, 0, maxScroll()))
    end

    local function stopHold()
        holdDirection = 0
        if holdConnection then
            holdConnection:Disconnect()
            holdConnection = nil
        end
    end

    local function startHold(direction)
        stopHold()
        holdDirection = direction
        scrollBy(direction * 24)
        holdConnection = RunService.Heartbeat:Connect(function(dt)
            if not Core.Running then
                stopHold()
                return
            end
            if holdDirection ~= 0 then
                scrollBy(holdDirection * 520 * dt)
            end
        end)
    end

    local function isPress(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
    end

    up.InputBegan:Connect(function(input)
        if isPress(input) then
            startHold(-1)
        end
    end)

    down.InputBegan:Connect(function(input)
        if isPress(input) then
            startHold(1)
        end
    end)

    handle.InputBegan:Connect(function(input)
        if isPress(input) then
            dragging = true
            dragStartY = input.Position.Y
            dragStartHandle = handle.Position.Y.Offset
        end
    end)

    track.InputBegan:Connect(function(input)
        if not isPress(input) then
            return
        end
        local y = input.Position.Y
        local top = handle.AbsolutePosition.Y
        local handleHeight = getHandleHeight(track.AbsoluteSize.Y)
        if y >= top and y <= top + handleHeight then
            return
        end
        local span = track.AbsoluteSize.Y - handleHeight
        if span > 0 then
            local target = math.clamp(y - track.AbsolutePosition.Y - handleHeight / 2, 0, span)
            scroll.CanvasPosition = Vector2.new(0, target / span * maxScroll())
            dragging = true
            dragStartY = y
            dragStartHandle = target
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local handleHeight = getHandleHeight(track.AbsoluteSize.Y)
            local span = track.AbsoluteSize.Y - handleHeight
            if span > 0 then
                local target = math.clamp(dragStartHandle + (input.Position.Y - dragStartY), 0, span)
                scroll.CanvasPosition = Vector2.new(0, target / span * maxScroll())
            end
        end
    end)

    connect(UserInputService.InputEnded, function(input)
        if isPress(input) then
            dragging = false
            stopHold()
        end
    end)

    holder.Destroying:Connect(stopHold)
    update()
    return holder, scroll
end

local viewport = Vector2.new(800, 600)
pcall(function()
    local camera = Workspace.CurrentCamera
    if camera then
        viewport = camera.ViewportSize
    end
end)

GUI.Screen = create("ScreenGui", {
    ResetOnSpawn = false,
    IgnoreGuiInset = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999
})

do
    local supportsIgnoreInsert = pcall(function()
        return GUI.Screen.IgnoreInsert
    end)
    if supportsIgnoreInsert then
        pcall(function()
            GUI.Screen.IgnoreInsert = true
        end)
    end
end

pcall(function()
    local protect = executorEnv.protect_gui or (executorEnv.syn and executorEnv.syn.protect_gui)
    if type(protect) == "function" then
        protect(GUI.Screen)
    end
end)

local parented = pcall(function()
    GUI.Screen.Parent = host
end)
if not parented then
    pcall(function()
        GUI.Screen.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end)
end

local screenSize = GUI.Screen.AbsoluteSize
if screenSize.X < 100 or screenSize.Y < 100 then
    screenSize = viewport
end

local initialWidth = 270
local initialHeight = 320

GUI.Main = create("Frame", {
    AnchorPoint = Vector2.new(0, 0),
    Position = UDim2.fromOffset(
        math.max(0, math.floor(screenSize.X / 2 - initialWidth / 2)),
        math.max(0, math.floor(screenSize.Y / 2 - initialHeight / 2))
    ),
    Size = UDim2.fromOffset(initialWidth, initialHeight),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, GUI.Screen)

do
    local shadowProps = {
        Name = generateName(),
        ZIndex = -1,
        BlurRadius = UDim.new(0, 14),
        Color = Color3.fromRGB(0, 0, 0),
        Enabled = true,
        Offset = UDim2.fromOffset(0, 4),
        Spread = UDim2.fromScale(0, 0),
        Transparency = 0.45
    }
    local okShadow, shadow = pcall(function()
        return Instance.new("UIShadow")
    end)
    if okShadow and shadow then
        for property, value in pairs(shadowProps) do
            pcall(function()
                shadow[property] = value
            end)
        end
        pcall(function()
            shadow.Parent = GUI.Main
        end)
    end
end

GUI.Header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = Theme.Header,
    BorderSizePixel = 0,
    ZIndex = 2
}, GUI.Main)

create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.fromScale(0, 1),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Theme.HeaderDivider,
    BorderSizePixel = 0,
    ZIndex = 2
}, GUI.Header)

create("ImageLabel", {
    Position = UDim2.fromOffset(8, 7),
    Size = UDim2.fromOffset(16, 16),
    BackgroundTransparency = 1,
    Image = Icon.Logo,
    ImageColor3 = Theme.Active,
    ZIndex = 3
}, GUI.Header)

makeLabel(GUI.Header, "Performance Manager", {
    Position = UDim2.fromOffset(30, 0),
    Size = UDim2.new(1, -86, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.BuilderSansMedium,
    TextSize = 14,
    TextColor3 = Theme.PrimaryText,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 3
})

local function headerButton(offsetX, image)
    local button = create("ImageButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, offsetX, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 3
    }, GUI.Header)
    corner(button, 4)
    local icon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Image = image,
        ImageColor3 = Theme.PrimaryText,
        ZIndex = 4
    }, button)
    bindHover(button, Theme.Header, Theme.BtnRestoreHover, Theme.BtnRestorePress)
    return button, icon
end

GUI.CloseButton = headerButton(-5, Icon.Close)
GUI.MinimizeButton, GUI.MinimizeIcon = headerButton(-29, Icon.Minimal)

GUI.Content = create("Frame", {
    Position = UDim2.fromOffset(0, 30),
    Size = UDim2.new(1, 0, 1, -30),
    BackgroundTransparency = 1,
    BorderSizePixel = 0
}, GUI.Main)

local _, MainScroll = createScroller(GUI.Content)
ensurePadding(MainScroll, 5, 5, 5, 5)
listLayout(MainScroll, 6)
GUI.MainScroll = MainScroll

GUI.Cards.Server = createExpandableCard(MainScroll, "Server", 1, true, Icon.Server)
GUI.Cards.AntiLag = createExpandableCard(MainScroll, "Anti lag", 2, true, Icon.AntiLag)
GUI.Cards.HidePlayer = createExpandableCard(MainScroll, "Hide Player", 3, true, Icon.HidePlayer)

do
    local container = GUI.Cards.AntiLag.Container

    makeSubTitle(container, "Graphics Presets", 1)

    createDropdown(
        container,
        "Graphics Preset",
        2,
        {"Default", "Balanced", "Performance", "Ultra Performance", "Custom"},
        "Default",
        "GraphicsPreset",
        function(preset)
            AntiLag.VisualManager.ApplyPreset(preset)
        end
    )

    makeSubTitle(container, "Visual Manager", 3)

    createToggle(container, "Enable Anti Lag", 4, "AntiLag", function(val)
        AntiLag.SetMaster(val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(container, "Reduce Visual Effects", 5, "Particle", function(val)
        AntiLag.SetCategory("Particle", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createDropdown(
        container,
        "Particle Visibility",
        6,
        {"Full", "Reduced", "Hidden"},
        "Full",
        "ParticleVisibility",
        function(val)
            State.Options.ParticleVisibility = val
            AntiLag.RenderingManager.RefreshSource("ParticleDensity")
            AntiLag.VisualManager.MarkCustom()
        end
    )

    createToggle(container, "Shadow Settings", 7, "Shadow", function(val)
        AntiLag.SetCategory("Shadow", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(container, "Lighting Settings", 8, "Lighting", function(val)
        AntiLag.SetCategory("Lighting", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(container, "Light Sources", 9, "Light", function(val)
        AntiLag.SetCategory("Light", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(container, "Character Effects", 10, "Character", function(val)
        AntiLag.SetCategory("Character", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(container, "Weather Effects", 11, "Weather", function(val)
        AntiLag.SetCategory("Weather", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(container, "Environmental Effects", 12, "Environment", function(val)
        AntiLag.SetCategory("Environment", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(container, "Texture Effects", 13, "Texture", function(val)
        AntiLag.SetCategory("Texture", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(container, "Low Graphics", 14, "LowGraphics", function(val)
        AntiLag.SetCategory("LowGraphics", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    makeSubTitle(container, "Rendering Manager", 20)

    local renderList = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 21
    }, container)
    listLayout(renderList, 6)
    ensurePadding(renderList, 5, 5, 5, 5)

    createToggle(renderList, "SpecialMesh Optimization", 1, "MeshSpecial", function(val)
        AntiLag.RenderingManager.SetToggle("MeshSpecial", "MeshControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(renderList, "MeshPart Performance LOD", 2, "MeshPart", function(val)
        AntiLag.RenderingManager.SetToggle("MeshPart", "MeshControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(renderList, "Hide Decorative Meshes", 3, "MeshVisibility", function(val)
        AntiLag.RenderingManager.SetToggle("MeshVisibility", "MeshControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createDropdown(
        renderList,
        "Texture Quality",
        4,
        {"Default", "Reduced", "Minimal"},
        "Default",
        "TextureQuality",
        function(val)
            State.Options.TextureQuality = val
            AntiLag.RenderingManager.RefreshSource("TextureQuality")
            AntiLag.VisualManager.MarkCustom()
        end
    )

    createToggle(renderList, "Texture & SurfaceAppearance", 5, "TextureMap", function(val)
        AntiLag.RenderingManager.SetToggle("TextureMap", "TextureQuality", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(renderList, "MaterialVariant Strip", 6, "MaterialVariant", function(val)
        AntiLag.RenderingManager.SetToggle("MaterialVariant", "TextureQuality", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(renderList, "Hide Decals", 7, "DecalVisibility", function(val)
        AntiLag.RenderingManager.SetToggle("DecalVisibility", "DecalVisibility", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createDropdown(
        renderList,
        "Particle Density",
        8,
        {"100%", "50%", "25%", "0%"},
        "100%",
        "ParticleDensity",
        function(val)
            State.Options.ParticleDensity = val
            AntiLag.RenderingManager.RefreshSource("ParticleDensity")
            AntiLag.VisualManager.MarkCustom()
        end
    )

    createDropdown(
        renderList,
        "Transparency Control",
        9,
        {"Default", "Simplify", "Hide"},
        "Default",
        "TransparencyMode",
        function(val)
            State.Options.TransparencyMode = val
            AntiLag.RenderingManager.RefreshSource("TransparencyControl")
            AntiLag.VisualManager.MarkCustom()
        end
    )

    createToggle(renderList, "Disable Local Effects", 10, "LocalEffects", function(val)
        AntiLag.RenderingManager.SetToggle("LocalEffects", "LocalEffects", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(renderList, "Terrain Decoration Off", 11, "TerrainDecoration", function(val)
        AntiLag.RenderingManager.SetToggle("TerrainDecoration", "TerrainDecoration", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(renderList, "Terrain Water Effects Off", 12, "TerrainWater", function(val)
        AntiLag.RenderingManager.SetToggle("TerrainWater", "TerrainWater", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(renderList, "Terrain Grass Decoration Off", 13, "TerrainGrass", function(val)
        AntiLag.RenderingManager.SetToggle("TerrainGrass", "TerrainGrass", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(renderList, "Clouds Off", 14, "CloudsControl", function(val)
        AntiLag.RenderingManager.SetToggle("CloudsControl", "CloudsControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(renderList, "Reflectance Off", 15, "ReflectanceControl", function(val)
        AntiLag.RenderingManager.SetToggle("ReflectanceControl", "ReflectanceControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createToggle(renderList, "CastShadow Off", 16, "CastShadowControl", function(val)
        AntiLag.RenderingManager.SetToggle("CastShadowControl", "CastShadowControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    makeSubTitle(container, "Optimization", 30)

    GUI.RestoreButton = makeButton(container, "Restore Default", 31, {
        Idle = Theme.BtnRestore,
        Hover = Theme.BtnRestoreHover,
        Press = Theme.BtnRestorePress,
        Text = Theme.BtnRestoreText
    })
end

local ThumbnailCache = {}

local function loadPlayerThumbnail(imageLabel, fallbackLabel, userId)
    fallbackLabel.Visible = true
    imageLabel.Image = ""

    local cached = ThumbnailCache[userId]
    if cached then
        imageLabel.Image = cached
        fallbackLabel.Visible = false
        return
    end

    task.spawn(function()
        local ok, content, isReady = pcall(function()
            return Players:GetUserThumbnailAsync(
                userId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)
        if not Core.Running or not imageLabel.Parent then
            return
        end
        if ok and isReady and type(content) == "string" and content ~= "" then
            ThumbnailCache[userId] = content
            imageLabel.Image = content
            fallbackLabel.Visible = false
        else

            local rbxThumb = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=60&h=60"
            imageLabel.Image = rbxThumb

            fallbackLabel.Visible = false
        end
    end)
end

local function createCircularThumbnail(parent, userId, displayName, pos)
    local holder = create("Frame", {
        Position = pos or UDim2.fromOffset(8, 12),
        Size = UDim2.fromOffset(38, 38),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0
    }, parent)
    corner(holder, 19)
    local cr = holder:FindFirstChildOfClass("UICorner")
    if cr then
        cr.CornerRadius = UDim.new(1, 0)
    end
    stroke(holder, Theme.Border)

    local initials = string.upper(string.sub(displayName or "?", 1, 2))
    local fallback = makeLabel(holder, initials, {
        Size = UDim2.fromScale(1, 1),
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 12,
        TextColor3 = Theme.MutedText,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1
    })

    local thumb = create("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = "",
        ZIndex = 2
    }, holder)
    local thumbCorner = create("UICorner", {CornerRadius = UDim.new(1, 0)}, thumb)
    thumbCorner.CornerRadius = UDim.new(1, 0)

    loadPlayerThumbnail(thumb, fallback, userId)
    return holder
end

do
    local container = GUI.Cards.Server.Container

    local serverRow = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 1
    }, container)

    local leftCol = create("Frame", {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.38, -3, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, serverRow)
    listLayout(leftCol, 4)

    local placeThumb = create("ImageLabel", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ScaleType = Enum.ScaleType.Crop,
        Image = "rbxthumb://type=Asset&id=" .. tostring(game.PlaceId) .. "&w=420&h=420",
        LayoutOrder = 1
    }, leftCol)
    corner(placeThumb, 5)

    local placeNameLabel = makeLabel(leftCol, "Place", {
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 12,
        TextColor3 = Theme.PrimaryText,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        LayoutOrder = 2
    })

    local rightCol = create("Frame", {
        Position = UDim2.new(0.38, 3, 0, 0),
        Size = UDim2.new(0.62, -3, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, serverRow)
    listLayout(rightCol, 4)

    local rejoinButton, rejoinLabel = makeButton(rightCol, "Rejoin", 1, {
        Idle = Theme.BtnRejoin,
        Hover = Theme.BtnRejoinHover,
        Press = Theme.BtnRejoinPress,
        Text = Theme.BtnRejoinText,
        Icon = Icon.Rejoin
    })

    local hopButton, hopLabel = makeButton(rightCol, "Server Hop", 2, {
        Idle = Theme.BtnServerHop,
        Hover = Theme.BtnServerHopHover,
        Press = Theme.BtnServerHopPress,
        Text = Theme.BtnServerHopText,
        Icon = Icon.ServerHop
    })

    local smallButton, smallLabel = makeButton(rightCol, "Small Server", 3, {
        Idle = Theme.BtnSmallServer,
        Hover = Theme.BtnSmallServerHover,
        Press = Theme.BtnSmallServerPress,
        Text = Theme.BtnSmallServerText,
        Icon = Icon.SmallServer
    })

    local function syncThumbHeight()
        local h = rightCol.AbsoluteSize.Y
        if h > 0 then
            placeThumb.Size = UDim2.new(1, 0, 0, math.max(36, h - 34))
        end
    end
    rightCol:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncThumbHeight)
    syncThumbHeight()

    task.spawn(function()
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)
        if not Core.Running or not placeNameLabel.Parent then
            return
        end
        if ok and type(info) == "table" and type(info.Name) == "string" and info.Name ~= "" then
            placeNameLabel.Text = info.Name
        else
            placeNameLabel.Text = "Place"
            warnMsg(ok and "Failed to load place name" or info)
        end
    end)

    local function bindConfirm(button, label, baseText, action)
        local token = 0
        local armed = false
        button.MouseButton1Click:Connect(function()
            if not armed then
                armed = true
                token = token + 1
                local current = token
                label.Text = "Confirm " .. baseText .. "?"
                task.delay(3, function()
                    if Core.Running and armed and token == current and button.Parent then
                        armed = false
                        label.Text = baseText
                    end
                end)
            else
                armed = false
                token = token + 1
                label.Text = baseText
                action()
            end
        end)
    end

    local function httpGet(url)
        local requestFunction = executorEnv.request
            or executorEnv.http_request
            or (executorEnv.syn and executorEnv.syn.request)
            or (executorEnv.http and executorEnv.http.request)

        if type(requestFunction) == "function" then
            local ok, response = pcall(requestFunction, {Url = url, Method = "GET"})
            if ok and type(response) == "table" and type(response.Body) == "string" then
                if response.StatusCode == nil or response.StatusCode == 200 then
                    return response.Body
                end
            end
        end

        local okGet, body = pcall(function()
            return game:HttpGet(url)
        end)
        if okGet and type(body) == "string" then
            return body
        end
        return nil
    end

    local function fetchServers(order, cursor)
        local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId)
            .. "/servers/Public?sortOrder=" .. order .. "&excludeFullGames=true&limit=100"
        if cursor then
            url = url .. "&cursor=" .. cursor
        end
        local body = httpGet(url)
        if not body then
            return nil
        end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(body)
        end)
        if ok and type(data) == "table" and type(data.data) == "table" then
            return data
        end
        return nil
    end

    local function findServer(order, pages, pickSmallest)
        local candidates = {}
        local cursor = nil
        for _ = 1, pages do
            local data = fetchServers(order, cursor)
            if not data then
                break
            end
            for _, server in ipairs(data.data) do
                if type(server) == "table"
                    and server.id ~= game.JobId
                    and type(server.playing) == "number"
                    and type(server.maxPlayers) == "number"
                    and server.playing < server.maxPlayers then
                    candidates[#candidates + 1] = server
                end
            end
            cursor = data.nextPageCursor
            if not cursor then
                break
            end
        end

        if #candidates == 0 then
            return nil
        end

        if pickSmallest then
            table.sort(candidates, function(a, b)
                return a.playing < b.playing
            end)
            return candidates[1]
        end
        return candidates[math.random(1, #candidates)]
    end

    local function teleportToServer(serverId)
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
        end)
        if not ok then
            ServerManager.SetStatus("Teleport failed", true)
        end
    end

    local function runServerAction(statusMsg, order, pages, pickSmallest)
        if ServerManager.Busy then
            return
        end
        ServerManager.Busy = true
        ServerManager.SetStatus(statusMsg, false)
        task.spawn(function()
            local server = findServer(order, pages, pickSmallest)
            ServerManager.Busy = false
            if not Core.Running then
                return
            end
            if not server then
                ServerManager.SetStatus("Teleport failed", true)
                return
            end
            ServerManager.SetStatus("Teleporting...", false)
            teleportToServer(server.id)
        end)
    end

    bindConfirm(rejoinButton, rejoinLabel, "Rejoin", function()
        ServerManager.SetStatus("Rejoining...", false)
        local ok = pcall(function()
            if #Players:GetPlayers() <= 1 then
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end)
        if not ok then
            ServerManager.SetStatus("Teleport failed", true)
        end
    end)

    bindConfirm(hopButton, hopLabel, "Server Hop", function()
        runServerAction("Searching server...", "Desc", 3, false)
    end)

    bindConfirm(smallButton, smallLabel, "Small Server", function()
        runServerAction("Finding small server...", "Asc", 2, true)
    end)

    pcall(function()
        connect(TeleportService.TeleportInitFailed, function()
            ServerManager.Busy = false
            ServerManager.SetStatus("Teleport failed", true)
        end)
    end)
end

do
    local container = GUI.Cards.HidePlayer.Container

    createToggle(container, "Hide Other Players Locally", 1, "HidePlayers", function(value)
        State.HideEnabled = value
        State.Toggles.HidePlayers = value
        PV.ApplyAll()
        Selector.RefreshStatus()
    end)

    createToggle(container, "Hide Player Names", 2, "HidePlayerNames", function(value)
        State.Toggles.HidePlayerNames = value
        PV.ApplyAll()
        Selector.RefreshStatus()
    end)

    createToggle(container, "Hide Player Accessories", 3, "HidePlayerAccessories", function(value)
        State.Toggles.HidePlayerAccessories = value
        PV.ApplyAll()
        Selector.RefreshStatus()
    end)

    createToggle(container, "Hide Player Effects", 4, "HidePlayerEffects", function(value)
        State.Toggles.HidePlayerEffects = value
        PV.ApplyAll()
        Selector.RefreshStatus()
    end)

    GUI.RefreshButton, GUI.ShowAllButton = makeButtonRow(
        container,
        5,
        "Refresh Players",
        nil,
        "Show All Players",
        nil
    )

    GUI.ExcludeSummary = makeLabel(container, "Excluded players: 0", {
        Size = UDim2.new(1, 0, 0, 16),
        TextSize = 10,
        TextColor3 = Theme.MutedText,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = 6
    })

    local searchHolder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Theme.SecondarySurface,
        BorderSizePixel = 0,
        LayoutOrder = 7
    }, container)
    corner(searchHolder, 4)
    local searchStroke = stroke(searchHolder, Theme.Border, true)

    create("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Image = Icon.Search,
        ImageColor3 = Theme.MutedText
    }, searchHolder)

    GUI.PlayerSearch = create("TextBox", {
        Position = UDim2.fromOffset(26, 0),
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = Enum.Font.BuilderSans,
        PlaceholderText = "Search player...",
        PlaceholderColor3 = Theme.MutedText,
        Text = "",
        TextColor3 = Theme.PrimaryText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true
    }, searchHolder)

    local clearBtn = create("ImageButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        Image = Icon.Clear,
        ImageColor3 = Theme.MutedText,
        Visible = false,
        AutoButtonColor = false
    }, searchHolder)

    GUI.PlayerSearch.Focused:Connect(function()
        searchStroke.Color = Theme.Active
    end)

    GUI.PlayerSearch.FocusLost:Connect(function()
        searchStroke.Color = Theme.Border
    end)

    clearBtn.MouseButton1Click:Connect(function()
        GUI.PlayerSearch.Text = ""
    end)

    GUI.ExcludeClearBtn = clearBtn

    local playerListScroll = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 214),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ClipsDescendants = true,
        LayoutOrder = 8
    }, container)
    ensurePadding(playerListScroll, 5, 5, 5, 5)
    listLayout(playerListScroll, 6)
    GUI.PlayerList = playerListScroll
end

Selector.Cards = {}

local function getVisibilityStatusText(userId)
    if State.Excluded[userId] then
        return "Visibility: Visible (Excluded)", "Excluded: Yes"
    elseif State.HideEnabled then
        return "Visibility: Hidden", "Excluded: No"
    elseif State.Toggles.HidePlayerNames or State.Toggles.HidePlayerAccessories or State.Toggles.HidePlayerEffects then
        return "Visibility: Partial Hide", "Excluded: No"
    else
        return "Visibility: Visible", "Excluded: No"
    end
end

function Selector.UpdateCount()
    local total = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and State.Excluded[player.UserId] then
            total = total + 1
        end
    end
    if GUI.ExcludeSummary and GUI.ExcludeSummary.Parent then
        GUI.ExcludeSummary.Text = "Excluded players: " .. tostring(total)
    end
end

function Selector.RefreshStatus()
    for _, card in pairs(Selector.Cards) do
        card.Update()
    end
    Selector.UpdateCount()
end

function Selector.ApplyFilter()
    local query = string.lower(GUI.PlayerSearch and GUI.PlayerSearch.Text or "")
    if GUI.ExcludeClearBtn then
        GUI.ExcludeClearBtn.Visible = query ~= ""
    end
    for _, card in pairs(Selector.Cards) do
        local visible = query == ""
            or string.find(card.Display, query, 1, true) ~= nil
            or string.find(card.Username, query, 1, true) ~= nil
        card.Frame.Visible = visible
    end
end

GUI.PlayerSearch:GetPropertyChangedSignal("Text"):Connect(Selector.ApplyFilter)

function PlayerCard.CreateCard(player, order)
    local userId = player.UserId

    local card = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = Theme.SecondarySurface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = order
    }, GUI.PlayerList)
    corner(card, 4)
    stroke(card, Theme.Border)
    bindHover(card, Theme.SecondarySurface, Theme.Hover, Theme.Press)

    createCircularThumbnail(card, userId, player.DisplayName, UDim2.fromOffset(8, 13))

    local function line(y, text, font, color, size)
        return makeLabel(card, text, {
            Position = UDim2.fromOffset(54, y),
            Size = UDim2.new(1, -86, 0, 13),
            Font = font,
            TextColor3 = color,
            TextSize = size,
            TextTruncate = Enum.TextTruncate.AtEnd
        })
    end

    line(5, player.DisplayName, Enum.Font.BuilderSansMedium, Theme.PrimaryText, 12)
    line(19, "@" .. player.Name .. " • ID: " .. tostring(userId), Enum.Font.BuilderSans, Theme.MutedText, 10)
    local visLbl = line(33, "Visibility: Visible", Enum.Font.BuilderSans, Theme.PrimaryText, 10)

    local excLbl = makeLabel(card, "Excluded: No", {
        Position = UDim2.fromOffset(54, 46),
        Size = UDim2.new(1, -86, 0, 13),
        Font = Enum.Font.BuilderSans,
        TextColor3 = Theme.MutedText,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local checkbox = createCheckbox(card, State.Excluded[userId] == true, function()
        Exclusion.Toggle(userId)
    end)

    local object = {
        Frame = card,
        Display = string.lower(player.DisplayName),
        Username = string.lower(player.Name)
    }

    function object.Update()
        local excluded = State.Excluded[userId] == true
        checkbox:Set(excluded, true)
        local visText, excText = getVisibilityStatusText(userId)
        visLbl.Text = visText
        excLbl.Text = excText
        local statusColor = excluded and Theme.Active or Theme.MutedText
        excLbl.TextColor3 = statusColor
    end

    card.MouseButton1Click:Connect(function()
        Exclusion.Toggle(userId)
    end)

    object.Update()
    return object
end

function Selector.Refresh()
    if GUI.PlayerList and GUI.PlayerList.Parent then
        for _, child in ipairs(GUI.PlayerList:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end
    end

    Selector.Cards = {}

    local others = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            others[#others + 1] = player
        end
    end
    table.sort(others, function(a, b)
        return string.lower(a.DisplayName) < string.lower(b.DisplayName)
    end)

    for index, player in ipairs(others) do
        if GUI.PlayerList and GUI.PlayerList.Parent then
            Selector.Cards[player.UserId] = PlayerCard.CreateCard(player, index)
        end
    end

    if #others == 0 then
        if GUI.PlayerList and GUI.PlayerList.Parent then
            makeLabel(GUI.PlayerList, "No other players in server", {
                Size = UDim2.new(1, 0, 0, 22),
                TextColor3 = Theme.MutedText,
                TextSize = 10
            })
        end
    end

    Selector.ApplyFilter()
    Selector.UpdateCount()
end

GUI.RefreshButton.MouseButton1Click:Connect(function()
    Selector.Refresh()
    PV.ApplyAll()
end)

GUI.ShowAllButton.MouseButton1Click:Connect(function()
    State.HideEnabled = false
    State.Toggles.HidePlayers = false
    State.Toggles.HidePlayerNames = false
    State.Toggles.HidePlayerAccessories = false
    State.Toggles.HidePlayerEffects = false

    for _, k in ipairs({"HidePlayers", "HidePlayerNames", "HidePlayerAccessories", "HidePlayerEffects"}) do
        if GUI.Toggles[k] then
            GUI.Toggles[k]:Set(false, true)
        end
    end

    PV.ApplyAll()
    Selector.RefreshStatus()
end)

local Layout = {
    Minimized = false,
    LastHeight = initialHeight
}

local MinSize = Vector2.new(240, 120)

local function currentBounds()
    local size = GUI.Screen.AbsoluteSize
    if size.X < 100 or size.Y < 100 then
        local okCam, cam = pcall(function()
            return Workspace.CurrentCamera
        end)
        if okCam and cam then
            size = cam.ViewportSize
        else
            size = viewport
        end
    end
    return size
end

GUI.ResizeOverlay = create("Frame", {
    AnchorPoint = Vector2.new(0, 0),
    Position = GUI.Main.Position,
    Size = GUI.Main.Size,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = false,
    ZIndex = 100
}, GUI.Screen)

local function syncResizeOverlay()
    if not GUI.ResizeOverlay or not GUI.Main then
        return
    end
    GUI.ResizeOverlay.Position = GUI.Main.Position
    GUI.ResizeOverlay.Size = GUI.Main.Size
    GUI.ResizeOverlay.Visible = not Layout.Minimized
end

GUI.Main:GetPropertyChangedSignal("Position"):Connect(syncResizeOverlay)
GUI.Main:GetPropertyChangedSignal("Size"):Connect(syncResizeOverlay)

local Pointer = {
    Mode = nil,
    Edge = nil,
    Handle = nil,
    ActiveInput = nil,
    Start = Vector3.new(),
    StartPosition = UDim2.new(),
    StartSize = Vector2.new()
}

local function isPointerPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function beginPointer(mode, input, edge, handle)
    Pointer.Mode = mode
    Pointer.Edge = edge
    Pointer.Handle = handle
    Pointer.ActiveInput = input
    Pointer.Start = input.Position
    Pointer.StartPosition = GUI.Main.Position
    Pointer.StartSize = Vector2.new(GUI.Main.Size.X.Offset, GUI.Main.Size.Y.Offset)
    if handle then
        tween(handle, 0.08, {BackgroundTransparency = 0.2})
    end
end

local function endPointer()
    if Pointer.Handle and Pointer.Handle.Parent then
        tween(Pointer.Handle, 0.12, {BackgroundTransparency = 1})
    end
    Pointer.Mode = nil
    Pointer.Edge = nil
    Pointer.Handle = nil
    Pointer.ActiveInput = nil
end

local function setMinimized(value)
    if value == Layout.Minimized then
        return
    end
    Layout.Minimized = value
    if Pointer.Mode == "Resize" then
        endPointer()
    end

    if value then
        Layout.LastHeight = GUI.Main.Size.Y.Offset
        GUI.Content.Visible = false
        GUI.ResizeOverlay.Visible = false
        for _, handle in pairs(GUI.Resize) do
            handle.Active = false
            handle.Visible = false
            handle.BackgroundTransparency = 1
        end
        GUI.MinimizeIcon.Image = Icon.Maximize
        tween(GUI.Main, 0.18, {Size = UDim2.fromOffset(GUI.Main.Size.X.Offset, 30)})
    else
        GUI.Content.Visible = true
        for _, handle in pairs(GUI.Resize) do
            handle.Visible = true
            handle.Active = true
            handle.BackgroundTransparency = 1
        end
        GUI.MinimizeIcon.Image = Icon.Minimal
        local bounds = currentBounds()
        local targetHeight = math.clamp(Layout.LastHeight, MinSize.Y, math.max(MinSize.Y, bounds.Y))
        local clampedY = math.clamp(GUI.Main.Position.Y.Offset, 0, math.max(0, bounds.Y - targetHeight))
        local t = tween(GUI.Main, 0.18, {
            Size = UDim2.fromOffset(GUI.Main.Size.X.Offset, targetHeight),
            Position = UDim2.fromOffset(GUI.Main.Position.X.Offset, clampedY)
        })
        t.Completed:Connect(function()
            if not Layout.Minimized then
                syncResizeOverlay()
            end
        end)
    end
end

GUI.MinimizeButton.MouseButton1Click:Connect(function()
    setMinimized(not Layout.Minimized)
end)

GUI.Header.InputBegan:Connect(function(input)
    if isPointerPress(input) then
        beginPointer("Drag", input)
    end
end)

connect(UserInputService.InputChanged, function(input)
    if not Pointer.Mode then
        return
    end
    if input.UserInputType == Enum.UserInputType.Touch and Pointer.ActiveInput and input ~= Pointer.ActiveInput then
        return
    end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - Pointer.Start
    local bounds = currentBounds()
    local startX = Pointer.StartPosition.X.Offset
    local startY = Pointer.StartPosition.Y.Offset

    if Pointer.Mode == "Drag" then
        local width = GUI.Main.Size.X.Offset
        local height = GUI.Main.Size.Y.Offset
        local maxX = math.max(0, bounds.X - width)
        local maxY = math.max(0, bounds.Y - height)
        local x = math.clamp(startX + delta.X, 0, maxX)
        local y = math.clamp(startY + delta.Y, 0, maxY)
        GUI.Main.Position = UDim2.fromOffset(x, y)
        return
    end

    if Layout.Minimized then
        return
    end

    local startW = Pointer.StartSize.X
    local startH = Pointer.StartSize.Y
    local width = startW
    local height = startH

    if Pointer.Edge == "Right" then
        local maxW = math.max(MinSize.X, bounds.X - startX)
        width = math.clamp(startW + delta.X, MinSize.X, maxW)
    elseif Pointer.Edge == "Bottom" then
        local maxH = math.max(MinSize.Y, bounds.Y - startY)
        height = math.clamp(startH + delta.Y, MinSize.Y, maxH)
    end

    GUI.Main.Size = UDim2.fromOffset(width, height)
    Layout.LastHeight = height
end)

connect(UserInputService.InputEnded, function(input)
    if not Pointer.Mode then
        return
    end
    if input.UserInputType == Enum.UserInputType.Touch then
        if Pointer.ActiveInput == input then
            endPointer()
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        endPointer()
    end
end)

local function createResizeHandle(edge, position, size)
    local handle = create("Frame", {
        Position = position,
        Size = size,
        BackgroundColor3 = Theme.ResizeActive,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 101
    }, GUI.ResizeOverlay)

    handle.MouseEnter:Connect(function()
        if not Pointer.Mode and not Layout.Minimized then
            tween(handle, 0.1, {BackgroundTransparency = 0.55})
        end
    end)

    handle.MouseLeave:Connect(function()
        if Pointer.Handle ~= handle then
            tween(handle, 0.12, {BackgroundTransparency = 1})
        end
    end)

    handle.InputBegan:Connect(function(input)
        if isPointerPress(input) and not Layout.Minimized then
            beginPointer("Resize", input, edge, handle)
        end
    end)

    GUI.Resize[edge] = handle
    return handle
end

createResizeHandle("Right", UDim2.new(1, 0, 0, 0), UDim2.new(0, 7, 1, 0))
createResizeHandle("Bottom", UDim2.new(0, 0, 1, 0), UDim2.new(1, 0, 0, 7))

syncResizeOverlay()

syncVisualControls = function()
    for key, toggle in pairs(GUI.Toggles) do
        if toggle and toggle.Set then
            toggle:Set(State.Toggles[key] == true, true)
        end
    end
    for key, dd in pairs(GUI.Dropdowns) do
        if dd and dd.Set and State.Options[key] ~= nil then
            dd:Set(State.Options[key], true)
        end
    end
end

function Core.RestoreAll()
    if State.Restoring then
        return
    end
    State.Restoring = true

    AntiLag.StopWatch()

    State.Reset()
    syncVisualControls()
    Selector.RefreshStatus()

    if GUI.RestoreButton and GUI.RestoreButton.Parent then
        GUI.RestoreButton.Text = "Restoring..."
    end

    task.spawn(function()
        Engine.Queue = {}
        Engine.QueuedSet = {}
        for _, source in ipairs(CategorySources) do
            Engine.Generation[source] = (Engine.Generation[source] or 0) + 1
            Tracker.Reset(source)
        end
        PV.ReleaseWatchers()

        local sources = {}
        for source in pairs(Storage.Index) do
            sources[#sources + 1] = source
        end
        for _, source in ipairs(sources) do
            Storage.EnqueueRelease(source)
        end

        local deadline = os.clock() + 15
        while Storage.ReleaseWorkerRunning or next(Storage.Releasing) ~= nil do
            if os.clock() >= deadline then
                break
            end
            yieldFrame()
        end

        Tracker.ResetAll()
        Storage.Cleanup()
        State.Restoring = false

        if GUI.RestoreButton and GUI.RestoreButton.Parent then
            GUI.RestoreButton.Text = "Restore Default"
        end
        Selector.RefreshStatus()
    end)
end

function Core.Shutdown()
    if not Core.Running then
        return
    end
    Core.Running = false

    AntiLag.StopWatch()
    AutoRefresh.StopAll()
    PV.ReleaseWatchers()
    endPointer()

    disconnectList(Core.Connections)

    Engine.Queue = {}
    Engine.QueuedSet = {}
    for _, source in ipairs(CategorySources) do
        Engine.Generation[source] = (Engine.Generation[source] or 0) + 1
    end

    local sources = {}
    for source in pairs(Storage.Index) do
        sources[#sources + 1] = source
    end

    task.spawn(function()
        for _, source in ipairs(sources) do
            Storage.EnqueueRelease(source)
        end
        local deadline = os.clock() + 15
        while Storage.ReleaseWorkerRunning or next(Storage.Releasing) ~= nil do
            if os.clock() >= deadline then
                break
            end
            yieldFrame()
        end
        Tracker.ResetAll()
        Storage.Data = {}
        Storage.Index = {}
        Storage.Permanent = {}
    end)

    pcall(function()
        if GUI.Screen then
            GUI.Screen:Destroy()
        end
    end)

    Selector.Cards = {}
    GUI.Toggles = {}
    GUI.Dropdowns = {}
    GUI.Resize = {}
    GUI.Cards = {}

    if genv and type(genv.__PerformanceManager) == "table" and genv.__PerformanceManager.Shutdown == Core.Shutdown then
        genv.__PerformanceManager = nil
    end
end

GUI.RestoreButton.MouseButton1Click:Connect(Core.RestoreAll)
GUI.CloseButton.MouseButton1Click:Connect(Core.Shutdown)

if genv then
    genv.__PerformanceManager = {Shutdown = Core.Shutdown}
end

AutoRefresh.Start()
Selector.Refresh()
syncVisualControls()
ServerManager.SetStatus("Ready", false)

task.spawn(function()
    while Core.Running do
        task.wait(20)
        if not Core.Running then
            break
        end
        local ok, err = pcall(function()
            Storage.Cleanup()
            Tracker.Clean()
        end)
        if not ok then
            warnMsg(err)
        end
    end
end)
