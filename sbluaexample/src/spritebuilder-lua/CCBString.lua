local CCBString = class("CCBString")

local deepcopy = require("spritebuilder-lua.CCBTools").deepcopy
function CCBString:ctor(path, language)
    self.language = language
    print("path = ", path)
    local data = cc.HelperFunc:getFileData(path)

    local json = json.decode(data)
    -- require("spritebuilder-lua.CCBTools").deepcopy(self, json)

    -- create key-value index
    self.translations = {}
    for i = 1,#json.translations do
        local t = json.translations[i]
        local translation = {}
        deepcopy(translation, t.translations)
        self.translations[t.key] = translation
    end
    dump(self.translations, "self.translations")
    -- dump(self, "CCBString", 5)
    print("str(game_title) ", self:str("game_title"))

end


local languageCodeStr = {}
languageCodeStr[0] = "en"
languageCodeStr[1] = "zh-Hans"


function CCBString:str(key)
    local l = self.language or 0
    local code = languageCodeStr[l]
    return self.translations[key][code]
end

return CCBString