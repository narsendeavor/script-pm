<p align="center">
  <img src="https://files.catbox.moe/u035uy.jpeg" width="100%" alt="Performance Manager Preview">
</p>

<h1 align="center">Performance Manager</h1>

<p align="center">
  A standalone Luau client-side utility for Roblox, combining graphics optimization, rendering control, local player visibility management, and server navigation tools.
</p>

---

## Features

### Server Management
- **Place Preview** — Displays the current game's thumbnail and automatically retrieves its place name.
- **Rejoin** — Reconnects to the current server instance or teleports back to the current place.
- **Server Hop** — Finds and joins a random available public server, excluding the current server.
- **Small Server** — Searches for an available public server with the lowest player count.
- **Two-Step Confirmation** — Requires a second click within 3 seconds before executing server actions.
- **Teleport Status** — Provides feedback when searching, rejoining, teleporting, or encountering failures.

### Anti Lag

**Graphics Presets**
- **Default** — Restores the default graphics configuration.
- **Balanced** — Applies moderate graphics reductions.
- **Performance** — Applies stronger rendering and visual optimizations.
- **Ultra Performance** — Applies maximum available visual reductions.
- **Custom** — Automatically selected when individual settings are manually adjusted.

**Visual Manager**
- Enable Anti Lag
- Reduce Visual Effects
- Particle Visibility (Full, Reduced, Hidden)
- Shadow Settings
- Lighting Settings
- Light Sources
- Character Effects
- Weather Effects
- Environmental Effects
- Texture Effects
- Low Graphics

**Rendering Manager**
- SpecialMesh Optimization
- MeshPart Performance LOD
- Hide Decorative Meshes
- Texture Quality (Default, Reduced, Minimal)
- Texture & SurfaceAppearance
- MaterialVariant Strip
- Hide Decals
- Particle Density (100%, 50%, 25%, 0%)
- Transparency Control (Default, Simplify, Hide)
- Disable Local Effects
- Terrain Decoration Off
- Terrain Water Effects Off
- Terrain Grass Decoration Off
- Clouds Off
- Reflectance Off
- CastShadow Off

**Optimization & Restoration**
- Restore Default
- Individual rendering and visual setting controls
- Restores previously recorded instance properties when optimizations are disabled or reset.

### Hide Player

**Player Visibility**
- **Hide Other Players Locally** — Hides other players' characters locally.
- **Hide Player Names** — Hides player name displays.
- **Hide Player Accessories** — Hides other players' accessories.
- **Hide Player Effects** — Hides player highlights and particle effects.

**Player Management**
- **Refresh Players** — Refreshes the player list.
- **Show All Players** — Disables player-hiding options and restores player visibility.
- **Player Search** — Searches players by display name or username.
- **Player Exclusion** — Excludes selected players from visibility modifications.
- **Player Headshots** — Displays circular player profile thumbnails with initials fallback.
- **Visibility Status** — Displays each player's current visibility and exclusion status.
- **Automatic Player Tracking** — Updates the player list when players join, leave, or respawn.

---

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/narsendeavor/script-pm/refs/heads/main/pm.lua"))()
```
