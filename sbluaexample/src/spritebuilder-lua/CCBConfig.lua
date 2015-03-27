CCBConfig = {}

CCBConfig.fonts_root_path = "fonts/"
CCBConfig.translation_file = "Strings.json"

function CCBConfig:new()
    local instance = nil 
    return function()
        if instance then return instance end 
        local o = {}
        setmetatable(o, self)  
        self.__index = self  
        instance = o

        self:init()
        return o 
    end 
end

CCBConfig.getInstance = CCBConfig:new();

function CCBConfig:init()
    -- init the translation
    local path = CCBConfig.fonts_root_path .. CCBConfig.translation_file
    -- local language = cc.Application:getInstance():getCurrentLanguage()
    self.translation = require("spritebuilder-lua.CCBString").new(path, 0) --language)

end

function CCBConfig:getTranslation()
    return self.translation
end


return CCBConfig