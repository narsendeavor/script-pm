-- Performance Manage Server
-- Create NarsEdv
-- https://github.com/narsendeavor/script-pm
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
    warn("[Server] " .. tostring(message))
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
    Background = Color3.fromHex("#151515"),
    Surface = Color3.fromHex("#1A1A1A"),
    SecondarySurface = Color3.fromHex("#0D0D0D"),
    InspectorRow = Color3.fromHex("#181818"),
    InspectorAlt = Color3.fromHex("#1A1A1A"),
    SectionHeader = Color3.fromHex("#1B1B1B"),
    Subsection = Color3.fromHex("#181818"),
    PlayerCard = Color3.fromHex("#151515"),
    Hover = Color3.fromHex("#282828"),
    Press = Color3.fromHex("#202020"),
    Border = Color3.fromHex("#000000"),
    SearchFocusBorder = Color3.fromHex("#4E4E4E"),
    Divider = Color3.fromHex("#000000"),
    Header = Color3.fromHex("#222222"),
    HeaderDivider = Color3.fromHex("#000000"),
    MutedText = Color3.fromHex("#969696"),
    PrimaryText = Color3.fromHex("#EBEBEB"),
    Active = Color3.fromHex("#FFFFFF"),
    Watermark = Color3.fromHex("#484848"),

    CheckFill = Color3.fromHex("#326FC2"),
    CheckHover = Color3.fromHex("#3B82F6"),
    CheckBoxBg = Color3.fromHex("#121212"),
    CheckBoxBorder = Color3.fromHex("#000000"),

    ToggleOn = Color3.fromHex("#326FC2"),
    ToggleOff = Color3.fromHex("#282828"),
    ToggleOnIcon = Color3.fromHex("#000000"),
    ScrollTrack = Color3.fromHex("#161616"),
    ScrollHandle = Color3.fromHex("#4A4A4A"),
    ResizeActive = Color3.fromHex("#FFFFFF"),

    DropdownBtn = Color3.fromHex("#242424"),
    DropdownBtnHover = Color3.fromHex("#2E2E2E"),
    DropdownBtnPress = Color3.fromHex("#1D1D1D"),
    DropdownCard = Color3.fromHex("#1D1D1D"),
    DropdownOptionHover = Color3.fromHex("#282828"),
    DropdownOptionActive = Color3.fromHex("#303030"),

    BtnRestore = Color3.fromHex("#242424"),
    BtnRestoreHover = Color3.fromHex("#2F2F2F"),
    BtnRestorePress = Color3.fromHex("#1B1B1B"),
    BtnRestoreText = Color3.fromHex("#EBEBEB")
}

local Icon = {
    ArrowLeft = "rbxassetid://92473583511724",
    ArrowRight = "rbxassetid://73780377692148",
    ArrowUp = "rbxassetid://132169295529879",
    ArrowDown = "rbxassetid://139953983876976",
    Expand = "rbxassetid://92473583511724",
    Collapse = "rbxassetid://136612013728069",
    Close = "rbxassetid://110786993356448",
    Minimal = "rbxassetid://118026365011536",
    Maximize = "rbxassetid://134243273101015",
    Search = "rbxassetid://121018724060431",
    Checklist = "rbxassetid://93898873302694",
    ToggleOn = "rbxassetid://96479131758775",
    ToggleOff = "rbxassetid://118026365011536",
    Rotate = "rbxassetid://117913330389477"
}

local function generateName()
    local bytes = {}
    for i = 1, 32 do
        bytes[i] = string.char(math.random(0, 255))
    end
    return "_pmcreate\narsedv_" .. table.concat(bytes)
end

local function sanitizeGeneratedName(rawName)
    local hex = string.gsub(rawName, "[^%w_]", function(ch)
        return string.format("%02x", string.byte(ch))
    end)
    if hex == "" then
        return "_pmcreate_arsedv_gui"
    end
    return string.sub(hex, 1, 48)
end

local function applyGeneratedName(instance, fixedName)
    if fixedName then
        local okFixed = pcall(function()
            instance.Name = fixedName
        end)
        if okFixed then
            return fixedName
        end
    end

    local okGen, rawName = pcall(generateName)
    if okGen and type(rawName) == "string" and rawName ~= "" then
        local okAssign = pcall(function()
            instance.Name = rawName
        end)
        if okAssign and instance.Name ~= "" then
            return instance.Name
        end
        local safeName = sanitizeGeneratedName(rawName)
        local okSafe = pcall(function()
            instance.Name = safeName
        end)
        if okSafe then
            warnMsg("GUI naming fallback applied")
            return safeName
        end
    end

    local fallback = "_pmcreate_arsedv_gui"
    pcall(function()
        instance.Name = fallback
    end)
    warnMsg("GUI naming fallback applied")
    return fallback
end

local GUI: {[string]: any} = {
    Toggles = {},
    Dropdowns = {},
    Resize = {},
    Cards = {},
    SearchEntries = {},
    Subsections = {}
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

local PhysicalClassCache = {}

local function isPhysicalInstance(instance)
    local className = instance.ClassName
    local cached = PhysicalClassCache[className]
    if cached == nil then
        cached = instance:IsA("BasePart")
        PhysicalClassCache[className] = cached
    end
    return cached
end

local function isProtectedGui(instance, allowCharacterBillboard)
    if typeof(instance) ~= "Instance" then
        return true
    end
    local okWs, inWorkspace = pcall(instance.IsDescendantOf, instance, Workspace)
    if okWs and inWorkspace then
        if isPhysicalInstance(instance) then
            return false
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

            local sliceCount = Core.Running and 45 or 220
            local writeLimit = Core.Running and 35 or 180
            local timeLimit = Core.Running and 0.0018 or 0.005
            if index % sliceCount == 0 or Storage.FrameWrites >= writeLimit or (os.clock() - sliceStart) >= timeLimit then
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
    Tracker.Processed[source .. "_Vis"] = nil
    Tracker.Processed[source .. "_Lod"] = nil
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

local StreamingModelLod = nil
pcall(function()
    StreamingModelLod = Enum.ModelLevelOfDetail.StreamingMesh
end)

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
        if p.ClassName == "Model" and Players:GetPlayerFromCharacter(p) then
            CharacterCache[p] = true
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
            if className == "MeshPart" or className == "UnionOperation" then
                Storage.Apply(instance, "RenderFidelity", Enum.RenderFidelity.Performance, source)
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
    if className == "Model" then
        if StreamingModelLod and State.Toggles.MeshPart and not belongsToAnyCharacter(instance) then
            if Tracker.Mark(source .. "_Lod", instance) then
                Storage.Apply(instance, "LevelOfDetail", StreamingModelLod, source)
            end
        end
        return
    end
    if className ~= "SpecialMesh" and className ~= "MeshPart" and className ~= "UnionOperation" then
        return
    end
    if isProtectedGui(instance, false) or belongsToAnyCharacter(instance) then
        return
    end
    if State.Toggles.MeshSpecial and className == "SpecialMesh" then
        if Tracker.Mark(source, instance) then
            Storage.Apply(instance, "TextureId", "", source)
        end
    elseif State.Toggles.MeshPart and (className == "MeshPart" or className == "UnionOperation") then
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
    Lighting = function(source)
        Storage.Apply(Lighting, "EnvironmentSpecularScale", 0, source)
        Storage.Apply(Lighting, "ShadowSoftness", 0, source)
    end,
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

local ProcessorErrors = {}

local function runProcessor(processor, instance, scoped)
    local ok, err = pcall(processor, instance, scoped)
    if not ok then
        local message = tostring(err)
        if not ProcessorErrors[message] then
            ProcessorErrors[message] = true
            warnMsg(message)
        end
    end
end

local function isSourceStale(source, generation)
    return not Core.Running
        or State.Restoring
        or Engine.Generation[source] ~= generation
        or not isSourceActive(source)
end

local StaleCheckInterval = 64

local function makeStaleCheck(source, generation)
    local calls = 0
    return function(force)
        if not Core.Running or State.Restoring or Engine.Generation[source] ~= generation then
            return true
        end
        calls = calls + 1
        if force or calls % StaleCheckInterval == 0 then
            return not isSourceActive(source)
        end
        return false
    end
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
            if shouldStopFn(true) then
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

    local shouldStop = makeStaleCheck(source, generation)
    local function visit(instance)
        runProcessor(processor, instance, true)
    end

    for _, root in ipairs(roots) do
        if isSourceStale(source, generation) then
            return
        end
        if not traverseRootIncremental(root, visit, shouldStop) then
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

    local procs = {}
    for _, item in ipairs(activeItems) do
        local proc = Processors[item.Source]
        if proc then
            procs[#procs + 1] = {Source = item.Source, Generation = item.Generation, Proc = proc}
        end
    end

    local checks = 0
    local function shouldStopAll(force)
        if not Core.Running or State.Restoring then
            return true
        end
        checks = checks + 1
        if force or checks % StaleCheckInterval == 0 then
            for i = #procs, 1, -1 do
                local entry = procs[i]
                if isSourceStale(entry.Source, entry.Generation) then
                    table.remove(procs, i)
                end
            end
        end
        return #procs == 0
    end

    local function visitAll(instance)
        for i = 1, #procs do
            runProcessor(procs[i].Proc, instance, true)
        end
    end

    local matService = getMaterialService()
    local auxVisited = {}
    local auxRoots = {}
    for _, entry in ipairs(procs) do
        local s = entry.Source
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
        if shouldStopAll(true) then
            return
        end
        traverseRootIncremental(auxRoot, visitAll, shouldStopAll)
        yieldFrame()
    end

    local terrain = getTerrain()
    if terrain then
        for _, entry in ipairs(procs) do
            if entry.Source == "Weather" and not isSourceStale(entry.Source, entry.Generation) then
                pcall(entry.Proc, terrain, true)
                yieldFrame()
            end
        end
    end

    if shouldStopAll(true) then
        return
    end
    traverseRootIncremental(Workspace, visitAll, shouldStopAll)
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
                            runProcessor(proc, instance, false)
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

local GuardedSources = {"Lighting", "Shadow", "CastShadowControl", "LowGraphics"}
local GuardInterval = 2

function AntiLag.Enforce()
    if Engine.WorkerRunning then
        return
    end

    local active = {}
    for _, source in ipairs(GuardedSources) do
        if isSourceActive(source) and not Storage.Releasing[source] and not Storage.ReleaseActive[source] then
            active[#active + 1] = source
            local static = Statics[source]
            if static then
                pcall(static, source)
            end
        end
    end
    if #active == 0 then
        return
    end

    local roots = {Lighting}
    local camera = Workspace.CurrentCamera
    if camera then
        roots[#roots + 1] = camera
    end

    for _, root in ipairs(roots) do
        for _, instance in ipairs(root:GetDescendants()) do
            for _, source in ipairs(active) do
                local processed = Tracker.Processed[source]
                if processed then
                    processed[instance] = nil
                end
                runProcessor(Processors[source], instance, true)
            end
        end
    end
end

function AntiLag.StartGuard()
    if AntiLag.GuardToken then
        return
    end
    local token = {}
    AntiLag.GuardToken = token

    task.spawn(function()
        while Core.Running and AntiLag.GuardToken == token do
            task.wait(GuardInterval)
            if Core.Running and AntiLag.GuardToken == token and not State.Restoring then
                local ok, err = pcall(AntiLag.Enforce)
                if not ok then
                    warnMsg(err)
                end
            end
        end
    end)
end

function AntiLag.StopGuard()
    AntiLag.GuardToken = nil
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
    AntiLag.StartGuard()
end

function AntiLag.StopWatch()
    AntiLag.StopGuard()
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

function AntiLag.VisualManager.ApplyQuality(level, presetName)
    local function apply()
        local ok, rendering = pcall(function()
            return settings().Rendering
        end)
        if ok and typeof(rendering) == "Instance" then
            Storage.Permanent[rendering] = true
            Storage.Apply(rendering, "QualityLevel", level, "Preset")
        end
    end

    if not (Storage.Releasing.Preset or Storage.ReleaseActive.Preset) then
        apply()
        return
    end

    task.spawn(function()
        while Core.Running and (Storage.Releasing.Preset or Storage.ReleaseActive.Preset) do
            yieldFrame()
        end
        if Core.Running and not State.Restoring and State.Options.GraphicsPreset == presetName then
            apply()
        end
    end)
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
        AntiLag.VisualManager.ApplyQuality(config.QualityLevel, presetName)
    else
        Engine.Stop("Preset")
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
        if Selector.AddPlayer then
            Selector.AddPlayer(player)
        else
            Selector.Refresh()
        end
    end)

    connect(Players.PlayerRemoving, function(player)
        AutoRefresh.Untrack(player)
        PV.Release(player)
        State.Excluded[player.UserId] = nil
        task.defer(function()
            if Core.Running then
                refreshCharacterCache()
                if Selector.RemovePlayer then
                    Selector.RemovePlayer(player.UserId)
                else
                    Selector.Refresh()
                end
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

local ActiveTweens = setmetatable({}, {__mode = "k"})

local function cancelTween(instance)
    local existing = ActiveTweens[instance]
    if existing then
        ActiveTweens[instance] = nil
        pcall(function()
            existing:Cancel()
        end)
    end
end

local function cancelAllTweens()
    for instance, object in pairs(ActiveTweens) do
        ActiveTweens[instance] = nil
        pcall(function()
            object:Cancel()
        end)
    end
end

local function create(className, properties, parent, fixedName)
    local instance = Instance.new(className)
    applyGeneratedName(instance, fixedName)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

local function tween(instance, duration, properties, style, direction)
    cancelTween(instance)
    local object = TweenService:Create(
        instance,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        properties
    )
    ActiveTweens[instance] = object
    object.Completed:Connect(function()
        if ActiveTweens[instance] == object then
            ActiveTweens[instance] = nil
        end
    end)
    object:Play()
    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 2)
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
        existing.PaddingLeft = UDim.new(0, left or 0)
        existing.PaddingTop = UDim.new(0, top or 0)
        existing.PaddingRight = UDim.new(0, right or 0)
        existing.PaddingBottom = UDim.new(0, bottom or 0)
        return existing
    end
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0)
    }, parent)
end

local function listLayout(parent, gap)
    return create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, gap or 0)
    }, parent)
end

local function isTouchOnlyInput(input)
    if input and input.UserInputType == Enum.UserInputType.Touch then
        return true
    end
    local ok, lastType = pcall(function()
        return UserInputService:GetLastInputType()
    end)
    return ok and lastType == Enum.UserInputType.Touch
end

local function bindHover(button, idle, hover, press)
    local pointerInside = false
    local pressing = false

    local function snapIdle()
        pointerInside = false
        pressing = false
        cancelTween(button)
        button.BackgroundColor3 = idle
    end

    button.MouseEnter:Connect(function()
        if isTouchOnlyInput(nil) then
            return
        end
        pointerInside = true
        if not pressing then
            tween(button, 0.08, {BackgroundColor3 = hover})
        end
    end)

    button.MouseLeave:Connect(function()
        pointerInside = false
        pressing = false
        tween(button, 0.10, {BackgroundColor3 = idle})
    end)

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            pressing = true
            tween(button, 0.06, {BackgroundColor3 = press})
        elseif input.UserInputType == Enum.UserInputType.Touch then
            pointerInside = false
            pressing = true
            cancelTween(button)
            button.BackgroundColor3 = press
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            snapIdle()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            pressing = false
            if pointerInside and not isTouchOnlyInput(input) then
                tween(button, 0.08, {BackgroundColor3 = hover})
            else
                tween(button, 0.10, {BackgroundColor3 = idle})
            end
        end
    end)

    button.MouseButton1Click:Connect(function()
        if isTouchOnlyInput(nil) or not pointerInside then
            snapIdle()
        end
    end)

    button:GetPropertyChangedSignal("Visible"):Connect(function()
        if not button.Visible then
            snapIdle()
        end
    end)
end

local function makeLabel(parent, text, properties)
    local props = {
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = text,
        TextColor3 = Theme.PrimaryText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    }
    for key, value in pairs(properties or {}) do
        props[key] = value
    end
    return create("TextLabel", props, parent)
end

local function makeDivider(parent, zIndex, insetTotal)
    return create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, -(insetTotal or 0), 0, 1),
        BackgroundColor3 = Theme.Divider,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ZIndex = zIndex or 2
    }, parent)
end

local function makeColumnDivider(parent, splitRatio, zIndex)
    return create("Frame", {
        Position = UDim2.new(splitRatio or 0.60, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Divider,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ZIndex = zIndex or 2
    }, parent)
end

local LABEL_COLUMN_RATIO = 0.60

local function registerSearchEntry(sectionKey, frame, searchText, subsectionKey)
    local entry = {
        Section = sectionKey,
        Frame = frame,
        SearchText = string.lower(searchText or ""),
        Subsection = subsectionKey
    }
    GUI.SearchEntries[#GUI.SearchEntries + 1] = entry
    return entry
end

local function makeSubTitle(parent, sectionKey, subsectionKey, text, order)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = Theme.Subsection,
        BorderSizePixel = 0,
        LayoutOrder = order
    }, parent)
    makeDivider(row, 2)
    makeLabel(row, text, {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -16, 1, 0),
        TextColor3 = Theme.MutedText,
        TextSize = 11,
        Font = Enum.Font.BuilderSansMedium,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
    GUI.Subsections[sectionKey .. ":" .. subsectionKey] = {
        Frame = row,
        Section = sectionKey,
        Subsection = subsectionKey
    }
    return row
end

local function createPropertyActionRow(parent, sectionKey, subsectionKey, text, order, actionText, iconImage, callback)
    local row = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 23),
        BackgroundColor3 = Theme.InspectorRow,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ClipsDescendants = true,
        LayoutOrder = order
    }, parent)
    makeDivider(row, 2)
    makeColumnDivider(row, LABEL_COLUMN_RATIO, 2)
    bindHover(row, Theme.InspectorRow, Theme.Hover, Theme.Press)

    local labelX = 16
    if iconImage then
        create("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 14, 0.5, 0),
            Size = UDim2.fromOffset(13, 13),
            BackgroundTransparency = 1,
            Image = iconImage,
            ImageColor3 = Theme.PrimaryText
        }, row)
        labelX = 32
    end

    local nameLbl = makeLabel(row, text, {
        Position = UDim2.fromOffset(labelX, 0),
        Size = UDim2.new(LABEL_COLUMN_RATIO, -(labelX + 6), 1, 0),
        Font = Enum.Font.BuilderSans,
        TextSize = 11,
        TextColor3 = Theme.PrimaryText,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local statusLbl = makeLabel(row, actionText or "Execute", {
        Position = UDim2.new(LABEL_COLUMN_RATIO, 8, 0, 0),
        Size = UDim2.new(1 - LABEL_COLUMN_RATIO, -14, 1, 0),
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 11,
        TextColor3 = Theme.MutedText,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    if callback then
        row.MouseButton1Click:Connect(callback)
    end

    registerSearchEntry(sectionKey, row, text .. " " .. (actionText or ""), subsectionKey)
    return row, statusLbl, nameLbl
end

local function createPropertyCheckboxRow(parent, sectionKey, subsectionKey, text, order, key, callback)
    local row = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 23),
        BackgroundColor3 = Theme.InspectorRow,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ClipsDescendants = true,
        LayoutOrder = order
    }, parent)
    makeDivider(row, 2)
    makeColumnDivider(row, LABEL_COLUMN_RATIO, 2)
    bindHover(row, Theme.InspectorRow, Theme.Hover, Theme.Press)

    makeLabel(row, text, {
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(LABEL_COLUMN_RATIO, -20, 1, 0),
        Font = Enum.Font.BuilderSans,
        TextSize = 11,
        TextColor3 = Theme.PrimaryText,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local box = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(LABEL_COLUMN_RATIO, 8, 0.5, 0),
        Size = UDim2.fromOffset(15, 15),
        BackgroundColor3 = Theme.CheckBoxBg,
        BorderSizePixel = 0
    }, row)
    corner(box, 3)
    local boxStroke = stroke(box, Theme.CheckBoxBorder, true)
    local boxScale = create("UIScale", {Scale = 1}, box)

    local checkIcon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(11, 11),
        BackgroundTransparency = 1,
        Image = Icon.Checklist,
        ImageColor3 = Theme.Active,
        ImageTransparency = 1,
        Visible = false
    }, box)

    local toggle = {Value = false, Frame = row}
    local animToken = 0

    function toggle:Set(value, silent)
        self.Value = value and true or false
        animToken = animToken + 1
        local currentToken = animToken
        if self.Value then
            checkIcon.Visible = true
            tween(box, 0.12, {BackgroundColor3 = Theme.CheckFill})
            tween(boxStroke, 0.12, {Color = Theme.CheckFill})
            if silent then
                cancelTween(boxScale)
                boxScale.Scale = 1
                cancelTween(checkIcon)
                checkIcon.Size = UDim2.fromOffset(11, 11)
                checkIcon.ImageTransparency = 0
            else
                cancelTween(boxScale)
                boxScale.Scale = 0.84
                tween(boxScale, 0.18, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                cancelTween(checkIcon)
                checkIcon.Size = UDim2.fromOffset(2, 2)
                checkIcon.ImageTransparency = 0.25
                tween(checkIcon, 0.16, {ImageTransparency = 0, Size = UDim2.fromOffset(11, 11)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end
        else
            tween(box, 0.12, {BackgroundColor3 = Theme.CheckBoxBg})
            tween(boxStroke, 0.12, {Color = Theme.CheckBoxBorder})
            if silent then
                cancelTween(boxScale)
                boxScale.Scale = 1
                cancelTween(checkIcon)
                checkIcon.Visible = false
                checkIcon.ImageTransparency = 1
                checkIcon.Size = UDim2.fromOffset(2, 2)
            else
                cancelTween(boxScale)
                boxScale.Scale = 0.9
                tween(boxScale, 0.14, {Scale = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local t = tween(checkIcon, 0.12, {ImageTransparency = 1, Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                t.Completed:Connect(function(playbackState)
                    if playbackState == Enum.PlaybackState.Completed and currentToken == animToken and not self.Value and checkIcon.Parent then
                        checkIcon.Visible = false
                    end
                end)
            end
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

    registerSearchEntry(sectionKey, row, text .. " " .. tostring(key or ""), subsectionKey)
    return toggle
end

local function createPropertyToggleRow(parent, sectionKey, subsectionKey, text, order, key, callback)
    local row = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 23),
        BackgroundColor3 = Theme.InspectorRow,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ClipsDescendants = true,
        LayoutOrder = order
    }, parent)
    makeDivider(row, 2)
    makeColumnDivider(row, LABEL_COLUMN_RATIO, 2)
    bindHover(row, Theme.InspectorRow, Theme.Hover, Theme.Press)

    makeLabel(row, text, {
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(LABEL_COLUMN_RATIO, -20, 1, 0),
        Font = Enum.Font.BuilderSans,
        TextSize = 11,
        TextColor3 = Theme.PrimaryText,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local track = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(LABEL_COLUMN_RATIO, 8, 0.5, 0),
        Size = UDim2.fromOffset(30, 16),
        BackgroundColor3 = Theme.ToggleOff,
        BorderSizePixel = 0
    }, row)
    corner(track, 8)

    local knob = create("Frame", {
        Position = UDim2.new(0, 2, 0.5, -6),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = Theme.MutedText,
        BorderSizePixel = 0
    }, track)
    corner(knob, 6)

    local icon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
        Image = Icon.ToggleOff,
        ImageColor3 = Theme.Background
    }, knob)

    local toggle = {Value = false, Frame = row}

    function toggle:Set(value, silent)
        self.Value = value and true or false
        if self.Value then
            icon.Image = Icon.ToggleOn
            icon.ImageColor3 = Theme.ToggleOnIcon
            tween(track, 0.14, {BackgroundColor3 = Theme.ToggleOn})
            tween(knob, 0.14, {Position = UDim2.new(0, 16, 0.5, -6), BackgroundColor3 = Theme.Active})
        else
            icon.Image = Icon.ToggleOff
            icon.ImageColor3 = Theme.Background
            tween(track, 0.14, {BackgroundColor3 = Theme.ToggleOff})
            tween(knob, 0.14, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Theme.MutedText})
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

    registerSearchEntry(sectionKey, row, text .. " " .. tostring(key or ""), subsectionKey)
    return toggle
end

local function createCheckbox(parent, initialValue, onChanged)
    local box = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(15, 15),
        BackgroundColor3 = Theme.CheckBoxBg,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = ""
    }, parent)
    corner(box, 3)
    local boxStroke = stroke(box, Theme.CheckBoxBorder, true)
    local boxScale = create("UIScale", {Scale = 1}, box)

    local checkIcon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(11, 11),
        BackgroundTransparency = 1,
        Image = Icon.Checklist,
        ImageColor3 = Theme.Active,
        ImageTransparency = 1,
        Visible = false
    }, box)

    local cb = {Value = initialValue and true or false}
    local animToken = 0

    function cb:Set(value, silent)
        self.Value = value and true or false
        animToken = animToken + 1
        local currentToken = animToken
        if self.Value then
            checkIcon.Visible = true
            tween(box, 0.12, {BackgroundColor3 = Theme.CheckFill})
            tween(boxStroke, 0.12, {Color = Theme.CheckFill})
            if silent then
                cancelTween(boxScale)
                boxScale.Scale = 1
                cancelTween(checkIcon)
                checkIcon.Size = UDim2.fromOffset(11, 11)
                checkIcon.ImageTransparency = 0
            else
                cancelTween(boxScale)
                boxScale.Scale = 0.84
                tween(boxScale, 0.18, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                cancelTween(checkIcon)
                checkIcon.Size = UDim2.fromOffset(2, 2)
                checkIcon.ImageTransparency = 0.25
                tween(checkIcon, 0.16, {ImageTransparency = 0, Size = UDim2.fromOffset(11, 11)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end
        else
            tween(box, 0.12, {BackgroundColor3 = Theme.CheckBoxBg})
            tween(boxStroke, 0.12, {Color = Theme.CheckBoxBorder})
            if silent then
                cancelTween(boxScale)
                boxScale.Scale = 1
                cancelTween(checkIcon)
                checkIcon.Visible = false
                checkIcon.ImageTransparency = 1
                checkIcon.Size = UDim2.fromOffset(2, 2)
            else
                cancelTween(boxScale)
                boxScale.Scale = 0.9
                tween(boxScale, 0.14, {Scale = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local t = tween(checkIcon, 0.12, {ImageTransparency = 1, Size = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                t.Completed:Connect(function(playbackState)
                    if playbackState == Enum.PlaybackState.Completed and currentToken == animToken and not self.Value and checkIcon.Parent then
                        checkIcon.Visible = false
                    end
                end)
            end
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

local ActiveDropdownPopup = nil

local function closeActiveDropdownPopup()
    if ActiveDropdownPopup then
        local closeFn = ActiveDropdownPopup.Close
        ActiveDropdownPopup = nil
        if closeFn then
            closeFn()
        end
    end
end

local function createPropertyDropdownRow(parent, sectionKey, subsectionKey, labelText, order, options, initialValue, key, onSelect)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundColor3 = Theme.InspectorRow,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = order
    }, parent)
    makeDivider(row, 2)
    makeColumnDivider(row, LABEL_COLUMN_RATIO, 2)

    local titleLbl = makeLabel(row, labelText, {
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(LABEL_COLUMN_RATIO, -20, 1, 0),
        Font = Enum.Font.BuilderSans,
        TextSize = 11,
        TextColor3 = Theme.PrimaryText,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local dropdownBtn = create("TextButton", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(LABEL_COLUMN_RATIO, 6, 0.5, 0),
        Size = UDim2.new(1 - LABEL_COLUMN_RATIO, -12, 0, 19),
        BackgroundColor3 = Theme.DropdownBtn,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ClipsDescendants = true,
        ZIndex = 3
    }, row)
    corner(dropdownBtn, 3)
    local btnStroke = stroke(dropdownBtn, Theme.Border, true)
    bindHover(dropdownBtn, Theme.DropdownBtn, Theme.DropdownBtnHover, Theme.DropdownBtnPress)

    local valueLbl = makeLabel(dropdownBtn, tostring(initialValue or options[1] or ""), {
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -22, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.PrimaryText,
        TextSize = 10,
        Font = Enum.Font.BuilderSansMedium,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 4
    })

    local arrow = create("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        Image = Icon.ArrowDown,
        ImageColor3 = Theme.MutedText,
        ZIndex = 4
    }, dropdownBtn)

    local dd = {
        Value = initialValue or options[1],
        Expanded = false,
        OptionButtons = {},
        Title = titleLbl,
        Frame = row
    }

    local function syncSelectionVisual()
        valueLbl.Text = tostring(dd.Value)
        for optName, btn in pairs(dd.OptionButtons) do
            if btn and btn.Parent then
                local active = optName == dd.Value
                btn.BackgroundColor3 = active and Theme.DropdownOptionActive or Theme.DropdownCard
                btn.TextColor3 = active and Theme.Active or Theme.PrimaryText
            end
        end
    end

    local function closeSelf()
        dd.Expanded = false
        dd.OptionButtons = {}
        arrow.Image = Icon.ArrowDown
        btnStroke.Color = Theme.Border
        if GUI.DropdownPopup and GUI.DropdownPopup.Parent then
            cancelTween(GUI.DropdownPopup)
            GUI.DropdownPopup:Destroy()
            GUI.DropdownPopup = nil
        end
        if GUI.DropdownBackdrop and GUI.DropdownBackdrop.Parent then
            GUI.DropdownBackdrop.Visible = false
        end
        if GUI.DropdownLayer and GUI.DropdownLayer.Parent then
            GUI.DropdownLayer.Visible = false
        end
    end

    function dd:SetExpanded(open)
        local wantOpen = open and true or false
        if not wantOpen then
            if ActiveDropdownPopup and ActiveDropdownPopup.Owner == dd then
                closeActiveDropdownPopup()
            else
                closeSelf()
            end
            return
        end

        closeActiveDropdownPopup()

        local layer = GUI.DropdownLayer
        if not layer or not layer.Parent or not dropdownBtn.Parent then
            return
        end

        self.Expanded = true
        arrow.Image = Icon.ArrowUp
        btnStroke.Color = Theme.SearchFocusBorder

        layer.Visible = true
        if GUI.DropdownBackdrop then
            GUI.DropdownBackdrop.Visible = true
        end

        local layerPos = layer.AbsolutePosition
        local layerSize = layer.AbsoluteSize
        local btnPos = dropdownBtn.AbsolutePosition
        local btnSize = dropdownBtn.AbsoluteSize

        local cardWidth = math.max(48, math.floor(btnSize.X + 0.5))
        local optionHeight = 20
        local verticalPad = 6
        local targetHeight = (#options * optionHeight) + verticalPad

        local relX = math.clamp(math.floor(btnPos.X - layerPos.X + 0.5), 2, math.max(2, layerSize.X - cardWidth - 2))
        local belowY = math.floor((btnPos.Y - layerPos.Y) + btnSize.Y + 3 + 0.5)
        local relY = belowY
        if belowY + targetHeight > layerSize.Y - 4 then
            local aboveY = math.floor((btnPos.Y - layerPos.Y) - targetHeight - 3 + 0.5)
            if aboveY >= 4 then
                relY = aboveY
            else
                relY = math.max(4, layerSize.Y - targetHeight - 4)
            end
        end

        local popup = create("Frame", {
            Position = UDim2.fromOffset(relX, relY),
            Size = UDim2.fromOffset(cardWidth, 0),
            BackgroundColor3 = Theme.DropdownCard,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ZIndex = 42
        }, layer)
        corner(popup, 3)
        stroke(popup, Theme.Border, true)
        ensurePadding(popup, 0, 3, 0, 3)
        listLayout(popup, 0)
        GUI.DropdownPopup = popup

        self.OptionButtons = {}
        for idx, optName in ipairs(options) do
            local isSelected = optName == self.Value
            local optBtn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, optionHeight),
                BackgroundColor3 = isSelected and Theme.DropdownOptionActive or Theme.DropdownCard,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Font = Enum.Font.BuilderSansMedium,
                Text = tostring(optName),
                TextColor3 = isSelected and Theme.Active or Theme.PrimaryText,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                LayoutOrder = idx,
                ZIndex = 43
            }, popup)
            ensurePadding(optBtn, 8, 0, 6, 0)
            optBtn.MouseEnter:Connect(function()
                if not isTouchOnlyInput(nil) and dd.Value ~= optName then
                    tween(optBtn, 0.08, {BackgroundColor3 = Theme.DropdownOptionHover})
                end
            end)
            optBtn.MouseLeave:Connect(function()
                if dd.Value ~= optName then
                    tween(optBtn, 0.08, {BackgroundColor3 = Theme.DropdownCard})
                end
            end)
            optBtn.MouseButton1Click:Connect(function()
                dd:Set(optName)
                closeActiveDropdownPopup()
            end)
            self.OptionButtons[optName] = optBtn
        end

        ActiveDropdownPopup = {
            Owner = dd,
            Close = closeSelf
        }

        tween(popup, 0.12, {Size = UDim2.fromOffset(cardWidth, targetHeight)})
    end

    function dd:Set(val, silent)
        self.Value = val
        syncSelectionVisual()
        if not silent and onSelect then
            onSelect(val)
        end
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        dd:SetExpanded(not dd.Expanded)
    end)

    syncSelectionVisual()
    if key then
        GUI.Dropdowns[key] = dd
    end

    registerSearchEntry(sectionKey, row, labelText .. " " .. table.concat(options, " "), subsectionKey)
    return dd
end

local function createAccordionSection(parent, title, order, defaultExpanded)
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
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = Theme.SectionHeader,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = 1
    }, card)
    makeDivider(header, 2)
    bindHover(header, Theme.SectionHeader, Theme.Hover, Theme.Press)

    local arrow = create("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 6, 0.5, 0),
        Size = UDim2.fromOffset(11, 11),
        BackgroundTransparency = 1,
        Image = defaultExpanded and Icon.Collapse or Icon.Expand,
        ImageColor3 = Theme.PrimaryText
    }, header)

    local titleLabel = makeLabel(header, title, {
        Position = UDim2.fromOffset(21, 0),
        Size = UDim2.new(1, -27, 1, 0),
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 11,
        TextColor3 = Theme.Active,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local clipFrame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = defaultExpanded and true or false,
        LayoutOrder = 2
    }, card)

    local inner = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, clipFrame)
    listLayout(inner, 0)

    local cardObj = {
        Card = card,
        Header = header,
        TitleLabel = titleLabel,
        Container = inner,
        Expanded = defaultExpanded and true or false,
        UserExpanded = defaultExpanded and true or false
    }
    local animToken = 0

    local function applyState(animate)
        animToken = animToken + 1
        local currentToken = animToken
        arrow.Image = cardObj.Expanded and Icon.Collapse or Icon.Expand

        if cardObj.Expanded then
            clipFrame.Visible = true
            if animate then
                local targetH = inner.AbsoluteSize.Y
                if targetH <= 0 then
                    clipFrame.AutomaticSize = Enum.AutomaticSize.Y
                    clipFrame.Size = UDim2.new(1, 0, 0, 0)
                    return
                end
                clipFrame.AutomaticSize = Enum.AutomaticSize.None
                local t = tween(clipFrame, 0.16, {Size = UDim2.new(1, 0, 0, targetH)})
                t.Completed:Connect(function(playbackState)
                    if playbackState == Enum.PlaybackState.Completed and currentToken == animToken and cardObj.Expanded and clipFrame.Parent then
                        clipFrame.AutomaticSize = Enum.AutomaticSize.Y
                        clipFrame.Size = UDim2.new(1, 0, 0, 0)
                    end
                end)
            else
                cancelTween(clipFrame)
                clipFrame.AutomaticSize = Enum.AutomaticSize.Y
                clipFrame.Size = UDim2.new(1, 0, 0, 0)
            end
        else
            if animate then
                local currentH = clipFrame.AbsoluteSize.Y
                clipFrame.AutomaticSize = Enum.AutomaticSize.None
                clipFrame.Size = UDim2.new(1, 0, 0, currentH)
                local t = tween(clipFrame, 0.16, {Size = UDim2.new(1, 0, 0, 0)})
                t.Completed:Connect(function(playbackState)
                    if playbackState == Enum.PlaybackState.Completed and currentToken == animToken and not cardObj.Expanded and clipFrame.Parent then
                        clipFrame.Visible = false
                    end
                end)
            else
                cancelTween(clipFrame)
                clipFrame.AutomaticSize = Enum.AutomaticSize.None
                clipFrame.Size = UDim2.new(1, 0, 0, 0)
                clipFrame.Visible = false
            end
        end
    end

    function cardObj:SetExpanded(value, animate, fromUser)
        self.Expanded = value and true or false
        if fromUser then
            self.UserExpanded = self.Expanded
        end
        applyState(animate ~= false)
    end

    header.MouseButton1Click:Connect(function()
        local searchActive = GUI.SearchBox and GUI.SearchBox.Text ~= ""
        cardObj:SetExpanded(not cardObj.Expanded, true, not searchActive)
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
        if scroll.CanvasPosition.Y > limit then
            scroll.CanvasPosition = Vector2.new(0, limit)
        end
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
    return holder, scroll, update
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
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 50,
    IgnoreGuiInset = true
})
GUI.RootName = GUI.Screen.Name

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
local headerHeight = 22
local toolbarHeight = 26

GUI.Main = create("Frame", {
    AnchorPoint = Vector2.new(0, 0),
    Position = UDim2.fromOffset(
        math.max(0, math.floor(screenSize.X / 2 - initialWidth / 2)),
        math.max(0, math.floor(screenSize.Y / 2 - initialHeight / 2))
    ),
    Size = UDim2.fromOffset(initialWidth, initialHeight),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = false
}, GUI.Screen)

do
    local shadowProps = {
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
        applyGeneratedName(shadow)
        for property, value in pairs(shadowProps) do
            pcall(function()
                shadow[property] = value
            end)
        end
        pcall(function()
            shadow.Parent = GUI.Main
        end)
        GUI.Shadow = shadow
    end
end

GUI.Header = create("Frame", {
    Size = UDim2.new(1, 0, 0, headerHeight),
    BackgroundColor3 = Theme.Header,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 2
}, GUI.Main)

create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.fromScale(0, 1),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Theme.HeaderDivider,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    ZIndex = 2
}, GUI.Header)

makeLabel(GUI.Header, "Performance Manager", {
    Position = UDim2.fromOffset(8, 0),
    Size = UDim2.new(1, -54, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.BuilderSansMedium,
    TextSize = 12,
    TextColor3 = Theme.PrimaryText,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 3
})

local function headerButton(offsetX, image)
    local button = create("ImageButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, offsetX, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 3
    }, GUI.Header)
    corner(button, 3)
    local icon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        Image = image,
        ImageColor3 = Theme.PrimaryText,
        ZIndex = 4
    }, button)
    bindHover(button, Theme.Header, Theme.BtnRestoreHover, Theme.BtnRestorePress)
    return button, icon
end

GUI.CloseButton = headerButton(-4, Icon.Close)
GUI.MinimizeButton, GUI.MinimizeIcon = headerButton(-22, Icon.Minimal)

GUI.Toolbar = create("Frame", {
    Position = UDim2.fromOffset(0, headerHeight),
    Size = UDim2.new(1, 0, 0, toolbarHeight),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 2
}, GUI.Main)
makeDivider(GUI.Toolbar, 3, 20)

do
    local searchHolder = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 6, 0.5, 0),
        Size = UDim2.new(1, -134, 0, 19),
        BackgroundColor3 = Theme.SecondarySurface,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, GUI.Toolbar)
    corner(searchHolder, 3)
    local searchStroke = stroke(searchHolder, Theme.Border, true)

    create("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 5, 0.5, 0),
        Size = UDim2.fromOffset(11, 11),
        BackgroundTransparency = 1,
        Image = Icon.Search,
        ImageColor3 = Theme.MutedText
    }, searchHolder)

    GUI.SearchBox = create("TextBox", {
        Position = UDim2.fromOffset(20, 0),
        Size = UDim2.new(1, -36, 1, 0),
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = Enum.Font.BuilderSans,
        PlaceholderText = "Search settings",
        PlaceholderColor3 = Theme.MutedText,
        Text = "",
        TextColor3 = Theme.PrimaryText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true
    }, searchHolder)

    local clearSearchBtn = create("ImageButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.fromOffset(11, 11),
        BackgroundTransparency = 1,
        Image = Icon.Close,
        ImageColor3 = Theme.MutedText,
        Visible = false,
        AutoButtonColor = false
    }, searchHolder)

    GUI.SearchBox.Focused:Connect(function()
        searchStroke.Color = Theme.SearchFocusBorder
    end)

    GUI.SearchBox.FocusLost:Connect(function()
        searchStroke.Color = Theme.Border
    end)

    clearSearchBtn.MouseButton1Click:Connect(function()
        GUI.SearchBox.Text = ""
    end)

    GUI.SearchClearBtn = clearSearchBtn

    local resetBtn = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(118, 19),
        BackgroundColor3 = Theme.BtnRestore,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ClipsDescendants = true
    }, GUI.Toolbar)
    corner(resetBtn, 3)
    stroke(resetBtn, Theme.Border, true)
    bindHover(resetBtn, Theme.BtnRestore, Theme.BtnRestoreHover, Theme.BtnRestorePress)

    create("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 6, 0.5, 0),
        Size = UDim2.fromOffset(11, 11),
        BackgroundTransparency = 1,
        Image = Icon.Rotate,
        ImageColor3 = Theme.BtnRestoreText
    }, resetBtn)

    local resetLbl = makeLabel(resetBtn, "Reset all to Default", {
        Position = UDim2.fromOffset(20, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.BuilderSansMedium,
        TextColor3 = Theme.BtnRestoreText,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    GUI.RestoreButton = resetBtn
    GUI.RestoreButtonLabel = resetLbl
end

GUI.Content = create("Frame", {
    Position = UDim2.fromOffset(0, headerHeight + toolbarHeight),
    Size = UDim2.new(1, 0, 1, -(headerHeight + toolbarHeight)),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, GUI.Main)

GUI.Watermark = makeLabel(GUI.Content, "Create by NarsEdv - Version 0.1", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 10, 1, -6),
    Size = UDim2.fromOffset(200, 14),
    TextColor3 = Theme.Watermark,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    Active = false,
    ZIndex = 0
})

local _, MainScroll, updateMainScroll = createScroller(GUI.Content)
listLayout(MainScroll, 0)
GUI.MainScroll = MainScroll

GUI.DropdownLayer = create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 40
}, GUI.Content)

GUI.DropdownBackdrop = create("TextButton", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "",
    Visible = false,
    ZIndex = 40
}, GUI.DropdownLayer)

GUI.DropdownBackdrop.MouseButton1Click:Connect(closeActiveDropdownPopup)

MainScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    if ActiveDropdownPopup then
        closeActiveDropdownPopup()
    end
end)

GUI.Cards.Server = createAccordionSection(MainScroll, "Server", 1, true)
GUI.Cards.AntiLag = createAccordionSection(MainScroll, "Performance", 2, true)
GUI.Cards.HidePlayer = createAccordionSection(MainScroll, "Player", 3, true)

GUI.EmptySearchLabel = makeLabel(MainScroll, "No matching settings", {
    Size = UDim2.new(1, 0, 0, 26),
    TextColor3 = Theme.MutedText,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Center,
    Visible = false,
    LayoutOrder = 99
})

do
    local container = GUI.Cards.Server.Container

    local function createServerInfoRow(labelText, valueText, order, searchExtra)
        local row = create("Frame", {
            Size = UDim2.new(1, 0, 0, 21),
            BackgroundColor3 = Theme.InspectorRow,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            LayoutOrder = order
        }, container)
        makeDivider(row, 2)
        makeColumnDivider(row, LABEL_COLUMN_RATIO, 2)

        makeLabel(row, labelText, {
            Position = UDim2.fromOffset(16, 0),
            Size = UDim2.new(LABEL_COLUMN_RATIO, -20, 1, 0),
            Font = Enum.Font.BuilderSans,
            TextSize = 11,
            TextColor3 = Theme.PrimaryText,
            TextTruncate = Enum.TextTruncate.AtEnd
        })

        local valueLbl = makeLabel(row, valueText, {
            Position = UDim2.new(LABEL_COLUMN_RATIO, 8, 0, 0),
            Size = UDim2.new(1 - LABEL_COLUMN_RATIO, -12, 1, 0),
            Font = Enum.Font.BuilderSansMedium,
            TextSize = 11,
            TextColor3 = Theme.MutedText,
            TextTruncate = Enum.TextTruncate.AtEnd
        })

        registerSearchEntry("Server", row, labelText .. " " .. tostring(valueText) .. " " .. tostring(searchExtra or ""), "Info")
        return valueLbl
    end

    local function resolveExecutorIdentity()
        local fn = executorEnv.identifyexecutor or executorEnv.getexecutorname
        if type(fn) == "function" then
            local ok, name, version = pcall(fn)
            if ok and name and tostring(name) ~= "" then
                if version and tostring(version) ~= "" then
                    return tostring(name) .. " " .. tostring(version)
                end
                return tostring(name)
            end
        end
        return "Unknown"
    end

    local namePlaceLbl = createServerInfoRow("Name Place", "Loading...", 1, "place name map")
    local jobIdText = game.JobId ~= "" and game.JobId or "Studio / Local"
    createServerInfoRow("JobId", jobIdText, 2, "instance server id")
    local playerCountLbl = createServerInfoRow("PlayerCount", tostring(#Players:GetPlayers()) .. " / " .. tostring(Players.MaxPlayers), 3, "players count")
    createServerInfoRow("PlaceId", tostring(game.PlaceId), 4, "place id")
    createServerInfoRow("ExecutorIdentity", resolveExecutorIdentity(), 5, "executor identity")

    GUI.UpdatePlayerCount = function()
        if playerCountLbl and playerCountLbl.Parent then
            playerCountLbl.Text = tostring(#Players:GetPlayers()) .. " / " .. tostring(Players.MaxPlayers)
        end
    end

    task.spawn(function()
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)
        if not Core.Running or not namePlaceLbl.Parent then
            return
        end
        if ok and type(info) == "table" and type(info.Name) == "string" and info.Name ~= "" then
            namePlaceLbl.Text = info.Name
        else
            namePlaceLbl.Text = "Place " .. tostring(game.PlaceId)
        end
    end)

    local buttonBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.InspectorRow,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = 6
    }, container)
    makeDivider(buttonBar, 2)

    local buttonGrid = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 6, 0.5, 0),
        Size = UDim2.new(1, -12, 0, 21),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, buttonBar)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    }, buttonGrid)

    local function createServerActionButton(labelText, order)
        local btn = create("TextButton", {
            Size = UDim2.new(1 / 3, -3, 0, 21),
            BackgroundColor3 = Theme.BtnRestore,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.BuilderSansMedium,
            Text = labelText,
            TextColor3 = Theme.BtnRestoreText,
            TextSize = 10,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = order
        }, buttonGrid)
        corner(btn, 3)
        stroke(btn, Theme.Border, true)
        bindHover(btn, Theme.BtnRestore, Theme.BtnRestoreHover, Theme.BtnRestorePress)
        return btn
    end

    local rejoinBtn = createServerActionButton("Rejoin", 1)
    local hopBtn = createServerActionButton("Server Hop", 2)
    local smallBtn = createServerActionButton("Small Server", 3)
    registerSearchEntry("Server", buttonBar, "rejoin server hop small server actions", "Actions")

    local function bindConfirm(button, baseText, action)
        local token = 0
        local armed = false
        button.MouseButton1Click:Connect(function()
            if not armed then
                armed = true
                token = token + 1
                local current = token
                button.Text = "Confirm?"
                button.TextColor3 = Theme.Active
                task.delay(3, function()
                    if Core.Running and armed and token == current and button.Parent then
                        armed = false
                        button.Text = baseText
                        button.TextColor3 = Theme.BtnRestoreText
                    end
                end)
            else
                armed = false
                token = token + 1
                button.Text = baseText
                button.TextColor3 = Theme.BtnRestoreText
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

    local function teleportToServer(serverId, button, baseText)
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
        end)
        if not ok then
            ServerManager.SetStatus("Teleport failed", true)
            if button and button.Parent then
                button.Text = "Failed"
                task.delay(2, function()
                    if Core.Running and button.Parent then
                        button.Text = baseText
                    end
                end)
            end
        end
    end

    local function runServerAction(statusMsg, order, pages, pickSmallest, button, baseText)
        if ServerManager.Busy then
            return
        end
        ServerManager.Busy = true
        ServerManager.SetStatus(statusMsg, false)
        if button and button.Parent then
            button.Text = statusMsg
        end
        task.spawn(function()
            local server = findServer(order, pages, pickSmallest)
            ServerManager.Busy = false
            if not Core.Running then
                return
            end
            if not server then
                ServerManager.SetStatus("Teleport failed", true)
                if button and button.Parent then
                    button.Text = "Failed"
                    task.delay(2, function()
                        if Core.Running and button.Parent then
                            button.Text = baseText
                        end
                    end)
                end
                return
            end
            ServerManager.SetStatus("Teleporting...", false)
            if button and button.Parent then
                button.Text = "Teleporting..."
            end
            teleportToServer(server.id, button, baseText)
        end)
    end

    bindConfirm(rejoinBtn, "Rejoin", function()
        ServerManager.SetStatus("Rejoining...", false)
        rejoinBtn.Text = "Rejoining..."
        local ok = pcall(function()
            if #Players:GetPlayers() <= 1 then
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end)
        if not ok then
            ServerManager.SetStatus("Teleport failed", true)
            rejoinBtn.Text = "Failed"
            task.delay(2, function()
                if Core.Running and rejoinBtn.Parent then
                    rejoinBtn.Text = "Rejoin"
                end
            end)
        end
    end)

    bindConfirm(hopBtn, "Server Hop", function()
        runServerAction("Searching...", "Desc", 3, false, hopBtn, "Server Hop")
    end)

    bindConfirm(smallBtn, "Small Server", function()
        runServerAction("Searching...", "Asc", 2, true, smallBtn, "Small Server")
    end)

    pcall(function()
        connect(TeleportService.TeleportInitFailed, function()
            ServerManager.Busy = false
            ServerManager.SetStatus("Teleport failed", true)
            if rejoinBtn.Parent then rejoinBtn.Text = "Rejoin" end
            if hopBtn.Parent then hopBtn.Text = "Server Hop" end
            if smallBtn.Parent then smallBtn.Text = "Small Server" end
        end)
    end)
end

do
    local container = GUI.Cards.AntiLag.Container

    makeSubTitle(container, "Performance", "Presets", "Graphics Presets", 1)

    createPropertyDropdownRow(
        container,
        "Performance",
        "Presets",
        "Graphics Preset",
        2,
        {"Default", "Balanced", "Performance", "Ultra Performance", "Custom"},
        "Default",
        "GraphicsPreset",
        function(preset)
            AntiLag.VisualManager.ApplyPreset(preset)
        end
    )

    makeSubTitle(container, "Performance", "Visual", "Visual Manager", 3)

    createPropertyToggleRow(container, "Performance", "Visual", "Enable Anti Lag", 4, "AntiLag", function(val)
        AntiLag.SetMaster(val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Visual", "Reduce Visual Effects", 5, "Particle", function(val)
        AntiLag.SetCategory("Particle", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyDropdownRow(
        container,
        "Performance",
        "Visual",
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

    createPropertyCheckboxRow(container, "Performance", "Visual", "Shadow Settings", 7, "Shadow", function(val)
        AntiLag.SetCategory("Shadow", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Visual", "Lighting Settings", 8, "Lighting", function(val)
        AntiLag.SetCategory("Lighting", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Visual", "Light Sources", 9, "Light", function(val)
        AntiLag.SetCategory("Light", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Visual", "Character Effects", 10, "Character", function(val)
        AntiLag.SetCategory("Character", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Visual", "Weather Effects", 11, "Weather", function(val)
        AntiLag.SetCategory("Weather", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Visual", "Environmental Effects", 12, "Environment", function(val)
        AntiLag.SetCategory("Environment", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Visual", "Texture Effects", 13, "Texture", function(val)
        AntiLag.SetCategory("Texture", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Visual", "Low Graphics", 14, "LowGraphics", function(val)
        AntiLag.SetCategory("LowGraphics", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    makeSubTitle(container, "Performance", "Rendering", "Rendering Manager", 20)

    createPropertyCheckboxRow(container, "Performance", "Rendering", "SpecialMesh Optimization", 21, "MeshSpecial", function(val)
        AntiLag.RenderingManager.SetToggle("MeshSpecial", "MeshControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Rendering", "MeshPart Performance LOD", 22, "MeshPart", function(val)
        AntiLag.RenderingManager.SetToggle("MeshPart", "MeshControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Rendering", "Hide Decorative Meshes", 23, "MeshVisibility", function(val)
        AntiLag.RenderingManager.SetToggle("MeshVisibility", "MeshControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyDropdownRow(
        container,
        "Performance",
        "Rendering",
        "Texture Quality",
        24,
        {"Default", "Reduced", "Minimal"},
        "Default",
        "TextureQuality",
        function(val)
            State.Options.TextureQuality = val
            AntiLag.RenderingManager.RefreshSource("TextureQuality")
            AntiLag.VisualManager.MarkCustom()
        end
    )

    createPropertyCheckboxRow(container, "Performance", "Rendering", "Texture & SurfaceAppearance", 25, "TextureMap", function(val)
        AntiLag.RenderingManager.SetToggle("TextureMap", "TextureQuality", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Rendering", "MaterialVariant Strip", 26, "MaterialVariant", function(val)
        AntiLag.RenderingManager.SetToggle("MaterialVariant", "TextureQuality", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Rendering", "Hide Decals", 27, "DecalVisibility", function(val)
        AntiLag.RenderingManager.SetToggle("DecalVisibility", "DecalVisibility", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyDropdownRow(
        container,
        "Performance",
        "Rendering",
        "Particle Density",
        28,
        {"100%", "50%", "25%", "0%"},
        "100%",
        "ParticleDensity",
        function(val)
            State.Options.ParticleDensity = val
            AntiLag.RenderingManager.RefreshSource("ParticleDensity")
            AntiLag.VisualManager.MarkCustom()
        end
    )

    createPropertyDropdownRow(
        container,
        "Performance",
        "Rendering",
        "Transparency Control",
        29,
        {"Default", "Simplify", "Hide"},
        "Default",
        "TransparencyMode",
        function(val)
            State.Options.TransparencyMode = val
            AntiLag.RenderingManager.RefreshSource("TransparencyControl")
            AntiLag.VisualManager.MarkCustom()
        end
    )

    createPropertyCheckboxRow(container, "Performance", "Rendering", "Disable Local Effects", 30, "LocalEffects", function(val)
        AntiLag.RenderingManager.SetToggle("LocalEffects", "LocalEffects", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Rendering", "Terrain Decoration Off", 31, "TerrainDecoration", function(val)
        AntiLag.RenderingManager.SetToggle("TerrainDecoration", "TerrainDecoration", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Rendering", "Terrain Water Effects Off", 32, "TerrainWater", function(val)
        AntiLag.RenderingManager.SetToggle("TerrainWater", "TerrainWater", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Rendering", "Terrain Grass Decoration Off", 33, "TerrainGrass", function(val)
        AntiLag.RenderingManager.SetToggle("TerrainGrass", "TerrainGrass", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Rendering", "Clouds Off", 34, "CloudsControl", function(val)
        AntiLag.RenderingManager.SetToggle("CloudsControl", "CloudsControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Rendering", "Reflectance Off", 35, "ReflectanceControl", function(val)
        AntiLag.RenderingManager.SetToggle("ReflectanceControl", "ReflectanceControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)

    createPropertyCheckboxRow(container, "Performance", "Rendering", "CastShadow Off", 36, "CastShadowControl", function(val)
        AntiLag.RenderingManager.SetToggle("CastShadowControl", "CastShadowControl", val)
        AntiLag.VisualManager.MarkCustom()
    end)
end

local ThumbnailCache = {}

local function loadPlayerThumbnail(imageLabel, fallbackLabel, userId, cardObj)
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
        if not Core.Running or not cardObj or not cardObj.Alive or cardObj.UserId ~= userId or not imageLabel.Parent then
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

local function createCircularThumbnail(parent, userId, displayName, cardObj)
    local holder = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, parent)
    create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, holder)

    local initials = string.upper(string.sub(displayName or "?", 1, 2))
    local fallback = makeLabel(holder, initials, {
        Size = UDim2.fromScale(1, 1),
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 10,
        TextColor3 = Theme.MutedText,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1
    })

    local thumb = create("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScaleType = Enum.ScaleType.Crop,
        Image = "",
        ZIndex = 2
    }, holder)
    create("UICorner", {
        CornerRadius = UDim.new(1, 0)
    }, thumb)

    loadPlayerThumbnail(thumb, fallback, userId, cardObj)
    return holder
end

do
    local container = GUI.Cards.HidePlayer.Container

    createPropertyToggleRow(container, "Player", "Visibility", "Hide Other Players Locally", 1, "HidePlayers", function(value)
        State.HideEnabled = value
        State.Toggles.HidePlayers = value
        PV.ApplyAll()
        Selector.RefreshStatus()
    end)

    createPropertyCheckboxRow(container, "Player", "Visibility", "Hide Player Names", 2, "HidePlayerNames", function(value)
        State.Toggles.HidePlayerNames = value
        PV.ApplyAll()
        Selector.RefreshStatus()
    end)

    createPropertyCheckboxRow(container, "Player", "Visibility", "Hide Player Accessories", 3, "HidePlayerAccessories", function(value)
        State.Toggles.HidePlayerAccessories = value
        PV.ApplyAll()
        Selector.RefreshStatus()
    end)

    createPropertyCheckboxRow(container, "Player", "Visibility", "Hide Player Effects", 4, "HidePlayerEffects", function(value)
        State.Toggles.HidePlayerEffects = value
        PV.ApplyAll()
        Selector.RefreshStatus()
    end)

    local refreshRow = createPropertyActionRow(container, "Player", "Management", "Refresh Players", 5, "Refresh", nil, nil)
    GUI.RefreshButton = refreshRow

    local showAllRow = createPropertyActionRow(container, "Player", "Management", "Show All Players", 6, "Reset", nil, nil)
    GUI.ShowAllButton = showAllRow

    local playerDropdownWrapper = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.InspectorRow,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = 7
    }, container)
    listLayout(playerDropdownWrapper, 0)

    local dropdownBtn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 23),
        BackgroundColor3 = Theme.InspectorRow,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ClipsDescendants = true,
        LayoutOrder = 1
    }, playerDropdownWrapper)
    makeDivider(dropdownBtn, 2)
    makeColumnDivider(dropdownBtn, LABEL_COLUMN_RATIO, 2)
    bindHover(dropdownBtn, Theme.InspectorRow, Theme.Hover, Theme.Press)

    makeLabel(dropdownBtn, "Player List", {
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(LABEL_COLUMN_RATIO, -20, 1, 0),
        Font = Enum.Font.BuilderSans,
        TextSize = 11,
        TextColor3 = Theme.PrimaryText,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    GUI.ExcludeSummary = makeLabel(dropdownBtn, "0 Excluded", {
        Position = UDim2.new(LABEL_COLUMN_RATIO, 8, 0, 0),
        Size = UDim2.new(1 - LABEL_COLUMN_RATIO, -26, 1, 0),
        TextSize = 11,
        Font = Enum.Font.BuilderSansMedium,
        TextColor3 = Theme.MutedText,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local listArrow = create("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(11, 11),
        BackgroundTransparency = 1,
        Image = Icon.Expand,
        ImageColor3 = Theme.MutedText
    }, dropdownBtn)

    local playerListClip = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        LayoutOrder = 2
    }, playerDropdownWrapper)

    local playerListInner = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, playerListClip)
    listLayout(playerListInner, 0)

    local searchRowWrap = create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        LayoutOrder = 1
    }, playerListInner)
    makeDivider(searchRowWrap, 2, 20)

    local searchHolder = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -12, 0, 20),
        BackgroundColor3 = Theme.SecondarySurface,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, searchRowWrap)
    corner(searchHolder, 2)
    local searchStroke = stroke(searchHolder, Theme.Border, true)

    create("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 6, 0.5, 0),
        Size = UDim2.fromOffset(11, 11),
        BackgroundTransparency = 1,
        Image = Icon.Search,
        ImageColor3 = Theme.MutedText
    }, searchHolder)

    GUI.PlayerSearch = create("TextBox", {
        Position = UDim2.fromOffset(21, 0),
        Size = UDim2.new(1, -38, 1, 0),
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = Enum.Font.BuilderSans,
        PlaceholderText = "Search player...",
        PlaceholderColor3 = Theme.MutedText,
        Text = "",
        TextColor3 = Theme.PrimaryText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true
    }, searchHolder)

    local clearBtn = create("ImageButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.fromOffset(11, 11),
        BackgroundTransparency = 1,
        Image = Icon.Close,
        ImageColor3 = Theme.MutedText,
        Visible = false,
        AutoButtonColor = false
    }, searchHolder)

    GUI.PlayerSearch.Focused:Connect(function()
        searchStroke.Color = Theme.SearchFocusBorder
    end)

    GUI.PlayerSearch.FocusLost:Connect(function()
        searchStroke.Color = Theme.Border
    end)

    clearBtn.MouseButton1Click:Connect(function()
        GUI.PlayerSearch.Text = ""
    end)

    GUI.ExcludeClearBtn = clearBtn

    local playerListContainer = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = 2
    }, playerListInner)
    listLayout(playerListContainer, 0)
    GUI.PlayerList = playerListContainer

    GUI.EmptyPlayersLabel = makeLabel(playerListContainer, "No other players in server", {
        Size = UDim2.new(1, 0, 0, 26),
        TextColor3 = Theme.MutedText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false,
        LayoutOrder = 9999
    })

    local playerDropdownOpen = false
    local playerDropdownToken = 0

    local function setPlayerListExpanded(open)
        playerDropdownOpen = open and true or false
        playerDropdownToken = playerDropdownToken + 1
        local currentToken = playerDropdownToken
        listArrow.Image = playerDropdownOpen and Icon.Collapse or Icon.Expand

        if playerDropdownOpen then
            playerListClip.Visible = true
            local targetH = playerListInner.AbsoluteSize.Y
            if targetH <= 0 then
                targetH = 52
            end
            playerListClip.AutomaticSize = Enum.AutomaticSize.None
            local t = tween(playerListClip, 0.15, {Size = UDim2.new(1, 0, 0, targetH)})
            t.Completed:Connect(function(playbackState)
                if playbackState == Enum.PlaybackState.Completed and currentToken == playerDropdownToken and playerDropdownOpen and playerListClip.Parent then
                    playerListClip.AutomaticSize = Enum.AutomaticSize.Y
                    playerListClip.Size = UDim2.new(1, 0, 0, 0)
                end
            end)
        else
            local currentH = playerListClip.AbsoluteSize.Y
            playerListClip.AutomaticSize = Enum.AutomaticSize.None
            playerListClip.Size = UDim2.new(1, 0, 0, currentH)
            local t = tween(playerListClip, 0.15, {Size = UDim2.new(1, 0, 0, 0)})
            t.Completed:Connect(function(playbackState)
                if playbackState == Enum.PlaybackState.Completed and currentToken == playerDropdownToken and not playerDropdownOpen and playerListClip.Parent then
                    playerListClip.Visible = false
                end
            end)
        end
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        setPlayerListExpanded(not playerDropdownOpen)
    end)

    registerSearchEntry("Player", playerDropdownWrapper, "player list exclusion exclude", "Management")
end

Selector.Cards = {}

local function getVisibilityStatusText(userId)
    if State.Excluded[userId] then
        return "Excluded"
    elseif State.HideEnabled then
        return "Hidden"
    elseif State.Toggles.HidePlayerNames or State.Toggles.HidePlayerAccessories or State.Toggles.HidePlayerEffects then
        return "Partial Hide"
    else
        return "Visible"
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
        GUI.ExcludeSummary.Text = tostring(total) .. " Excluded"
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
    if updateMainScroll then
        updateMainScroll()
    end
end

GUI.PlayerSearch:GetPropertyChangedSignal("Text"):Connect(Selector.ApplyFilter)

function PlayerCard.CreateCard(player, order)
    local userId = player.UserId

    local card = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.PlayerCard,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ClipsDescendants = true,
        LayoutOrder = order
    }, GUI.PlayerList)
    makeDivider(card, 2)
    bindHover(card, Theme.PlayerCard, Theme.Hover, Theme.Press)

    local object = {
        UserId = userId,
        Alive = true,
        Frame = card,
        Display = string.lower(player.DisplayName),
        Username = string.lower(player.Name),
        RawDisplay = player.DisplayName
    }

    createCircularThumbnail(card, userId, player.DisplayName, object)

    makeLabel(card, player.DisplayName, {
        Position = UDim2.fromOffset(40, 4),
        Size = UDim2.new(1, -72, 0, 14),
        Font = Enum.Font.BuilderSansMedium,
        TextColor3 = Theme.PrimaryText,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local subLbl = makeLabel(card, "@" .. player.Name, {
        Position = UDim2.fromOffset(40, 18),
        Size = UDim2.new(1, -72, 0, 13),
        Font = Enum.Font.BuilderSans,
        TextColor3 = Theme.MutedText,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local checkbox = createCheckbox(card, State.Excluded[userId] == true, function()
        Exclusion.Toggle(userId)
    end)

    function object.Update()
        local excluded = State.Excluded[userId] == true
        checkbox:Set(excluded, true)
        local statusText = getVisibilityStatusText(userId)
        subLbl.Text = "@" .. player.Name .. "  " .. statusText
        subLbl.TextColor3 = excluded and Theme.CheckHover or Theme.MutedText
    end

    card.MouseButton1Click:Connect(function()
        Exclusion.Toggle(userId)
    end)

    object.Update()
    return object
end

local function updateCardSortAndEmptyState()
    local sorted = {}
    for _, card in pairs(Selector.Cards) do
        sorted[#sorted + 1] = card
    end
    table.sort(sorted, function(a, b)
        if a.Display == b.Display then
            return a.UserId < b.UserId
        end
        return a.Display < b.Display
    end)
    for index, card in ipairs(sorted) do
        if card.Frame and card.Frame.Parent then
            card.Frame.LayoutOrder = index
        end
    end
    if GUI.EmptyPlayersLabel and GUI.EmptyPlayersLabel.Parent then
        GUI.EmptyPlayersLabel.Visible = (#sorted == 0)
    end
end

function Selector.AddPlayer(player)
    if not player or player == LocalPlayer or not GUI.PlayerList or not GUI.PlayerList.Parent then
        return
    end
    local userId = player.UserId
    if Selector.Cards[userId] then
        Selector.Cards[userId].Update()
    else
        Selector.Cards[userId] = PlayerCard.CreateCard(player, 1)
    end
    updateCardSortAndEmptyState()
    Selector.ApplyFilter()
    Selector.UpdateCount()
    if GUI.UpdatePlayerCount then
        GUI.UpdatePlayerCount()
    end
end

function Selector.RemovePlayer(userId)
    local card = Selector.Cards[userId]
    if card then
        card.Alive = false
        Selector.Cards[userId] = nil
        if card.Frame and card.Frame.Parent then
            cancelTween(card.Frame)
            card.Frame:Destroy()
        end
    end
    updateCardSortAndEmptyState()
    Selector.ApplyFilter()
    Selector.UpdateCount()
    if GUI.UpdatePlayerCount then
        GUI.UpdatePlayerCount()
    end
end

function Selector.Refresh()
    if not GUI.PlayerList or not GUI.PlayerList.Parent then
        return
    end

    local present = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            present[player.UserId] = player
        end
    end

    for userId, card in pairs(Selector.Cards) do
        if not present[userId] then
            card.Alive = false
            Selector.Cards[userId] = nil
            if card.Frame and card.Frame.Parent then
                cancelTween(card.Frame)
                card.Frame:Destroy()
            end
        end
    end

    for userId, player in pairs(present) do
        if Selector.Cards[userId] then
            Selector.Cards[userId].Update()
        else
            Selector.Cards[userId] = PlayerCard.CreateCard(player, 1)
        end
    end

    updateCardSortAndEmptyState()
    Selector.ApplyFilter()
    Selector.UpdateCount()
    if GUI.UpdatePlayerCount then
        GUI.UpdatePlayerCount()
    end
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

local function applyMainSearchFilter()
    closeActiveDropdownPopup()
    local raw = GUI.SearchBox and GUI.SearchBox.Text or ""
    local query = string.lower(string.gsub(raw, "^%s*(.-)%s*$", "%1"))

    if GUI.SearchClearBtn then
        GUI.SearchClearBtn.Visible = raw ~= ""
    end

    if query == "" then
        for _, entry in ipairs(GUI.SearchEntries) do
            if entry.Frame and entry.Frame.Parent then
                entry.Frame.Visible = true
            end
        end
        for _, sub in pairs(GUI.Subsections) do
            if sub.Frame and sub.Frame.Parent then
                sub.Frame.Visible = true
            end
        end
        for _, cardObj in pairs(GUI.Cards) do
            if cardObj.Card and cardObj.Card.Parent then
                cardObj.Card.Visible = true
                cardObj:SetExpanded(cardObj.UserExpanded, false, false)
            end
        end
        if GUI.EmptySearchLabel then
            GUI.EmptySearchLabel.Visible = false
        end
        if updateMainScroll then
            updateMainScroll()
        end
        return
    end

    local sectionHasMatch = {
        Server = false,
        Performance = false,
        Player = false
    }
    local subHasMatch = {}

    for _, entry in ipairs(GUI.SearchEntries) do
        local matched = string.find(entry.SearchText, query, 1, true) ~= nil
        if entry.Frame and entry.Frame.Parent then
            entry.Frame.Visible = matched
        end
        if matched then
            sectionHasMatch[entry.Section] = true
            if entry.Subsection then
                subHasMatch[entry.Section .. ":" .. entry.Subsection] = true
            end
        end
    end

    for key, sub in pairs(GUI.Subsections) do
        if sub.Frame and sub.Frame.Parent then
            sub.Frame.Visible = subHasMatch[key] == true
        end
    end

    local sectionMap = {
        Server = GUI.Cards.Server,
        Performance = GUI.Cards.AntiLag,
        Player = GUI.Cards.HidePlayer
    }

    local anyVisible = false
    for secName, cardObj in pairs(sectionMap) do
        if cardObj and cardObj.Card and cardObj.Card.Parent then
            local has = sectionHasMatch[secName] == true
            cardObj.Card.Visible = has
            if has then
                anyVisible = true
                cardObj:SetExpanded(true, false, false)
            end
        end
    end

    if GUI.EmptySearchLabel then
        GUI.EmptySearchLabel.Visible = not anyVisible
    end
    if updateMainScroll then
        updateMainScroll()
    end
end

GUI.SearchBox:GetPropertyChangedSignal("Text"):Connect(applyMainSearchFilter)

local Layout = {
    Minimized = false,
    LastHeight = initialHeight
}

local MinSize = Vector2.new(240, 140)

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
GUI.Main:GetPropertyChangedSignal("Size"):Connect(function()
    syncResizeOverlay()
    if ActiveDropdownPopup then
        closeActiveDropdownPopup()
    end
end)

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
        cancelTween(handle)
        handle.BackgroundTransparency = 0.2
    end
end

local function endPointer()
    if Pointer.Handle and Pointer.Handle.Parent then
        cancelTween(Pointer.Handle)
        Pointer.Handle.BackgroundTransparency = 1
    end
    for _, handle in pairs(GUI.Resize) do
        if handle and handle.Parent then
            cancelTween(handle)
            handle.BackgroundTransparency = 1
        end
    end
    Pointer.Mode = nil
    Pointer.Edge = nil
    Pointer.Handle = nil
    Pointer.ActiveInput = nil
end

local minimizeToken = 0

local function setMinimized(value)
    if value == Layout.Minimized then
        return
    end
    Layout.Minimized = value
    minimizeToken = minimizeToken + 1
    local currentToken = minimizeToken

    if Pointer.Mode == "Resize" then
        endPointer()
    end

    if value then
        closeActiveDropdownPopup()
        Layout.LastHeight = GUI.Main.Size.Y.Offset
        GUI.Toolbar.Visible = false
        GUI.Content.Visible = false
        GUI.ResizeOverlay.Visible = false
        for _, handle in pairs(GUI.Resize) do
            handle.Active = false
            handle.Visible = false
            handle.BackgroundTransparency = 1
        end
        GUI.MinimizeIcon.Image = Icon.Maximize
        tween(GUI.Main, 0.16, {Size = UDim2.fromOffset(GUI.Main.Size.X.Offset, headerHeight)})
    else
        GUI.Toolbar.Visible = true
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
        local t = tween(GUI.Main, 0.16, {
            Size = UDim2.fromOffset(GUI.Main.Size.X.Offset, targetHeight),
            Position = UDim2.fromOffset(GUI.Main.Position.X.Offset, clampedY)
        })
        t.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed and currentToken == minimizeToken and not Layout.Minimized then
                syncResizeOverlay()
                if updateMainScroll then
                    updateMainScroll()
                end
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

local function handlePointerMove(input)
    if not Pointer.Mode then
        return
    end
    if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
        if input.UserInputType ~= Enum.UserInputType.Touch or not Pointer.ActiveInput or Pointer.ActiveInput == input then
            endPointer()
        end
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
        local x = math.clamp(math.floor(startX + delta.X + 0.5), 0, maxX)
        local y = math.clamp(math.floor(startY + delta.Y + 0.5), 0, maxY)
        GUI.Main.Position = UDim2.fromOffset(x, y)
        return
    end

    if Layout.Minimized then
        return
    end

    local startW = Pointer.StartSize.X
    local startH = Pointer.StartSize.Y
    local posX = startX
    local posY = startY
    local width = startW
    local height = startH

    if Pointer.Edge == "Right" then
        local maxW = math.max(MinSize.X, bounds.X - startX)
        width = math.clamp(math.floor(startW + delta.X + 0.5), MinSize.X, maxW)
    elseif Pointer.Edge == "Left" then
        local rightEdge = startX + startW
        local clampedX = math.clamp(math.floor(startX + delta.X + 0.5), 0, math.max(0, rightEdge - MinSize.X))
        posX = clampedX
        width = rightEdge - clampedX
    elseif Pointer.Edge == "Bottom" then
        local maxH = math.max(MinSize.Y, bounds.Y - startY)
        height = math.clamp(math.floor(startH + delta.Y + 0.5), MinSize.Y, maxH)
    elseif Pointer.Edge == "Top" then
        local bottomEdge = startY + startH
        local clampedY = math.clamp(math.floor(startY + delta.Y + 0.5), 0, math.max(0, bottomEdge - MinSize.Y))
        posY = clampedY
        height = bottomEdge - clampedY
    end

    GUI.Main.Position = UDim2.fromOffset(posX, posY)
    GUI.Main.Size = UDim2.fromOffset(width, height)
    Layout.LastHeight = height
end

connect(UserInputService.InputChanged, handlePointerMove)

pcall(function()
    connect(UserInputService.TouchMoved, handlePointerMove)
end)

connect(UserInputService.InputEnded, function(input)
    if not Pointer.Mode then
        return
    end
    if input.UserInputType == Enum.UserInputType.Touch then
        if not Pointer.ActiveInput or Pointer.ActiveInput == input then
            endPointer()
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        endPointer()
    end
end)

pcall(function()
    connect(UserInputService.TouchEnded, function(input)
        if Pointer.Mode and (not Pointer.ActiveInput or Pointer.ActiveInput == input) then
            endPointer()
        end
    end)
end)

pcall(function()
    connect(UserInputService.WindowFocusReleased, function()
        if Pointer.Mode then
            endPointer()
        end
    end)
end)

local function createResizeHandle(edge, position, size)
    local handle = create("TextButton", {
        Position = position,
        Size = size,
        BackgroundColor3 = Theme.ResizeActive,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Selectable = false,
        Active = true,
        ZIndex = 105
    }, GUI.ResizeOverlay)

    handle.MouseEnter:Connect(function()
        if not Pointer.Mode and not Layout.Minimized and not isTouchOnlyInput(nil) then
            tween(handle, 0.10, {BackgroundTransparency = 0.55})
        end
    end)

    handle.MouseLeave:Connect(function()
        if Pointer.Handle ~= handle then
            cancelTween(handle)
            handle.BackgroundTransparency = 1
        end
    end)

    handle.InputBegan:Connect(function(input)
        if isPointerPress(input) and not Layout.Minimized then
            beginPointer("Resize", input, edge, handle)
        end
    end)

    handle.InputEnded:Connect(function(input)
        if Pointer.Handle == handle and isPointerPress(input) then
            endPointer()
        elseif Pointer.Handle ~= handle then
            cancelTween(handle)
            handle.BackgroundTransparency = 1
        end
    end)

    GUI.Resize[edge] = handle
    return handle
end

createResizeHandle("Left", UDim2.new(0, -5, 0, 0), UDim2.new(0, 5, 1, 0))
createResizeHandle("Top", UDim2.new(0, 0, 0, -5), UDim2.new(1, 0, 0, 5))
createResizeHandle("Right", UDim2.new(1, 0, 0, 0), UDim2.new(0, 5, 1, 0))
createResizeHandle("Bottom", UDim2.new(0, 0, 1, 0), UDim2.new(1, 0, 0, 5))

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

    if GUI.RestoreButtonLabel and GUI.RestoreButtonLabel.Parent then
        GUI.RestoreButtonLabel.Text = "Restoring..."
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

        if GUI.RestoreButtonLabel and GUI.RestoreButtonLabel.Parent then
            GUI.RestoreButtonLabel.Text = "Reset all to Default"
        end
        Selector.RefreshStatus()
    end)
end

local isClosing = false

local function runFullShutdownRestore()
    State.Restoring = true
    State.Reset()
    PV.ApplyGeneration = PV.ApplyGeneration + 1

    AntiLag.StopWatch()
    AutoRefresh.StopAll()
    PV.ReleaseWatchers()

    Engine.Queue = {}
    Engine.QueuedSet = {}
    for _, source in ipairs(CategorySources) do
        Engine.Generation[source] = (Engine.Generation[source] or 0) + 1
        Tracker.Reset(source)
    end

    local sources = {}
    for source in pairs(Storage.Index) do
        sources[#sources + 1] = source
    end

    task.spawn(function()
        for _, source in ipairs(sources) do
            Storage.EnqueueRelease(source)
        end

        local deadline = os.clock() + 45
        while (Storage.ReleaseWorkerRunning or #Storage.ReleaseQueue > 0 or next(Storage.Releasing) ~= nil) and os.clock() < deadline do
            yieldFrame()
        end

        local remaining = {}
        for instance, props in pairs(Storage.Data) do
            if isAlive(instance) then
                for _, record in pairs(props) do
                    remaining[#remaining + 1] = record
                end
            end
        end

        local sliceStart = os.clock()
        for idx, record in ipairs(remaining) do
            if isAlive(record.Instance) then
                pcall(writeProperty, record.Instance, record.Property, record.Original)
            end
            if idx % 180 == 0 or (os.clock() - sliceStart) >= 0.005 then
                yieldFrame()
                sliceStart = os.clock()
            end
        end

        Tracker.ResetAll()
        Storage.Data = {}
        Storage.Index = {}
        Storage.Permanent = {}
        State.Restoring = false
    end)
end

local function cleanupGuiObjects()
    for userId, card in pairs(Selector.Cards) do
        card.Alive = false
        Selector.Cards[userId] = nil
    end

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
    GUI.SearchEntries = {}
    GUI.Subsections = {}
    GUI.UpdatePlayerCount = nil
    GUI.DropdownPopup = nil
    GUI.DropdownBackdrop = nil
    GUI.DropdownLayer = nil
    GUI.RestoreButtonLabel = nil
    GUI.Shadow = nil
end

function Core.Shutdown(animateClose)
    if not Core.Running then
        return
    end
    if animateClose and isClosing then
        return
    end
    Core.Running = false

    closeActiveDropdownPopup()
    endPointer()
    cancelAllTweens()
    disconnectList(Core.Connections)

    if genv and type(genv.__PerformanceManager) == "table" and genv.__PerformanceManager.Shutdown == Core.Shutdown then
        genv.__PerformanceManager = nil
    end

    runFullShutdownRestore()

    if animateClose and GUI.Main and GUI.Main.Parent then
        isClosing = true
        if GUI.ResizeOverlay and GUI.ResizeOverlay.Parent then
            GUI.ResizeOverlay.Visible = false
        end
        for _, handle in pairs(GUI.Resize) do
            if handle and handle.Parent then
                handle.Active = false
                handle.Visible = false
                handle.BackgroundTransparency = 1
            end
        end

        local currentWidth = GUI.Main.AbsoluteSize.X
        if currentWidth <= 0 then
            currentWidth = GUI.Main.Size.X.Offset
        end
        local currentHeight = GUI.Main.AbsoluteSize.Y
        if currentHeight <= 0 then
            currentHeight = GUI.Main.Size.Y.Offset
        end

        GUI.Main.ClipsDescendants = true
        GUI.Main.Size = UDim2.fromOffset(currentWidth, currentHeight)

        if GUI.Shadow and GUI.Shadow.Parent then
            pcall(function()
                tween(GUI.Shadow, 0.14, {Transparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end)
        end

        local finished = false
        local function finishClose()
            if finished then
                return
            end
            finished = true
            cancelAllTweens()
            cleanupGuiObjects()
        end

        local wipeTween = tween(GUI.Main, 0.18, {Size = UDim2.fromOffset(currentWidth, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        wipeTween.Completed:Connect(finishClose)
        task.delay(0.24, finishClose)
    else
        cleanupGuiObjects()
    end
end

GUI.RestoreButton.MouseButton1Click:Connect(Core.RestoreAll)
GUI.CloseButton.MouseButton1Click:Connect(function()
    Core.Shutdown(true)
end)

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
