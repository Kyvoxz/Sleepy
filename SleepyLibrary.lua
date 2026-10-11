local YabujinDeobfuscated = {}

-- ============================================================================
-- PART 1: Yabujin Client (Roblox Rivals) Core Functions & Hooks  (CORREGIDO)
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
            J = getthreadidentity and getthreadidentity()
        end)

        pcall(setthreadidentity, 8)
        local N = {pcall(b, ...)}

        if not N[1] and type(N[2]) == "string" and N[2]:find("lacking capability", 1, true) then
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

        if typeof(b) == "Instance" and b:IsA("Player") then
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
            local A = (J and J ~= "") and J or nil
            return A, (N and N ~= "") and N or A
        end

        local realId = getRealUserId(b)
        local userData = yabujinUsers[realId] or yabujinUsers[tostring(realId)]

        if userData and userData.spoofer and next(userData.spoofer) then
            local spoofData = getYabujinSpoofField(realId, "Username")
            if not spoofData or type(spoofData) ~= "table" then
                return nil, nil
            end

            local name = (spoofData.name and spoofData.name ~= "") and spoofData.name or nil
            return name, (spoofData.displayName and spoofData.displayName ~= "") and spoofData.displayName or name
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
        local newName = nil

        if spoofConfig.UsernameSpoof then
            local J = spoofConfig.SpoofedName
            newName = (J and J ~= "") and J or origPlayerName
        else
            newName = origPlayerName
        end

        local nameChanged = newName ~= LocalPlayer.Name

        if nameChanged then
            pcall(function()
                local playersFrame = spoofConfig._findPlayersFrame and spoofConfig._findPlayersFrame()
                if playersFrame then
                    local label = playersFrame:FindFirstChild("PlayerLabel" .. LocalPlayer.Name)
                    if label then
                        label:Destroy()
                    end
                end
            end)
        end

        pcall(function()
            LocalPlayer.Name = newName
        end)

        if spoofConfig.UsernameSpoof then
            local display, name = spoofConfig.SpoofedDisplayName, spoofConfig.SpoofedName
            if display and display ~= "" then
                pcall(function()
                    LocalPlayer.DisplayName = display
                end)
            elseif name and name ~= "" then
                pcall(function()
                    LocalPlayer.DisplayName = name
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

        if not nameChanged then
            pcall(function()
                local playersFrame = spoofConfig._findPlayersFrame and spoofConfig._findPlayersFrame()
                if playersFrame then
                    local label = playersFrame:FindFirstChild("PlayerLabel" .. LocalPlayer.Name)
                    if label then
                        local displayLabel = label:FindFirstChild("DisplayNameLabel")
                        if displayLabel then
                            displayLabel.Text = LocalPlayer.DisplayName
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

    YabujinDeobfuscated.hookGetPlayerByUserId = function(self, userId)
        if spoofConfig.AvatarSpoof and spoofConfig.AvatarUserId then
            if type(userId) == "number" and (userId == spoofConfig.AvatarUserId or userId == localOriginalUserId) then
                return origGetPlayerByUserId(self, localSpoofTargetId)
            end
        end

        local player = origGetPlayerByUserId(self, userId)

        if not player and type(userId) == "number" and spoofConfig.RealUserIdMap then
            for realId, mappedId in pairs(spoofConfig.RealUserIdMap) do
                if mappedId == userId then
                    local found = origGetPlayerByUserId(self, realId)
                    if found then
                        return found
                    end
                end
            end
        end

        return player
    end
end

print("[Yabujin] Core functions corregidas cargadas")
return YabujinDeobfuscated
