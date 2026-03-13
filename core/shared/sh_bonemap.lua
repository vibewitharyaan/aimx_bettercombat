bonemap = {}

local boneGroups = {
    head = {
        name = 'head',
        description = 'Head and facial bones',
        bones = {
            31086, -- SKEL_Head
            39317, -- SKEL_Neck_1 (left)
            57597, -- SKEL_Neck_2 (right)
            65068, -- FB_R_Brow_Out_000
            12844, -- FACIAL_facialRoot
        }
    },
    torso = {
        name = 'torso',
        description = 'Spine, chest, pelvis',
        bones = {
            23553, -- SKEL_Pelvis
            24816, -- SKEL_Spine_Root
            24817, -- SKEL_Spine0
            24818, -- SKEL_Spine1
            11816, -- SKEL_Spine2 (thorax)
            57005, -- SKEL_Spine3
            14201, -- SKEL_Spine4 (upper chest)
            10706, -- SKEL_L_Clavicle
            64729, -- SKEL_R_Clavicle
        }
    },
    legs = {
        name = 'legs',
        description = 'Thighs, calves, feet',
        bones = {
            51826, -- SKEL_L_Thigh
            58271, -- SKEL_L_Calf
            14201, -- SKEL_L_Foot
            2108,  -- SKEL_L_Toe0
            58271, -- SKEL_R_Thigh
            36864, -- SKEL_R_Calf
            52301, -- SKEL_R_Foot
            14656, -- SKEL_R_Toe0
        }
    },
    arms = {
        name = 'arms',
        description = 'Upper arms, forearms, hands',
        bones = {
            45509, -- SKEL_L_UpperArm
            61163, -- SKEL_L_Forearm
            18905, -- SKEL_L_Hand
            26610, -- SKEL_L_Finger00 (thumb)
            4089,  -- SKEL_L_Finger10 (index)
            4137,  -- SKEL_L_Finger20 (middle)
            26294, -- SKEL_L_Finger30 (ring)
            58866, -- SKEL_L_Finger40 (pinky)
            40269, -- SKEL_R_UpperArm
            28252, -- SKEL_R_Forearm
            57005, -- SKEL_R_Hand
            58867, -- SKEL_R_Finger00 (thumb)
            64016, -- SKEL_R_Finger10 (index)
            64017, -- SKEL_R_Finger20 (middle)
            64064, -- SKEL_R_Finger30 (ring)
            64065, -- SKEL_R_Finger40 (pinky)
        }
    },
}

local componentToGroup = {
    [0] = 'head',
    [31086] = 'head',
    [39317] = 'head',
    [57597] = 'head',
    [23553] = 'torso',
    [24816] = 'torso',
    [24817] = 'torso',
    [24818] = 'torso',
    [11816] = 'torso',
    [57005] = 'torso',
    [14201] = 'torso',
    [51826] = 'legs',
    [58271] = 'legs',
    [14201] = 'legs',
    [36864] = 'legs',
    [52301] = 'legs',
    [45509] = 'arms',
    [61163] = 'arms',
    [18905] = 'arms',
    [40269] = 'arms',
    [28252] = 'arms',
    [57005] = 'arms',
}

local boneIdToGroup = {}
for groupName, group in pairs(boneGroups) do
    for _, boneId in ipairs(group.bones) do
        boneIdToGroup[boneId] = groupName
    end
end

-- Get bone group from bone ID
function bonemap.getGroupFromBone(boneId)
    return boneIdToGroup[boneId]
end

-- Get bone group from component ID
function bonemap.getGroupFromComponent(componentId)
    return componentToGroup[componentId]
end

-- Get all bones for a group
function bonemap.getBonesForGroup(groupName)
    local group = boneGroups[groupName]
    return group and group.bones or nil
end

-- Get all bone groups
function bonemap.getAllGroups()
    local groups = {}
    for name in pairs(boneGroups) do
        table.insert(groups, name)
    end
    return groups
end

-- Register custom bone group
function bonemap.registerGroup(name, bones, description)
    if boneGroups[name] then
        error(('Bone group "%s" already exists'):format(name))
    end

    boneGroups[name] = {
        name = name,
        description = description or '',
        bones = bones
    }

    for _, boneId in ipairs(bones) do
        boneIdToGroup[boneId] = name
    end

    if config.debug.code then
        _debug(('[Weapon Framework] Registered bone group: %s (%d bones)'):format(name, #bones))
    end
end

-- Map component ID to bone group
function bonemap.mapComponent(componentId, groupName)
    if not boneGroups[groupName] then
        error(('Bone group "%s" does not exist'):format(groupName))
    end

    componentToGroup[componentId] = groupName

    if config.debug.code then
        _debug(('[Weapon Framework] Mapped component %d -> %s'):format(componentId, groupName))
    end
end

-- Get human-readable bone group name
function bonemap.getGroupDescription(groupName)
    local group = boneGroups[groupName]
    return group and group.description or 'Unknown'
end

-- Check if bone ID exists in any group
function bonemap.isValidBone(boneId)
    return boneIdToGroup[boneId] ~= nil
end

-- Check if component ID exists in mapping
function bonemap.isValidComponent(componentId)
    return componentToGroup[componentId] ~= nil
end

-- Get bone group with fallback logic
function bonemap.getGroupWithFallback(boneOrComponentId, isComponent)
    local group = isComponent and bonemap.getGroupFromComponent(boneOrComponentId) or
    bonemap.getGroupFromBone(boneOrComponentId)

    if group then return group end

    if config.debug.code then
        _debug(('[Weapon Framework] Unknown %s ID: %d (defaulting to torso)'):format(
            isComponent and 'component' or 'bone', boneOrComponentId
        ))
    end

    return 'torso'
end

-- Print all bone mappings
if config.debug.code then
    function bonemap.printMappings()
        _debug('=== BONE GROUP MAPPINGS ===')
        for groupName, group in pairs(boneGroups) do
            _debug(('Group: %s (%s)'):format(groupName, group.description))
            _debug(('  Bones: %s'):format(table.concat(group.bones, ', ')))
        end

        _debug('\n=== COMPONENT MAPPINGS ===')
        for componentId, groupName in pairs(componentToGroup) do
            _debug(('Component %d -> %s'):format(componentId, groupName))
        end
    end
end

return bonemap
