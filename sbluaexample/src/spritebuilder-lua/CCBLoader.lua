local CCBLoader = class("CCBLoader")

local POSITION_TYPE_IN_POINTS  = 0
local POSITION_TYPE_IN_UI_POINTS = 1
local POSITION_TYPE_PERCENT = 2
local Config = require("spritebuilder-lua.CCBConfig")
local translation = Config:getInstance():getTranslation()

local Tools = require("spritebuilder-lua.CCBTools")
local c3b_c4b = Tools.c3b_c4b
local delayCall = Tools.delayCall

local function stringFromOptions(options)
    local data = options.string or options.title
    assert(data ~= nil, "Error: stringFromOptions data is nil")
    return data[2] and translation:str(data[1]) or data[1]
end

local function setNodeProps(node, options)
    if options.contentSize then
        node:setContentSize(options.contentSize)
    end

    local x, y = 0, 0
    if options.position then
        x, y = options.position.x, options.position.y
    end

    local anchorX, anchorY = 0.5, 0.5
    if options.anchorPoint then
        anchorX, anchorY = options.anchorPoint.x, options.anchorPoint.y
    end

    local scaleX, scaleY = 1, 1
    if options.scale then
        scaleX, scaleY = options.scale.x, options.scale.y
    end

    local rotation = 0
    if options.rotation then
        rotation = options.rotation
    end

    local visible = true
    if options.visible then
        visible = options.visible
    end
    node:setScaleX(scaleX)
    node:setScaleY(scaleY)
    node:setRotation(rotation)

    local ignoreAnchor = options.ignoreAnchorPointForPosition or false
    node:setPosition(x, y)
    node:setAnchorPoint(anchorX, anchorY)
    node:ignoreAnchorPointForPosition(ignoreAnchor)
end

local function setSpriteProps(spr, options)
    local cache = cc.SpriteFrameCache:getInstance()
    if options.spriteFrame.plist ~= "" then
        local frame = cache:getSpriteFrame(options.spriteFrame.spriteFrameName)
        spr:setSpriteFrame(frame)
    else
        local filename = options.spriteFrame.spriteFrameName
        spr:setTexture(filename)
    end

    if options.opacity then
        spr:setOpacity(options.opacity)
    end

    if options.color then
        spr:setColor(options.color)
    end
    
    local flipX, flipY = false, false 
    if options.flip then
        flipX, flipY = options.flip.flipX, options.flip.flipY
    end
    spr:setFlippedX(flipX)
    spr:setFlippedY(flipY)
end

local function setScale9SpriteProps(spr, options)
    local cache = cc.SpriteFrameCache:getInstance()
    local frame = cache:getSpriteFrame(options.spriteFrame.spriteFrameName)
    spr:setSpriteFrame(frame)
    spr:setPreferredSize(options.preferredSize)
    spr:setOpacity(options.opacity)
    spr:setColor(options.color)
end

local function setLabelBMFontProps(label, options)
    local op = options.opacity or 255
    label:setOpacity(op)
    local color = options.color or cc.c3b(255, 255, 255)
    label:setColor(color)
end

local function layerCreateFunc(options)
    local layer = display.newLayer()
    setNodeProps(layer, options)
    return layer
end

local function nodeCreateFunc(options)
    local node = display.newNode()
    setNodeProps(node, options)
    return node
end

local function spriteCreateFunc(options)
    local spr = display.newSprite()
    setSpriteProps(spr, options)
    setNodeProps(spr, options)
    return spr
end

local function scale9SpriteCreateFunc(options)
    local spr = display.newScale9Sprite()
    setNodeProps(spr, options)
    setScale9SpriteProps(spr, options)
    return spr
end

local function controllButtonCreateFunc(options)
    dump(options, "control btn's options")
    local text = stringFromOptions(options)
    local fontPath = Config.fonts_root_path .. options.fontName

    local title = display.newTTFLabel({ text = text, 
                                        font = fontPath, 
                                        size = options.fontSize }) 
    local titleAnchorX, titleAnchorY = 0.5, 0.5
    if options.labelAnchorPoint then
        titleAnchorX, titleAnchorY = options.labelAnchorPoint.x, options.labelAnchorPoint.y
    end
    title:setAnchorPoint(cc.p(titleAnchorX, titleAnchorY))

    local norFile = options["backgroundSpriteFrame|Normal"].spriteFrameName
    local highFile = options["backgroundSpriteFrame|Highlighted"].spriteFrameName
    local disFile = options["backgroundSpriteFrame|Disabled"].spriteFrameName
    local selFile = options["backgroundSpriteFrame|Selected"].spriteFrameName
    local zoomWhenHighlighted = options.zoomWhenHighlighted
    local btnsize = options.preferredSize

    local norSprite = display.newScale9Sprite("#"..norFile)
    norSprite:setPreferredSize(btnsize)
    local ret =  cc.ControlButton:create(title, norSprite)
    ret:setZoomOnTouchDown(zoomWhenHighlighted)
    -- 文件名中包含nil.png表示不创建这个图片，节约资源和内存
    if highFile and string.len(highFile) > 0 then
        local highSprite = display.newScale9Sprite("#"..highFile)
        highSprite:setPreferredSize(btnsize)
        ret:setBackgroundSpriteForState(highSprite, 
                                        cc.CONTROL_STATE_HIGH_LIGHTED);
    end
    if disFile and string.len(disFile) > 0 then
        local disSprite = display.newScale9Sprite("#"..disFile)  
        disSprite:setPreferredSize(btnsize)
        ret:setBackgroundSpriteForState(disSprite, 
                                        cc.CONTROL_STATE_DISABLED);
    end

    local status = {"Normal", "Highlighted", "Disabled", "Selected"}
    local states = {}
    for i = 1, #status do 
        local key =  "labelColor|" .. status[i]
        local labelColor = options[key]
        if labelColor then
            ret:setTitleColorForState(labelColor, cc.CONTROL_STATE_NORMAL+(i-1))
        end
    end
    
    

    ret:setPreferredSize(btnsize)
    setNodeProps(ret, options)

    return ret
end

local function labelTTFCreateFunc(options)
    dump(options, "labelTTFCreateFunc")
    local label = display.newTTFLabel({ 
                                        text = stringFromOptions(options),
                                        font = options.fontName, 
                                        size = options.fontSize,
                                        color = c3b_c4b(options.fontColor),
                                        dimensions = options.dimensions,
                                        align = options.horizontalAlignment,
                                        valign = options.verticalAlignment
                                        })
    local outlineColor = c3b_c4b(options.outlineColor)
    label:enableOutline(outlineColor, options.outlineWidth)

    label:enableShadow(c3b_c4b(options.shadowColor), options.shadowOffset, options.shadowBlurRadius)

    setNodeProps(label, options)
    return label
end

local function labelBMFontCreateFunc(options)
    local text = stringFromOptions(options)--options.string[2] and translation:str(options.string[1]) or options.string[1]
    local font_path = Config.fonts_root_path .. options.fntFile
    local label = display.newBMFontLabel{font = font_path, text = text}
    setNodeProps(label, options)
    setLabelBMFontProps(label, options)
    return label
end

local function ListViewCreateFunc(options)
    print("ListViewCreateFunc")
    local spriteFrameName = "#" .. options.spriteFrame.spriteFrameName
    local w = options.preferredSize.width
    local h = options.preferredSize.height
    local x = options.position.x
    local y = options.position.y
    local ax = options.anchorPoint.x
    local ay = options.anchorPoint.y
    local color = options.color or cc.c3b(255, 255, 255)
    local dir = options.isHorizontal and 
                cc.ui.UIScrollView.DIRECTION_HORIZONTAL or cc.ui.UIScrollView.DIRECTION_VERTICAL
    local listView = cc.ui.UIListView.new {
        bg = spriteFrameName,
        bgScale9 = true,
        viewRect = cc.rect(x, y, w, h),
        direction = dir}
    listView:setAnchorPoint(cc.p(ax, ay))
    listView:setContentSize(w,h)
    return listView
end

local function PageViewCreateFunc(options)
    local w = options.preferredSize.width
    local h = options.preferredSize.height
    local x = options.position.x
    local y = options.position.y
    local pageView = cc.ui.UIPageView.new {
        viewRect = cc.rect(x,y,w,h),
        column = options.column,
        row = options.row,
        columnSpace = options.columnSpace,
        rowSpace = options.rowSpace,
        padding = {
            left = options.paddingLeft, 
            right = options.paddingRight, 
            top = options.paddingTop, 
            bottom = options.paddingBottom
        },
        circle = options.isCircle
    }
    
    return pageView
end

local function nodeColorCreateFunc(options)
    local color = options.color
    local layer = cc.LayerColor:create(cc.c3b(color.r, color.g, color.b, 1))
    layer:setOpacity(options.opacity)
    setNodeProps(layer, options)
    return layer
end

local baseClassCreateFuncs = {
    CCLayer = layerCreateFunc,
    CCNode = nodeCreateFunc,
    CCSprite = spriteCreateFunc,
    CCScale9Sprite = scale9SpriteCreateFunc,
    CCButton = controllButtonCreateFunc,
    CCLabelTTF = labelTTFCreateFunc,
    CCLabelBMFont  = labelBMFontCreateFunc,
    CCListView = ListViewCreateFunc,
    CCPageView = PageViewCreateFunc,
    CCNodeColor = nodeColorCreateFunc,
}

local function positionparseFunc(data, father)

    local x, y
    -- setx
    if father and data[4] == POSITION_TYPE_PERCENT then 
        x = data[1] * father:getContentSize().width
    elseif (data[4] == POSITION_TYPE_IN_POINTS or data[4] == POSITION_TYPE_IN_UI_POINTS) then
        x = data[1]
    end
     if father and data[5] == POSITION_TYPE_PERCENT then 
        y = data[2] * father:getContentSize().height
    elseif (data[5] == POSITION_TYPE_IN_POINTS or data[5] == POSITION_TYPE_IN_UI_POINTS) then
        y = data[2]
    end
    return {x = x, y = y}

    -- sety
end

local function contentSizeParseFunc(data)
    return {width = data[1], height = data[2]}
end

local function anchorPointParseFunc(data)
    return {x = data[1], y = data[2]}
end

local function scaleParseFunc(data)
    return {x = data[1], y = data[2]} 
end

local function displayFrameParseFunc(data)
    return {plist = data[1], spriteFrameName = data[2]}
end

local function colorParseFunc(data)
    return cc.c3b(data[1]*255, data[2]*255, data[3]*255)
end

local function opacityParseFunc(data)
    return data*255
end

local function flipParseFunc(data)
    return {flipX = data[1], flipY = data[2]}
end

local function BlendFuncParseFunc(data)
    return {src = data[1], dst = data[2]}
end

local function spriteFrameParseFunc(data)
    return {plist = data[1], spriteFrameName = data[2]}
end

local function preferredSizeParseFunc(data)
    return {width = data[1], height = data[2]}
end

local function ccControlParseFunc(data)
    return {callback_func_name = data[1] }
end

local function labelAnchorPointParseFunc(data)
    return {x = data[1], y = data[2]}
end

local function labelTTFFontSizeParseFunc(data)
    return data[1]
end

local function demensionsParseFunc(data)
    return {width = data[1], height = data[2]}
end

local function horizontalPaddingFunc(data)
    return data[1]
end

local function verticalPaddingFunc(data)
    return data[1]
end

local function floatScaleParseFunc(data)
    return data[1]
end

local propParseFuncs = {
    visible = "self",
    position = positionparseFunc,
    rotation = "self",
    contentSize = contentSizeParseFunc,
    anchorPoint = anchorPointParseFunc,
    scale = scaleParseFunc,
    ignoreAnchorPointForPosition = "self",  -- “self” 相当于 local function parseFunc(data) return data end
    displayFrame = displayFrameParseFunc,
    color = colorParseFunc,
    opacity = opacityParseFunc,
    flip = flipParseFunc,
    blendFunc = BlendFuncParseFunc,
    spriteFrame = spriteFrameParseFunc,
    preferredSize = preferredSizeParseFunc,
    insetLeft = "self",
    insetTop = "self",
    insetRight = "self",
    insetBottom = "self",
    fntFile = "self",
    string = "self",
    ccControl = ccControlParseFunc,
    enabled = "self",
    labelAnchorPoint = labelAnchorPointParseFunc,
    zoomWhenHighlighted = "self",
    isHorizontal = "self",
    column = "self",
    row = "self",
    columnSpace = "self",
    rowSpace = "self",
    paddingLeft = "self",
    paddingRight = "self",
    paddingTop = "self",
    paddingBottom = "self",
    isCircle = "self";
    fontName = "self",
    fontSize = labelTTFFontSizeParseFunc,
    horizontalAlignment = "self",
    verticalAlignment = "self",
    dimensions = demensionsParseFunc,
    horizontalPadding = horizontalPaddingFunc,
    verticalPadding = verticalPaddingFunc,
    title = "self",
    fontColor = colorParseFunc,
    outlineColor = colorParseFunc,
    outlineWidth = floatScaleParseFunc,
    shadowColor = colorParseFunc,
    shadowBlurRadius = floatScaleParseFunc,
    shadowOffset = positionparseFunc,
}

propParseFuncs["backgroundSpriteFrame|Normal"] = spriteFrameParseFunc
propParseFuncs["backgroundSpriteFrame|Highlighted"] = spriteFrameParseFunc
propParseFuncs["backgroundSpriteFrame|Disabled"] = spriteFrameParseFunc
propParseFuncs["backgroundSpriteFrame|Selected"] = spriteFrameParseFunc

propParseFuncs["labelColor|Normal"] = colorParseFunc
propParseFuncs["labelColor|Highlighted"] = colorParseFunc
propParseFuncs["labelColor|Disabled"] = colorParseFunc
propParseFuncs["labelColor|Selected"] = colorParseFunc

propParseFuncs["labelOpacity|Normal"] = "self"
propParseFuncs["labelOpacity|Highlighted"] = "self"
propParseFuncs["labelOpacity|Disabled"] = "self"
propParseFuncs["labelOpacity|Selected"] = "self"


propParseFuncs["backgroundColor|Normal"] = colorParseFunc
propParseFuncs["backgroundColor|Highlighted"] = colorParseFunc
propParseFuncs["backgroundColor|Disabled"] = colorParseFunc
propParseFuncs["backgroundColor|Selected"] = colorParseFunc



local function parseProps(props, father)
    local ret = {}
    for i = 1, #props do
        local p = props[i]
        local name = p.name
        local func = propParseFuncs[name]
        local v
        if p["baseValue"] ~= nil then
            v = p["baseValue"]
        else
            v = p["value"]
        end
        if func and type(func) == 'function' then
            ret[name] = func(v, father)
        elseif func and type(func) == "string" and func == "self" then
            ret[name] = v
        end
    end
    return ret
end

local function parseSequenceProps(seqs, callbacks)
    local ret = {}
    local CCSeq = require("spritebuilder-lua.CCBSeq")
    for i = 1, #seqs do
        local s = CCSeq.new(seqs[i], callbacks)
        ret[s.name] = s
    end
    return ret
end

local function getSeqWithId(seq, id)
    for k,v in pairs(seq) do
        if tonumber(v.sequenceId) == tonumber(id) then
            return v
        end
    end
    assert(false, string.format("not fond seq id = %d", id))
end

local function setNodeBaseValue(node, baseClassName, options)
    node.baseClassName = baseClassName
    node.baseValue = options
end

local function createNodeWithBaseClassName(rootdata, father, childrenList, seq)
    local baseClassName = rootdata["baseClass"]
    print("baseClassName = ", baseClassName)
    local props = rootdata["properties"]
    local sequenses = rootdata["sequences"]
    local options = parseProps(props, father)
    local node = baseClassCreateFuncs[baseClassName](options)
    setNodeBaseValue(node, baseClassName, options)
    -- used for create actions
    local animatedProperties = rootdata["animatedProperties"]
    if animatedProperties then
        print("-----animatedProperties----")
        print("node has ", table.nums(animatedProperties), "timeline!, in sequense ")
        for id, animatedProperty in pairs(animatedProperties) do
            local s = getSeqWithId(seq, id)
            print("s.seqid = ", s.sequenceId)
            s:addAnimForNode(node, animatedProperty)
        end
    end
    local children = rootdata["children"]
    if #children > 0 then
        print(rootdata.baseClass, "has", #children, "children")
        for i = 1, #children do
            local child = children[i]
            local nextList = childrenList
            -- 如果该节点还有子节点，则再创建一个table 用来保存子节点的数据，递归到根节点
            -- create new table to save to reference of the children
            if #child.children > 0 then
                childrenList[child.memberVarAssignmentName] = {}
                nextList = childrenList[child.memberVarAssignmentName]
            end

            -- 递归创建子节点
            -- create the children recursively
            local c = createNodeWithBaseClassName(child, node, nextList, seq)
            if c then
                node:addChild(c)
            else
                printf("!!!!!! fail to parse node name = %s, type = %s,memberVarAssignmentName = %s", 
                    child.displayName, child.baseClass, child.memberVarAssignmentName)
                assert(false)
            end

            -- 这里遍历到叶节点了，进行赋值
            -- to the 'leaf nodes'
            if child.memberVarAssignmentName
                and child.memberVarAssignmentName ~= "" 
                and #child.children == 0 then
                childrenList[child.memberVarAssignmentName] = c
            end
        end
    end
    return node
end

function CCBLoader.loadCCB(jsonFileName, callbacks, root)
    print("filepath is ", jsonFileName)
    require("spritebuilder-lua.CCBConfig"):getInstance()
    local data = cc.HelperFunc:getFileData(jsonFileName)
    local layoutdata = json.decode(data)
    local rootdata = layoutdata["nodeGraph"]
    local seqdata = layoutdata["sequences"]
    local childrenList = {}
    local seq = parseSequenceProps(seqdata, callbacks)
    local ccbNode = createNodeWithBaseClassName(rootdata, root, childrenList, seq)
    if root then
        root:addChild(ccbNode)
    end
    return ccbNode, childrenList, seq
end

function CCBLoader.playSeq(node, allseq, s)
    local callfuncs, sounds, finish = s:getSeq()

    for i = 1, #callfuncs do
        node:runAction(callfuncs[i])
    end

    for i = 1, #sounds do
        node:runAction(sounds[i])
    end
    -- play recursively
    local function playNextSeq(runningNode, allseq, seq)
        local nextid = seq.chainedSequenceId
        if tonumber(nextid) == -1 then
            return
        end
        local nextSeq = getSeqWithId(allseq, nextid)
        CCBLoader.playSeq(runningNode, allseq, nextSeq)
    end
    local next = delayCall(s.length, playNextSeq, node, allseq, s) 
    node:runAction(next)

end

function CCBLoader.playTimeline(node, allseq, name)
    local nm = name or "Default Timeline"
    CCBLoader.playSeq(node, allseq, allseq[nm])
end

return CCBLoader


