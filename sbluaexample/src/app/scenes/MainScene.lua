
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()

    local cache = cc.SpriteFrameCache:getInstance()
    cache:addSpriteFrames("images/ui.plist")

    local loader = require("spritebuilder-lua.CCBLoader")
    local node, children, seq = loader.loadCCB("ccb/main_layer.json")
    self:addChild(node)

    -- local sprite = cc.Sprite:createWithSpriteFrameName("btn_green_nor.png")
    -- local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("blue_light.png")
    -- sprite:setSpriteFrame(frame)
    -- sprite:setPosition(360, 500)
    -- sprite:setAnchorPoint(0.5, 0.5)
    -- print("sprite contentsize = ", sprite:getContentSize().width, sprite:getContentSize().height)
    -- self:addChild(sprite)
    -- print("sprite position = ", sprite:getPosition())
    -- -- loader.playSeq(node, seq, "Default Timeline")
    -- local label = display.newTTFLabel({
    -- text = "Hello, World",
    -- font = "Marker Felt",
    -- size = 64,
    -- align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
    -- })

    -- label:setPosition(display.width/2, display.height/2)

    -- self:addChild(label)

end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
