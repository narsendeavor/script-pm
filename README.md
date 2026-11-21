
<p align="center">
  <img src="https://files.catbox.moe/whjibo.jpeg" width="100%" alt="Performance Manager">
</p>

<h1 align="center">Performance Manager</h1>

<p align="center">
  A standalone Luau utility for Roblox focused on performance optimization, visual control, player visibility, and server management.
</p>

---

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/narsendeavor/script-pm/refs/heads/main/performancemanager.lua"))()
```

## Infinite Yield Plugin Command

**Command:** `pm / performance`

```lua
-- Performance Manage Server
-- https://github.com/narsendeavor/script-pm

local Plugin = {
    ["PluginName"] = "Performance Manager",
    ["PluginDescription"] = "Roblox performance optimization, anti-lag, visual effects management, player visibility controls, and server utilities.",
    ["Commands"] = {
        ["pm"] = {
            ["ListName"] = "pm / performance",
            ["Description"] = "Loads Performance Manager.",
            ["Aliases"] = {"performance"},
            ["Function"] = function(args, speaker)
                local success, err = pcall(function()
                    loadstring(game:HttpGet(
                        "https://raw.githubusercontent.com/narsendeavor/script-pm/refs/heads/main/performancemanager.lua"
                    ))()
                end)
                
                if success then
                    notify(
                        "Performance Manager",
                        "Loaded Performance Manager Server"
                    )
                else
                    warn("[Performance Manager] " .. tostring(err))
                end
            end
        }
    }
}

return Plugin
```

## Features

**Performance**
- Graphics presets: Default, Balanced, Performance, Ultra Performance, Custom
- Visual Manager: particles, shadows, lighting, light sources, weather, environment, textures, low graphics
- Rendering Manager: SpecialMesh, MeshPart LOD, decals, texture quality, particle density, transparency, terrain, clouds, reflectance, cast shadow

**Player**
- Hide players, names, accessories, and effects
- Exclusion list and auto refresh

**Server**
- Rejoin, Server Hop, Small Server

**Other**
- Search settings, resizable and minimizable window, reset all to default

---

<p align="center">Create by NarsEdv - Version 0.1</p>
