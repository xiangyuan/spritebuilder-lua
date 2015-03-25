local CCBSeq = class("CCBSeq")


--  the data format is:
    -- "autoPlay": true,
    -- "length": 2,  --这个sequence的总时间
    -- "offset": 0,
    -- "position": 2,
    -- "resolution": 30,
    -- "scale": 128,
    -- "sequenceId": 0,
    -- "soundChannel": {
    -- },
    -- "chainedSequenceId": 0,
    -- "name": "timeline_default",
    -- "callbackChannel": {}
    -- }
function CCBSeq:ctor(jsondata, callbacks)
    self.callbacks = callbacks
    self.animatedNodes = {}   
    deepcopy(self, jsondata)
end

local function createEaseWithType(easetype, rate, action)
    if easetype == 0 or easetype == 1 then
        return action
    elseif easetype == 2 then
        return cc.EaseIn:create(action, rate)
    elseif easetype == 3 then
        return cc.EaseOut:create(action, rate)
    elseif easetype == 4 then
        return cc.EaseInOut:create(action, rate)
    else 
        return action
    end
end

local function keyFrame_sound_createFunc(data)
    local ret = {}
    local keyframes = data.keyframes
    for i = 1, #keyframes do
        local keyFrame = keyframes[i]
        local delay = keyFrame.time
        local action = delaycall(delay, function()
                audio.playSound(keyFrame.value[1], false)
            end)
        ret[#ret+1] = action
    end
    return ret
end

local function keyFrame_callback_createFunc(timeline, data, callbacks)
    local ret = {}
    local keyframes = data.keyframes
    for i = 1, #keyframes do 
        local keyFrame = keyframes[i]
        local func = callbacks[timeline][keyFrame.value[1]]
        if func then
            func()
        else
            print("Warning.. NOT set **callback** func for timeline: ", timeline)
        end
        local action = delaycall(keyFrame.time, func)
        ret[#ret+1] = action
    end
    return ret
end

local function keyFrameCreate(jsondata, createFunc, ...)
    local keyframes = jsondata.keyframes
    local actions = {}
    if keyframes[1].time > 0 then
        actions[#actions+1] = cc.DelayTime:create(keyframes[1].time)
    end

    for i = 1, #keyframes-1 do
        local f1 = keyframes[i]
        local f2 = keyframes[i+1]

        local action = createFunc(f1, f2, i)

        local ease = createEaseWithType(f1.easing.type, f1.easing.opt, action)
        actions[#actions+1] = ease
    end
    return cc.Sequence:create(actions)
end


-- visible to be done
-- visible 因为没有 “没有动画” 这个动画的概念，所有这里特殊处理了动画的开头和结尾
local function keyFrame_visible_action_create(jsondata)
    local function visible(f1, f2, index)
        local show = (index % 2 == 1)
        local duration = f2.time - f1.time
        -- 这些如果要写的非常优雅，需要处理ccb输出的数据。
        -- 有仔细考虑过这里的。
        local act = show and cc.Show:create() or cc.Hide:create()
        return cc.Sequence:create(act, cc.DelayTime:create(duration))
    end
    -- return keyFrameCreate(jsondata, visible)
end

local function keyFrame_color_action_create(jsondata)
    local function tint(f1, f2)
        local duration = f2.time - f1.time
        local r,g,b = f2.value[1], f2.value[2], f2.value[3]
        return cc.TintTo:create(duration, r,g,b)
    end
    -- return keyFrameCreate(jsondata, tint)
end


local function keyFrame_position_action_create(jsondata)
    local function moveto(f1, f2)
        local duration = f2.time - f1.time
        local toX, toY = f2.value[1], f2.value[2]
        return cc.MoveTo:create(duration, cc.p(toX, toY))
    end
    return keyFrameCreate(jsondata, moveto)
end

local function keyFrame_rotation_action_create(jsondata)
    local function rotate(f1, f2)
        local duration = f2.time - f1.time
        local to = f2.value - f1.value
        return cc.RotateBy:create(duration, to)
    end
    return keyFrameCreate(jsondata, rotate)
end

local function keyFrame_opacity_action_create(jsondata)
    local function opacity(f1, f2)
        local duration = f2.time - f1.time
        local to = f2.value - f1.value
        return cc.FadeTo:create(duration, to)
    end
    return keyFrameCreate(jsondata, opacity)
end

local function keyFrame_scale_action_create(jsondata)
    local function scaleTo(f1, f2)
        local duration = f2.time - f1.time
        local scalex = f2.value[1] 
        local scaley = f2.value[2]
        return cc.ScaleTo:create(duration, scalex, scaley)
    end
    return keyFrameCreate(jsondata, scaleTo)
end


local anim_createFuncs = {
    color = keyFrame_color_action_create,
    visible = keyFrame_visible_action_create,
    position = keyFrame_position_action_create,
    rotation = keyFrame_rotation_action_create,
    opacity = keyFrame_opacity_action_create,
    scale = keyFrame_scale_action_create,
}

local function keyFrame_anim_createFunc(animatedProperty)
    local ret = {}
    for actionName, keyframes in pairs(animatedProperty) do
        print("actioname = ", actionName)
        local action = anim_createFuncs[actionName](keyframes)
        if action then
            ret[#ret+1] = action
        end
    end
    return ret
end

-- playSeq 的时候，循环播放要设置回第一帧
local firstFrameSetFunc = {
    CCLayer = function(node, options) setNodeProps(node, options)  end,
    CCSprite = function(node, options)  setNodeProps(node, options) setSpriteProps(node, options) end,
    CCLabelBMFont = function(node, options) setNodeProps(node, options) end,
    CCScale9Sprite = function(node, options)
                         setNodeProps(node,options) 
                         setScale9SpriteProps(node, options) 
                    end,
}

function CCBSeq:isNodeExisted(node)
    for i = 1, #self.animatedNodes do
        if node == self.animatedNodes[i] then
            return true
        end
    end
    return false
end

function CCBSeq:addAnimForNode(node, animatedProperty)
    if self:isNodeExisted(node) then
        assert(false, "node should be added twice!")
        return
    end

    self.animatedNodes[#self.animatedNodes+1] = node
    node.animatedProperty = animatedProperty
end

function CCBSeq:setToBase(node)
    firstFrameSetFunc[node.baseClassName](node, node.baseValue)
end


function CCBSeq:getSeq(finishCallbackFunc, ...)
    local callbackChannelAction = keyFrame_callback_createFunc(self.name, self.callbackChannel, self.callbacks)
    local soundCallbackAction = keyFrame_sound_createFunc(self.soundChannel)

    for i = 1, #self.animatedNodes do 
        local node = self.animatedNodes[i]
        -- 这行代码不能加，因为动画应该不和UI坐标相互影响。
        -- self:setToBase(node)
        node:stopAllActions()
        local animatedAction = keyFrame_anim_createFunc(node.animatedProperty)
        for j = 1, #animatedAction do
            node:runAction(animatedAction[j])
        end 
    end
    return callbackChannelAction, soundCallbackAction
end

return CCBSeq