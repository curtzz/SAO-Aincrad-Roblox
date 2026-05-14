# Handoff — SAO Floor 1 (Roblox Studio) — Session 2

## 1. Goal

Build a Sword Art Online–themed Roblox game starting with **Floor 1**
(Town of Beginnings → West Field → Tolbana → Labyrinth → Boss Arena).
All gameplay systems are prototyped on gray-block maps first; art swapped in later.

Build order — **ALL COMPLETE for Floor 1:**

1. ✅ Mob Spawner
2. ✅ XP / Leveling
3. ✅ Healing Crystal
4. ✅ Inventory + Col with persistence (DataStore)
5. ✅ NPC Shop
6. ✅ Zone Teleporters → redesigned as single Teleport Gate per floor
7. ✅ NPC Dialogue (Diavel / Kirito story beats)
8. ✅ Boss Room Trigger (door locks on entry, unlocks when Illfang dies)
9. ✅ Illfang Boss AI (two-phase, comprehensive combat system)

---

## 2. Repository

- **Repo:** `curtzz/SAO-Aincrad-Roblox`
- **Branch:** `claude/new-session-imkIl`
- All 32 scripts are committed and pushed on that branch.

### File map (src/ → Roblox Studio location)

```
src/
├── ReplicatedStorage/
│   ├── Modules/
│   │   ├── PlayerStats.lua          → ReplicatedStorage/Modules/PlayerStats       (ModuleScript)
│   │   ├── ZoneRegistry.lua         → ReplicatedStorage/Modules/ZoneRegistry      (ModuleScript)
│   │   ├── ShopCatalog.lua          → ReplicatedStorage/Modules/ShopCatalog       (ModuleScript)
│   │   ├── SwordSkills.lua          → ReplicatedStorage/Modules/SwordSkills       (ModuleScript)
│   │   └── DialogueRegistry.lua     → ReplicatedStorage/Modules/DialogueRegistry  (ModuleScript)
│   └── RemoteSetup.server.lua       → ReplicatedStorage/RemoteSetup               (Script)
│
├── ServerScriptService/
│   ├── MapBuilder.server.lua        → ServerScriptService/MapBuilder              (Script)
│   ├── PlayerLifecycle.server.lua   → ServerScriptService/PlayerLifecycle         (Script)
│   ├── LevelHandler.server.lua      → ServerScriptService/LevelHandler            (Script)
│   ├── MobSpawner.server.lua        → ServerScriptService/MobSpawner              (Script)
│   ├── CombatHandler.server.lua     → ServerScriptService/CombatHandler           (Script)
│   ├── NPCBuilder.server.lua        → ServerScriptService/NPCBuilder              (Script)
│   ├── GateBuilder.server.lua       → ServerScriptService/GateBuilder             (Script)
│   ├── GateHandler.server.lua       → ServerScriptService/GateHandler             (Script)
│   ├── ShopHandler.server.lua       → ServerScriptService/ShopHandler             (Script)
│   ├── ShopPromptBinder.server.lua  → ServerScriptService/ShopPromptBinder        (Script)
│   ├── DialoguePromptBinder.server.lua → ServerScriptService/DialoguePromptBinder (Script)
│   ├── DiscardHandler.server.lua    → ServerScriptService/DiscardHandler          (Script)
│   ├── CrystalHandler.server.lua    → ServerScriptService/CrystalHandler          (Script)
│   └── BossRoomTrigger.server.lua   → ServerScriptService/BossRoomTrigger         (Script)
│
├── StarterPlayer/
│   ├── StarterPlayerScripts/
│   │   ├── HPGUI.client.lua         → StarterPlayerScripts/HPGUI                 (LocalScript)
│   │   ├── SkillController.client.lua → StarterPlayerScripts/SkillController      (LocalScript)
│   │   ├── MenuController.client.lua  → StarterPlayerScripts/MenuController       (LocalScript)
│   │   ├── LevelUpNotifier.client.lua → StarterPlayerScripts/LevelUpNotifier      (LocalScript)
│   │   ├── ToolCountBadge.client.lua  → StarterPlayerScripts/ToolCountBadge       (LocalScript)
│   │   ├── ShopController.client.lua  → StarterPlayerScripts/ShopController       (LocalScript)
│   │   ├── GateController.client.lua  → StarterPlayerScripts/GateController       (LocalScript)
│   │   └── DialogueUI.client.lua      → StarterPlayerScripts/DialogueUI           (LocalScript)
│   └── StarterPack/
│       ├── AnnealBlade/
│       │   └── SwordCombat.client.lua → StarterPack/AnnealBlade/SwordCombat       (LocalScript inside Tool)
│       └── HealingCrystal/
│           └── CrystalLogic.client.lua → StarterPack/HealingCrystal/CrystalLogic  (LocalScript inside Tool)
│
└── Workspace/
    └── IllfangBoss/
        ├── BossAI.server.lua        → Workspace/IllfangBoss/BossAI               (Script)
        └── BossHealthBar.server.lua → Workspace/IllfangBoss/BossHealthBar         (Script)
```

---

## 3. System Summaries

### PlayerStats (ReplicatedStorage/Modules/PlayerStats)
Full DataStore API. Key: `PlayerStats_v2`. Auto-save every 180s with `_dirty` flag.
Default profile: `Level=1, XP=0, MaxHP=100, CurrentHP=100, Col=0, Inventory={}, UnlockedFloors={Floor1=true}, StoryFlags={}`.
API: `Load / Save / Unload / Get / AddItem / RemoveItem / AddCol / SpendCol / SetLevel / SetXP / UnlockFloor / GetUnlockedFloors / SetFlag / GetFlag`.
**Always use `PlayerStats.Get(player)` — never reach into internal tables directly.**

### ZoneRegistry (ReplicatedStorage/Modules/ZoneRegistry)
Floor-based (not zone-based). Floor1 defined with SpawnPosition `(0,5,0)`, GatePosition `(0,0,-30)`.
Add Floor2 entry here before boss unlocks it, or the gate menu will have nothing to show.

### RemoteEvents (created by RemoteSetup)
All live under `ReplicatedStorage.Remotes`:
`OpenShop, BuyItem, BuyResult, ActivateSkill, BasicAttack, LevelUp, OpenGateMenu, RequestTeleport, ZoneUnlocked, DiscardItem, OpenDialogue, AdvanceDialogue, UseHealingCrystal`

### MapBuilder
Builds `Floor1Map` folder in Workspace with 5 sub-folders: Town, Field, Tolbana, Labyrinth, BossArena.
Town at Z=0, Field Z=200, Tolbana Z=420, Labyrinth Z=500–700, BossArena Z=800.
The `(string.gsub)` parenthesis fix is already applied — all 5 zones build.

### MobSpawner
Spawns Frenzy Boars at 8 `SpawnMarker` parts in Field. 30s respawn. 25 XP + 15 Col on kill (via GiveXPEvent BindableEvent in ServerScriptService).

### LevelHandler
XP curve: `level × 100` XP per level. HP curve: `100 + (level-1) × 15`. Creates `GiveXPEvent` BindableEvent. Handles death + 5s respawn.

### CombatHandler
Server-validates `BasicAttack` (12 dmg, 0.45s CD) and `ActivateSkill` remotes. Safe-zone check prevents combat in Town and Tolbana.

### PlayerLifecycle
Loads/saves PlayerStats on join/leave. Force-teleports character to `(0,5,0)` on every CharacterAdded — players always respawn at Town.

### NPCBuilder
Builds 8 NPCs in `Workspace/ShopNPCs`:
- Story NPCs (Diavel, Kirito, Town Guard, Townsfolk) — get `DialogueId` attribute + DialoguePrompt
- Shop NPCs (Item Shop, Weapon Shop, Armor Shop, Inn) — get `ShopId` attribute

Raycast origin Y+5 so NPCs stand on stall floor, not roof.

### GateBuilder / GateHandler / GateController
One stone-arch gate per floor at `GatePosition`. Touching the cyan portal opens the floor menu.
Only unlocked floors appear. Current floor shows `(here)`, others show `TELEPORT →`.
Currently only Floor 1 exists so the button never appears — **this is intentional, not a bug**.

### ShopHandler / ShopPromptBinder / ShopController
ProximityPrompt on shop NPCs → fires `OpenShop` → client shows modal → `BuyItem` → server validates Col → `BuyResult`.

### DialogueRegistry / DialoguePromptBinder / DialogueUI
4 NPCs have dialogue: Diavel (with choice: join raid / maybe later), Kirito, GuardNPC, TownNPC.
Choices fire `AdvanceDialogue` to server → `PlayerStats.SetFlag` persists story state.
Portrait images are `rbxassetid://0` placeholders — swap with real asset IDs later.

### BossRoomTrigger
Invisible trigger at Z=750. First player to touch it locks the door (solid black part).
On `IllfangBoss.Humanoid.Died`: unlocks door, gives all players within 200 studs of arena center 500 XP + 300 Col, calls `UnlockFloor("Floor2")`, fires `ZoneUnlocked`.

### BossAI (Illfang the Kobold Lord)
Spawns at `(0, 6, 800)`. 2000 HP. Two-phase fight.

**Phase 1 (Talwar):** WalkSpeed 14, Strike 30 dmg/1.8s, Charge (rush + 25 dmg knockback/10s), Ground Slam (AOE 45 dmg + knockback, 16s, red floor indicator warning).

**Phase 2 (Nodachi) at 500 HP (25%):** 2.5s transition, body recolors red, weapon turns orange. WalkSpeed 22, Strike 55 dmg/1.1s (+ splash nearby), Charge 40 dmg/8s, Slam 70 dmg/12s, Cleave sweep (AOE 45 dmg/6s), Berserk triple-hit (3×40 dmg/22s).

**Leash:** Boss fully resets HP and phase if all players flee past 110 studs.
**Announcements:** Set via `boss:SetAttribute("BossMessage", msg)` — BossHealthBar displays them.

### BossHealthBar
BillboardGui above boss. Shows: Floor 1 Boss title, Phase I/II label, HP bar with tweened fill, HP numbers, announcement text row that fades out. Watches `Phase` and `BossMessage` attributes set by BossAI.

---

## 4. Known Watch-outs

- **`PlayerStats.Get` is the only safe accessor.** Any script that reaches into the internal `profiles` table directly will silently return nil.
- **Gate "TELEPORT →" never appears yet** — Floor 2 doesn't exist in ZoneRegistry. Don't mistake for a bug.
- **Boss spawns at `(0,6,800)`** — inside BossArena. Old scripts had it at `(-180,6,380)` in the Field; that's been fixed.
- **`GiveXPEvent`** is a BindableEvent created by LevelHandler at runtime in ServerScriptService. MobSpawner and BossRoomTrigger find it by name — LevelHandler must run first (it will, scripts run in order).
- **IllfangBoss model** must exist in Workspace with a `Humanoid` and `HumanoidRootPart` for BossAI and BossHealthBar to work. BossRoomTrigger polls for it every 3 seconds so it can be added after game start.
- **Portrait images** in DialogueRegistry are all `rbxassetid://0` — replace with real Decal asset IDs when art is ready.
- **AnnealBlade and HealingCrystal** are Tools in StarterPack. Each needs its LocalScript child. The Tool object itself (with Handle part) must be created manually in Studio.
- **DataStore** only works in live Roblox games, not in Studio by default. Enable "Allow Studio Access to API Services" in Game Settings → Security to test saving/loading in Studio.

---

## 5. What's Next

### Immediate — Test in Studio
1. Press F5. Confirm:
   - Map builds (5 zones visible)
   - Gate appears at Town (Z=-30), touching it opens menu showing "Floor 1 — Town of Beginnings (here)"
   - Frenzy Boars spawn in Field and chase players
   - Diavel/Kirito dialogue works (Talk prompt, typewriter text, choice buttons)
   - HP bar shows bottom-left, M key opens menu
   - Entering labyrinth north exit (Z≈750) locks the boss door
   - IllfangBoss two-phase fight works in arena

### Floor 2 Scaffolding (next major feature)
1. Add `Floor2` entry to `ZoneRegistry.Floors` with a new `SpawnPosition` and `GatePosition`
2. Build a second map zone in MapBuilder (or a separate MapBuilder2 script)
3. Place a Floor 2 gate model
4. When Illfang dies, `UnlockFloor("Floor2")` already fires — the gate menu will then show Floor 2 automatically

### Polish Pass
- Replace `rbxassetid://0` portrait placeholders in DialogueRegistry with real Decal IDs
- Give AnnealBlade a proper mesh/Handle in Studio
- Add particle effects to HealingCrystal use (currently code-only VFX)
- Add more Tolbana dialogue NPCs for the raid briefing scene
- Enrage timer on Illfang (optional): after X minutes, permanently increase damage

### Longer Term
- Floor 2 boss (The Gleam Eyes)
- Sword skill animations (currently hitbox-only, no visual swing)
- Player-to-player trading
- Party system for raid coordination

---

## 6. Switching to Local Development

To move this project from Claude Code web to your local machine:

**Step 1 — Install Claude Code CLI**
```
npm install -g @anthropic-ai/claude-code
```
Requires Node.js 18+. Works on Windows, Mac, Linux.

**Step 2 — Clone the repo**
```
git clone https://github.com/curtzz/SAO-Aincrad-Roblox.git
cd SAO-Aincrad-Roblox
git checkout claude/new-session-imkIl
```

**Step 3 — Run Claude Code locally**
```
claude
```
It will ask you to log in with your Anthropic account on first run.

**Step 4 — Upload this HANDOFF.md to start the new session**
Drag this file into the Claude Code chat (or reference it with `@HANDOFF.md`) so the new session has full context.

The local version has full git push access (uses your own GitHub credentials) so the 403 push errors from this session won't happen.
