
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    -- local loader = require("spritebuilder-lua.CCBLoader")
    -- loader.loadCCB()
    local label = display.newTTFLabel({
    text = "Hello, World",
    font = "Marker Felt",
    size = 64,
    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
    })

    label:setPosition(display.width/2, display.height/2)

    self:addChild(label)

end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
