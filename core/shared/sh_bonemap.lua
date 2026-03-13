api.bonemap = {}

local boneIdToGroup = {}

-- Rebuild lookup table for O(1) performance
CreateThread(function()
    while not config.boneGroups do Wait(100) end
    for groupName, group in pairs(config.boneGroups) do
        for _, id in ipairs(group.bones) do
            boneIdToGroup[id] = groupName
        end
    end
end)

-- Get bone group from bone ID
function api.bonemap.getGroupFromBone(boneId)
    return boneIdToGroup[boneId]
end

-- Get bone group from component ID
function api.bonemap.getGroupFromComponent(componentId)
    return config.componentToGroup and config.componentToGroup[componentId] or nil
end

-- Get all bones for a group
function api.bonemap.getBonesForGroup(groupName)
    local group = config.boneGroups and config.boneGroups[groupName]
    return group and group.bones or nil
end

-- Get all bone groups
function api.bonemap.getAllGroups()
    local groups = {}
    if config.boneGroups then
        for name in pairs(config.boneGroups) do
            table.insert(groups, name)
        end
    end
    return groups
end

-- Get human-readable bone group name
function api.bonemap.getGroupDescription(groupName)
    local group = config.boneGroups and config.boneGroups[groupName]
    return group and group.description or 'Unknown'
end

-- Get bone group with fallback logic
function api.bonemap.getGroupWithFallback(boneOrComponentId, isComponent)
    local group = isComponent and api.bonemap.getGroupFromComponent(boneOrComponentId) or api.bonemap.getGroupFromBone(boneOrComponentId)
    if group then return group end
    
    if config.debug.code then
        _debug(('[Weapon Framework] Unknown %s ID: %d (defaulting to torso)'):format(
            isComponent and 'component' or 'bone', boneOrComponentId
        ))
    end
    
    return 'torso'
end

return api.bonemap
