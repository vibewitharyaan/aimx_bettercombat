-- ============================================================================
-- WEAPON FRAMEWORK - BONE CLASSIFICATION SYSTEM
-- ============================================================================
-- Maps bone IDs and component IDs to logical bone groups
-- Extensible architecture for future granularity (fingers, hands, etc.)
-- ============================================================================

bonemap = {}

-- ============================================================================
-- BONE GROUP DEFINITIONS
-- ============================================================================
-- Current groups: head, torso, legs, arms
-- Future expansion: hands, fingers, feet, neck, etc.
-- ============================================================================

---@class BoneGroup
---@field name string
---@field description string
---@field bones number[] Array of bone IDs

local boneGroups = {
    head = {
        name = 'head',
        description = 'Head and facial bones',
        bones = {
            31086,  -- SKEL_Head
            39317,  -- SKEL_Neck_1 (left)
            57597,  -- SKEL_Neck_2 (right)
            65068,  -- FB_R_Brow_Out_000
            12844,  -- FACIAL_facialRoot
        }
    },
    
    torso = {
        name = 'torso',
        description = 'Spine, chest, pelvis',
        bones = {
            23553,  -- SKEL_Pelvis
            24816,  -- SKEL_Spine_Root
            24817,  -- SKEL_Spine0
            24818,  -- SKEL_Spine1
            11816,  -- SKEL_Spine2 (thorax)
            57005,  -- SKEL_Spine3
            14201,  -- SKEL_Spine4 (upper chest)
            10706,  -- SKEL_L_Clavicle
            64729,  -- SKEL_R_Clavicle
        }
    },
    
    legs = {
        name = 'legs',
        description = 'Thighs, calves, feet',
        bones = {
            -- Left leg
            51826,  -- SKEL_L_Thigh
            58271,  -- SKEL_L_Calf
            14201,  -- SKEL_L_Foot
            2108,   -- SKEL_L_Toe0
            
            -- Right leg
            58271,  -- SKEL_R_Thigh
            36864,  -- SKEL_R_Calf
            52301,  -- SKEL_R_Foot
            14656,  -- SKEL_R_Toe0
        }
    },
    
    arms = {
        name = 'arms',
        description = 'Upper arms, forearms, hands',
        bones = {
            -- Left arm
            45509,  -- SKEL_L_UpperArm
            61163,  -- SKEL_L_Forearm
            18905,  -- SKEL_L_Hand
            26610,  -- SKEL_L_Finger00 (thumb)
            4089,   -- SKEL_L_Finger10 (index)
            4137,   -- SKEL_L_Finger20 (middle)
            26294,  -- SKEL_L_Finger30 (ring)
            58866,  -- SKEL_L_Finger40 (pinky)
            
            -- Right arm
            40269,  -- SKEL_R_UpperArm
            28252,  -- SKEL_R_Forearm
            57005,  -- SKEL_R_Hand
            58867,  -- SKEL_R_Finger00 (thumb)
            64016,  -- SKEL_R_Finger10 (index)
            64017,  -- SKEL_R_Finger20 (middle)
            64064,  -- SKEL_R_Finger30 (ring)
            64065,  -- SKEL_R_Finger40 (pinky)
        }
    },
}

-- ============================================================================
-- COMPONENT ID MAPPING
-- ============================================================================
-- weaponDamageEvent returns component IDs, not bone IDs
-- This mapping is critical for server-side damage validation
-- ============================================================================

local componentToGroup = {
    -- Head components
    [0] = 'head',       -- Head hitbox component
    [31086] = 'head',   -- Direct head bone
    [39317] = 'head',   -- Neck
    [57597] = 'head',   -- Neck
    
    -- Torso components
    [23553] = 'torso',  -- Pelvis
    [24816] = 'torso',  -- Spine root
    [24817] = 'torso',  -- Spine 0
    [24818] = 'torso',  -- Spine 1
    [11816] = 'torso',  -- Spine 2
    [57005] = 'torso',  -- Spine 3
    [14201] = 'torso',  -- Spine 4
    
    -- Leg components
    [51826] = 'legs',   -- L Thigh
    [58271] = 'legs',   -- L Calf / R Thigh
    [14201] = 'legs',   -- L Foot
    [36864] = 'legs',   -- R Calf
    [52301] = 'legs',   -- R Foot
    
    -- Arm components
    [45509] = 'arms',   -- L Upper Arm
    [61163] = 'arms',   -- L Forearm
    [18905] = 'arms',   -- L Hand
    [40269] = 'arms',   -- R Upper Arm
    [28252] = 'arms',   -- R Forearm
    [57005] = 'arms',   -- R Hand (conflicts with spine3 - context dependent)
}

-- ============================================================================
-- FAST LOOKUP TABLES
-- ============================================================================
-- Pre-computed for O(1) bone group resolution
-- ============================================================================

local boneIdToGroup = {}
for groupName, group in pairs(boneGroups) do
    for _, boneId in ipairs(group.bones) do
        boneIdToGroup[boneId] = groupName
    end
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

---Get bone group from bone ID (client-side usage with GET_PED_LAST_DAMAGE_BONE)
---@param boneId number
---@return string|nil groupName
function bonemap.getGroupFromBone(boneId)
    return boneIdToGroup[boneId]
end

---Get bone group from component ID (server-side usage with weaponDamageEvent)
---@param componentId number
---@return string|nil groupName
function bonemap.getGroupFromComponent(componentId)
    return componentToGroup[componentId]
end

---Get all bones for a group
---@param groupName string
---@return number[]|nil
function bonemap.getBonesForGroup(groupName)
    local group = boneGroups[groupName]
    return group and group.bones or nil
end

---Get all bone groups
---@return string[]
function bonemap.getAllGroups()
    local groups = {}
    for name in pairs(boneGroups) do
        table.insert(groups, name)
    end
    return groups
end

---Register custom bone group (for future extensions)
---@param name string
---@param bones number[]
---@param description string
function bonemap.registerGroup(name, bones, description)
    if boneGroups[name] then
        error(('Bone group "%s" already exists'):format(name))
    end
    
    boneGroups[name] = {
        name = name,
        description = description or '',
        bones = bones
    }
    
    -- Update lookup table
    for _, boneId in ipairs(bones) do
        boneIdToGroup[boneId] = name
    end
    
    if config.debug.enabled then
        print(('[Weapon Framework] Registered bone group: %s (%d bones)'):format(name, #bones))
    end
end

---Map component ID to bone group (for custom mappings)
---@param componentId number
---@param groupName string
function bonemap.mapComponent(componentId, groupName)
    if not boneGroups[groupName] then
        error(('Bone group "%s" does not exist'):format(groupName))
    end
    
    componentToGroup[componentId] = groupName
    
    if config.debug.enabled then
        print(('[Weapon Framework] Mapped component %d -> %s'):format(componentId, groupName))
    end
end

---Get human-readable bone group name
---@param groupName string
---@return string
function bonemap.getGroupDescription(groupName)
    local group = boneGroups[groupName]
    return group and group.description or 'Unknown'
end

---Check if bone ID exists in any group
---@param boneId number
---@return boolean
function bonemap.isValidBone(boneId)
    return boneIdToGroup[boneId] ~= nil
end

---Check if component ID exists in mapping
---@param componentId number
---@return boolean
function bonemap.isValidComponent(componentId)
    return componentToGroup[componentId] ~= nil
end

-- ============================================================================
-- FALLBACK LOGIC
-- ============================================================================
-- If bone/component not in map, apply smart fallback
-- ============================================================================

---Get bone group with fallback logic
---@param boneOrComponentId number
---@param isComponent boolean
---@return string groupName (defaults to 'torso' if unknown)
function bonemap.getGroupWithFallback(boneOrComponentId, isComponent)
    local group = isComponent 
        and bonemap.getGroupFromComponent(boneOrComponentId)
        or bonemap.getGroupFromBone(boneOrComponentId)
    
    if group then
        return group
    end
    
    -- Fallback: treat unknown bones as torso hits (safest assumption)
    if config.debug.enabled then
        print(('[Weapon Framework] Unknown %s ID: %d (defaulting to torso)'):format(
            isComponent and 'component' or 'bone',
            boneOrComponentId
        ))
    end
    
    return 'torso'
end

-- ============================================================================
-- DEBUGGING UTILITIES
-- ============================================================================

if config.debug.enabled then
    ---Print all bone mappings (debug only)
    function bonemap.printMappings()
        print('=== BONE GROUP MAPPINGS ===')
        for groupName, group in pairs(boneGroups) do
            print(('Group: %s (%s)'):format(groupName, group.description))
            print(('  Bones: %s'):format(table.concat(group.bones, ', ')))
        end
        
        print('\n=== COMPONENT MAPPINGS ===')
        for componentId, groupName in pairs(componentToGroup) do
            print(('Component %d -> %s'):format(componentId, groupName))
        end
    end
end

return BoneMap
