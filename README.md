# MORON FISH IT - Professional Edition v2.0.0

## Overview

**Moron Fish It** is a professional-grade automation script for the Roblox game **Fish It!** (Place ID: 121864768012064). The script features a premium custom-built UI with sidebar navigation, clean categorization, and smooth animations. It is designed to be lightweight, user-friendly, and undetectable.

**No Script Key** | **No HWID Lock** | **Free Forever** | **Works on Any Device**

---

## How to Use

Copy and paste the following into your executor and run:

```lua
loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()
```

Or paste the entire script directly into your executor.

**Toggle UI:** Press `Right Shift` to show/hide the interface.

---

## Features Overview

### Fishing (7 tabs organized by category)

| Feature | Description | Risk Level |
|---------|-------------|------------|
| Auto Fish | Automatically casts and catches fish in a loop | Low |
| Blatant Mode | Parallel rod casting for 2x speed | Moderate |
| Instant Mode | Maximum speed with triple casting | High |
| Auto Catch | Background reel spam for extra catch speed | Low |
| Fish Delay | Adjustable delay between casts (0.1 - 5.0s) | - |
| Catch Delay | Adjustable delay for catching (0.1 - 3.0s) | - |
| Auto Enchant | Enchant your rod automatically | Low |
| Auto Buy Best Rod | Purchase the best affordable rod | Low |
| Auto Buy Weather | Buy weather changes for rare fish | Low |
| Auto Quest | Accept and complete quests automatically | Low |
| Auto Event | Teleport to active events (Megalodon, Worm) | Low |
| Auto Artifact | Find and collect artifacts on the map | Low |

### Selling

| Feature | Description |
|---------|-------------|
| Auto Sell | Sell fish at configurable intervals (protects favorites) |
| Sell Interval | Adjustable timer 10 - 300 seconds |
| Sell All Now | Instant sell button |
| Auto Favorite | Automatically favorite rare fish |
| Minimum Rarity | Choose: Legendary, Mythic, or Secret |
| Favorite All Rare Now | Scan and favorite all rare fish instantly |

### Teleport

| Category | Locations |
|----------|-----------|
| Islands | Spawn, Sisyphus Statue, Coral Reefs, Esoteric Depths, Crater Island, Lost Isle, Weather Machine, Tropical Grove, Mount Hallow, Treasure Room, Kohana, Underground Cellar, Ancient Jungle, Sacred Temple, Crystal Cavern, Underwater City, Forgotten Shore |
| NPCs | Rod Shop, Sell NPC, Enchant NPC, Quest NPC, Weather NPC, Boat Shop |

### Movement

| Feature | Description |
|---------|-------------|
| Walk Speed | Adjustable 16 - 200 |
| Jump Power | Adjustable 50 - 300 |
| Infinite Jump | Jump unlimited times in the air |
| Fly | Fly freely with WASD + Space/Shift |
| Noclip | Pass through walls and solid objects |

### Utility

| Feature | Description |
|---------|-------------|
| Anti-AFK | Prevent being kicked for inactivity |
| Anti-Drown | Automatically resurface when drowning |
| GPU Saver | Minimize graphics for AFK farming |
| FPS Boost | Remove particles and effects for performance |
| Server Hop | Join a different server with fewer players |
| Rejoin Server | Reconnect to the current server |

### Visuals

| Feature | Description |
|---------|-------------|
| Fish ESP | Floating labels on fish in the world |
| Player ESP | Player names with distance indicators |

### Settings

| Feature | Description |
|---------|-------------|
| Discord Webhook | Send rare catch notifications to Discord |
| Save/Load Config | Persistent settings per user |
| Reset to Default | One-click reset |
| Session Statistics | Live player name, catch count, session time |

---

## Anti-Detection System

The script implements multiple layers of anti-detection:

- **Randomized Delays**: All timings use random variation (0.82x - 1.18x) to appear human-like
- **Deferred Remote Firing**: Uses `task.defer` and `pcall` wrapping for silent execution
- **Smooth Teleportation**: Multi-step lerped teleports for distances over 400 studs
- **Rate-Limited Selling**: Random intervals around the configured sell timer
- **Background Processing**: All automation runs in separate coroutines
- **Natural Patterns**: No fixed timing patterns that anti-cheat can detect

---

## UI Design

- **Custom-built lightweight UI** (no heavy libraries like Rayfield)
- **Sidebar navigation** with color-coded category icons
- **Dark theme** with accent colors per category
- **Smooth toggle animations** with sliding knobs
- **Draggable window** from sidebar or header
- **Minimize button** to collapse to logo only
- **Right Shift hotkey** to toggle visibility
- **Scrollable pages** with proper padding and spacing
- **Professional typography** using Gotham font family

---

## Color Coding

| Category | Color | Purpose |
|----------|-------|---------|
| Fishing | Green (#00BE82) | Primary automation |
| Selling | Yellow (#FFB900) | Economy features |
| Teleport | Blue (#4678FF) | Navigation |
| Movement | Purple (#9650FF) | Character control |
| Utility | Green (#00BE82) | System tools |
| Visuals | Blue (#4678FF) | ESP overlays |
| Settings | Gray (#78788D) | Configuration |

---

## Compatibility

- Works with all major Roblox executors (Synapse X, Fluxus, KRNL, Delta, Arceus X, etc.)
- Mobile and PC compatible
- No external dependencies required
- Config saves per user ID

---

## Version History

| Version | Changes |
|---------|---------|
| v2.0.0 | Complete rebuild with premium UI, anti-detection, all features |

---

*Moron Fish It - Professional Edition*
