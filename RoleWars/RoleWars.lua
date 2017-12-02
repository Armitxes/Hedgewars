----------------------------------
--  Hedgewars: The Role Wars    --
--  by armitxes (armitxes.net)  --
----------------------------------

-- Note: This is my first LUA Script ;) sorry for any mistakes

--  Roles  --
-- All: Skip turn, Green Nade
-- Pyromaniac: FirePunch, Flamethrower, Molotov, HellishBomb, Napalm
-- Miner: Jackhammer, Blow Torch, Drill, Dynamite, Drillrain
-- Joker: Seduce, Hammer, SineGun, Tardis, Ball-Cannon, Cake
-- Minemaster: Push (Mudball), [Normal, Floating & Sticky Mines], Duck, Minerain (immune to mine damage)
-- Alchemist: Ice Gun, Cheese, Birdy, Low Gravity, Revive (50hp), Melon
-- Solider: Red Nade, Revolver (DE), Shotgun, Sniper, Bazooka, Mortar, Missile Rain, (Special: Plane)
-- Survivor: Whip, Hook, Parachute, Extra Time, Shotgun, Cleaver, Bee (Special: Can build)
-- Not in game: Piano, Suicide

HedgewarsScriptLoad("/Scripts/Params.lua")
HedgewarsScriptLoad("/Scripts/Tracker.lua")


---------- VARS ----------
local cfgRoles = {
    ['Pyromaniac']={ [amFirePunch]=1, [amFlamethrower]=1, [amMolotov]=2, [amHellishBomb]=4, [amNapalm]=5 },
    ['Miner']={ [amPickHammer]=1, [amBlowTorch]=1, [amDrill]=3, [amBallgun]=4, [amDynamite]=5, [amDrillStrike]=5 },
    ['Joker']={ [amSeduction]=1, [amHammer]=1, [amSineGun]=2, [amTardis]=4, [amBallgun]=4, [amCake]=5 },
    ['Minemaster']={ [amGirder]=0,[amMine]=1,[amAirMine]=1,[amDuck]=1,[amSMine]=3, [amMineStrike]=4 },
    ['Alchemist']={ [amIceGun]=0, [amLowGravity]=0, [amGasBomb]=1, [amResurrector]=3, [amBirdy]=3, [amWatermelon]=5},
    ['Solider']={ [amClusterBomb]=0, [amDEagle]=1, [amSniperRifle]=1, [amShotgun]=2, [amBazooka]=2, [amMortar]=2, [amAirAttack]=4 },
    ['Survivor']={ [amWhip]=1, [amRope]=1, [amParachute]=1, [amExtraTime]=1, [amShotgun]=2, [amBee]=3, [amRubber]=1, [amKnife]=2 }
}
local getRoleById = {
    [0]='Pyromaniac', [1]='Miner', [2]='Joker',
    [3]='Minemaster', [4]='Alchemist', [5]='Solider',
    [6]='Survivor'
}
local hogRoles = {}
local hogRoles2 = {}
local hogMana = {}
local hogTurns = {}

---------- FUNCTIONS ----------
function onGameInit() 
    DisableGameFlags(gfInfAttack)
    EnableGameFlags(gfResetWeps)
    Goals = "Pick a role. Defeat the enemies."
end

function onAmmoStoreInit()
    -- Allow skip at all times
    SetAmmo(amSkip, 9, 0, 0, 0)
    SetAmmo(amGrenade, 9, 0, 0, 0)
    SetAmmo(amGirder, 9, 0, 0, 0)

    -- Let utilities be available through crates
    SetAmmo(amParachute, 0, 1, 0, 1)
    SetAmmo(amGirder, 0, 1, 0, 2)
    SetAmmo(amSwitch, 0, 1, 0, 1)
    SetAmmo(amLowGravity, 0, 1, 0, 1)
    SetAmmo(amExtraDamage, 0, 1, 0, 1)
    SetAmmo(amInvulnerable, 0, 1, 0, 1)
    SetAmmo(amExtraTime, 0, 1, 0, 1)
    SetAmmo(amLaserSight, 0, 1, 0, 1)
    SetAmmo(amVampiric, 0, 1, 0, 1)
    SetAmmo(amJetpack, 0, 1, 0, 1)
    SetAmmo(amPortalGun, 0, 1, 0, 1)
    SetAmmo(amResurrector, 0, 1, 0, 1)
end

function onNewTurn()
    local cHog = CurrentHedgehog;

    if hogRoles[cHog] == null then
        TurnTimeLeft = TurnTimeLeft + 15

        r1 = GetRandom(6)
        r2 = GetRandom(6)

        if r1 == r2 and r2 > 0 then
            r2 = r2 - 1
        else
            r2 = r2 + 1
        end

        hogMana[cHog] = 0
        hogTurns[cHog] = 0
        hogRoles[cHog] = getRoleById[r1]
        hogRoles2[cHog] = getRoleById[r2]

        HogSay(cHog, "Guess I'm becoming a " .. hogRoles[cHog], SAY_THINK)
    end

    AddCaption(GetHogName(cHog) .. " the " .. hogRoles[cHog], 0xFF0000FF, capgrpGameState)
    hogMana[cHog] = hogMana[cHog] + 2
    hogTurns[cHog] = hogTurns[cHog] + 1

    addRoleWeapons(cHog)
end

function onUsedAmmo(ammo)
    local cHog = CurrentHedgehog

    if ammo == amTeleport then
        hogMana[cHog] = hogMana[cHog] - 6
    elseif ammo ~= amSkip and ammo ~= amGrenade then
        weapons = TableConcat(cfgRoles[hogRoles[cHog]], cfgRoles[hogRoles2[cHog]])
        hogMana[cHog] = hogMana[cHog] - weapons[ammo]
    end
end

function addRoleWeapons(hog)
    local cfgRole = cfgRoles[hogRoles[hog]]
    local roleText = hogRoles[hog]

    if hogTurns[hog] > 6 then
        cfgRole = TableConcat(cfgRole, cfgRoles[hogRoles2[hog]])
        roleText = hogRoles[hog] .. " & " .. hogRoles2[hog]
    end

    HogSay(hog, roleText .. ", Mana: " .. hogMana[hog], SAY_THINK)

    for weapon,cost in pairs(cfgRole) do
        if hogMana[hog] >= cost then
            AddAmmo(hog, weapon, 1)
        end
    end

    if hogMana[hog] > 6 then
        AddAmmo(hog, amTeleport, 1)
    end
end

function TableConcat(t1,t2)
    for index,value in pairs(t2) do
        t1[index] = value
    end
    return t1
end
