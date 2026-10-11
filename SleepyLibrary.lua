local YabujinDeobfuscated = {}

-- ============================================================================
-- PART 1: Yabujin Client (Roblox Rivals) Core Functions & Hooks
-- CORREGIDO AL MÁXIMO (sintaxis + estructura, sin cambiar lógica ni contenido)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Function [22]: runWithElevatedThreadIdentity
-- ----------------------------------------------------------------------------
do
    local setthreadidentity, pcall, getthreadidentity
    YabujinDeobfuscated.runWithElevatedThreadIdentity = function(b, ...)
        if not setthreadidentity then
            return pcall(b, ...)
        end
        local J
        pcall(function()
            J = getthreadidentity and (getthreadidentity())
        end)
        pcall(setthreadidentity, 8)
        local N = {pcall(b, ...)}
        if not N[1] and type(N[2]) == "string" and (N[2]:find("lacking capability", 1, true)) then
            local A = {7, 6, 3}
            for _, q in ipairs(A) do
                pcall(setthreadidentity, q)
                N = {pcall(b, ...)}
                if N[1] then
                    break
                end
                if type(N[2]) ~= "string" or not N[2]:find("lacking capability", 1, true) then
                    break
                end
            end
        end
        if J ~= nil then
            pcall(setthreadidentity, J)
        end
        return table.unpack(N)
    end
end

-- ----------------------------------------------------------------------------
-- Function [125]: runSafeQueueWorker
-- ----------------------------------------------------------------------------
do
    local setthreadidentity, pcall, spoofConfig
    YabujinDeobfuscated.runSafeQueueWorker = function()
        while true do
            if setthreadidentity then
                pcall(setthreadidentity, 8)
            end
            while #spoofConfig._safeQueue > 0 do
                local b = table.remove(spoofConfig._safeQueue, 1)
                if b then
                    spoofConfig._withId(b)
                end
            end
            task.wait()
        end
    end
end

-- ----------------------------------------------------------------------------
-- Function [55]: getRealUserId
-- ----------------------------------------------------------------------------
do
    local LocalPlayer, localOriginalUserId, spoofConfig
    YabujinDeobfuscated.getRealUserId = function(b)
        if b == LocalPlayer then
            return localOriginalUserId
        end
        local J = spoofConfig.RealUserIdMap
        if J and J[b] then
            return J[b]
        end
        if typeof(b) == "Instance" and (b:IsA("Player")) then
            return b.UserId
        end
        return 0
    end
end

-- ----------------------------------------------------------------------------
-- Function [42]: getOriginalPlayerName
-- ----------------------------------------------------------------------------
do
    local LocalPlayer, localOriginalName, spoofConfig
    YabujinDeobfuscated.getOriginalPlayerName = function(b)
        if b == LocalPlayer then
            return localOriginalName
        end
        local J = spoofConfig.OtherPlayerOriginals
        if J and J[b] and J[b].Name then
            return J[b].Name
        end
        return b.Name
    end
end

-- ----------------------------------------------------------------------------
-- Function [108]: getSpoofedPlayerNames
-- ----------------------------------------------------------------------------
do
    local LocalPlayer, spoofConfig, getRealUserId, getYabujinSpoofField
    YabujinDeobfuscated.getSpoofedPlayerNames = function(b)
        if not b then
            return nil, nil
        end
        if b == LocalPlayer then
            if not spoofConfig.UsernameSpoof then
                return nil, nil
            end
            local J, N = spoofConfig.SpoofedName, spoofConfig.SpoofedDisplayName
            local A = J and J ~= "" and J or nil
            return A, N and N ~= "" and N or A
        end
        local J = getRealUserId(b)
        b = yabujinUsers[J] or yabujinUsers[tostring(J)]
        if b and b.spoofer and (next(b.spoofer)) then
            local b = getYabujinSpoofField(J, "Username")
            if not b or type(b) ~= "table" then
                return nil, nil
            end
            local J = b.name and b.name ~= "" and b.name or nil
            return J, b.displayName and b.displayName ~= "" and b.displayName or J
        end
        if spoofConfig.AnonymousMode then
            return spoofConfig.AnonName or "Roblox", spoofConfig.AnonDisplayName or "Roblox"
        end
        return nil, nil
    end
end

-- ----------------------------------------------------------------------------
-- Function [91]: applyLocalPlayerIdentitySpoof
-- ----------------------------------------------------------------------------
do
    local spoofConfig, origPlayerName, LocalPlayer, pcall, origDisplayName, origUserId
    YabujinDeobfuscated.applyLocalPlayerIdentitySpoof = function()
        local b = nil
        if spoofConfig.UsernameSpoof then
            local J = spoofConfig.SpoofedName
            b = J and J ~= "" and J or origPlayerName
        else
            b = origPlayerName
        end
        local J = b ~= LocalPlayer.Name
        if J then
            pcall(function()
                local N = spoofConfig._findPlayersFrame and (spoofConfig._findPlayersFrame())
                if N then
                    local A = N:FindFirstChild("PlayerLabel" .. LocalPlayer.Name)
                    if A then
                        A:Destroy()
                    end
                end
            end)
        end
        pcall(function()
            LocalPlayer.Name = b
        end)
        if spoofConfig.UsernameSpoof then
            local b, N = spoofConfig.SpoofedDisplayName, spoofConfig.SpoofedName
            if b and b ~= "" then
                pcall(function()
                    LocalPlayer.DisplayName = b
                end)
            elseif N and N ~= "" then
                pcall(function()
                    LocalPlayer.DisplayName = N
                end)
            else
                pcall(function()
                    LocalPlayer.DisplayName = origDisplayName
                end)
            end
        else
            pcall(function()
                LocalPlayer.DisplayName = origDisplayName
            end)
        end
        if not J then
            pcall(function()
                local b = spoofConfig._findPlayersFrame and (spoofConfig._findPlayersFrame())
                if b then
                    local J = b:FindFirstChild("PlayerLabel" .. LocalPlayer.Name)
                    if J then
                        local b = J:FindFirstChild("DisplayNameLabel")
                        if b then
                            b.Text = LocalPlayer.DisplayName
                        end
                    end
                end
            end)
        end
        spoofConfig._withId(function()
            if spoofConfig.AvatarSpoof and spoofConfig.AvatarUserId and spoofConfig.AvatarUserId ~= 0 then
                LocalPlayer.UserId = spoofConfig.AvatarUserId
            else
                LocalPlayer.UserId = origUserId
            end
        end)
    end
end

-- ----------------------------------------------------------------------------
-- Function [99]: hookGetPlayerByUserId
-- ----------------------------------------------------------------------------
do
    local spoofConfig, localOriginalUserId, origGetPlayerByUserId, localSpoofTargetId
    YabujinDeobfuscated.hookGetPlayerByUserId = function(b, J)
        if spoofConfig.AvatarSpoof and spoofConfig.AvatarUserId then
            if type(J) == "number" and (J == spoofConfig.AvatarUserId or J == localOriginalUserId) then
                return origGetPlayerByUserId(b, localSpoofTargetId)
            end
        end
        local N = origGetPlayerByUserId(b, J)
        if not N and type(J) == "number" and spoofConfig.RealUserIdMap then
            for A, q in pairs(spoofConfig.RealUserIdMap) do
                if q == J then
                    local J = origGetPlayerByUserId(b, A)
                    if J then
                        return J
                    end
                end
            end
        end
        return N
    end
end

-- ----------------------------------------------------------------------------
-- Function [1]: hookPlayerGetAttribute
-- ----------------------------------------------------------------------------
do
    local getRealUserId, getYabujinSpoofField, spoofConfig, origGetAttribute
    YabujinDeobfuscated.hookPlayerGetAttribute = function(b, J)
        if typeof(b) == "Instance" and (b:IsA("Player")) then
            local N = getRealUserId(b)
            if yabujinUsers[N] and yabujinUsers[N].spoofer then
                if J == "StatisticDuelsWinStreak" then
                    local A = getYabujinSpoofField(N, "Streak")
                    if A then
                        return A
                    end
                elseif J == "DisplayELO" then
                    local A = getYabujinSpoofField(N, "ELO")
                    if A then
                        return A
                    end
                elseif J == "DisplayELOLeaderboardRanking" then
                    local A = getYabujinSpoofField(N, "LeaderboardRank")
                    if A then
                        return A
                    end
                elseif J == "Level" then
                    local A = getYabujinSpoofField(N, "Level")
                    if A then
                        return A
                    end
                elseif J == "PlayerStatus" then
                    local A = getYabujinSpoofField(N, "Pass")
                    if A and type(A) == "number" and A > 1 then
                        if A == 2 then
                            return "Prime"
                        elseif A == 3 then
                            return "Contraband"
                        end
                    end
                end
            end
        end
        if spoofConfig.AnonymousMode then
            local N = getRealUserId(b)
            if not (yabujinUsers[N] and yabujinUsers[N].spoofer) then
                if J == "StatisticDuelsWinStreak" and spoofConfig.AnonStreak then
                    return spoofConfig.AnonStreak
                end
                if J == "DisplayELO" and spoofConfig.AnonELO then
                    return spoofConfig.AnonELO
                end
                if J == "Level" and spoofConfig.AnonLevel then
                    return spoofConfig.AnonLevel
                end
                if J == "DisplayELOLeaderboardRanking" then
                    return 0
                end
            end
        end
        return origGetAttribute(b, J)
    end
end

-- ----------------------------------------------------------------------------
-- Function [8]: hookNametagDisplayName
-- ----------------------------------------------------------------------------
do
    local LocalPlayer, getRealUserId, getSpoofedPlayerNames, spoofConfig, origNametagFunc
    YabujinDeobfuscated.hookNametagDisplayName = function(b, J, N, A)
        if J and J ~= LocalPlayer then
            local q = getRealUserId(J)
            local W = yabujinUsers[q] or yabujinUsers[tostring(q)]
            if W and W.spoofer and (next(W.spoofer)) then
                local q, q = getSpoofedPlayerNames(J)
                N = if q and q ~= "" then q else N
            elseif spoofConfig.AnonymousMode then
                return origNametagFunc(b, J, spoofConfig.AnonDisplayName or "Roblox", A)
            end
        end
        return origNametagFunc(b, J, if J == LocalPlayer and spoofConfig.UsernameSpoof then spoofConfig.SpoofedDisplayName ~= "" and spoofConfig.SpoofedDisplayName or (spoofConfig.SpoofedName ~= "" and spoofConfig.SpoofedName or J.DisplayName) else N, A)
    end
end

print("[Yabujin] Parte 1 corregida al máximo (sintaxis + estructura)")
return YabujinDeobfuscated
