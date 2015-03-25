local CCBLoader = class("CCBLoader")

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
    if options.displayFrame.plist ~= "" then
        local frame = cache:getSpriteFrame(options.displayFrame.spriteFrameName)
        spr:setSpriteFrame(frame)
    else
        local filename = options.displayFrame.spriteFrameName
        spr:setTexture(filename)
    end
    local op = options.opacity or 255
    spr:setOpacity(op)
    local color = options.color or cc.c3b(255, 255, 255)
    spr:setColor(color)
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
    spr:setPreferredSize(options.preferedSize)
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
    setNodeProps(spr, options)
    setSpriteProps(spr, options)
    return spr
end

local function scale9SpriteCreateFunc(options)
    local spr = display.newScale9Sprite()
    setNodeProps(spr, options)
    setScale9SpriteProps(spr, options)
    return spr
end

local function controllButtonCreateFunc(options)
    local title = display.newTTFLabel({ text =options["title|1"], 
                                        font = options["titleTTF|1"], 
                                        size = options["titleTTFSize|1"] }) 
    local titleAnchorX, titleAnchorY = 0.5, 0.5
    if options.labelAnchorPoint then
        titleAnchorX, titleAnchorY = options.labelAnchorPoint.x, options.labelAnchorPoint.y
    end
    title:setAnchorPoint(cc.p(titleAnchorX, titleAnchorY))

    local norfile = options["backgroundSpriteFrame|1"].spriteFrameName
    local highfile = options["backgroundSpriteFrame|2"].spriteFrameName
    local disfile = options["backgroundSpriteFrame|3"].spriteFrameName

    local zoomOnTouchDown = options.zoomOnTouchDown
    local btnsize = options.preferedSize

    local norSprite = display.newScale9Sprite("#"..norfile)
    local ret =  cc.ControlButton:create(title, norSprite)
    ret:setZoomOnTouchDown(zoomOnTouchDown)
    -- 文件名中包含nil.png表示不创建这个图片，节约资源和内存
    if not string.find(highfile, "nil.png") then
        local highSprite = display.newScale9Sprite("#"..highfile)
        ret:setBackgroundSpriteForState(highSprite, 
                                        cc.CONTROL_STATE_HIGH_LIGHTED);
    end
    if not string.find(disfile, "nil.png") then
        local disSprite = display.newScale9Sprite("#"..disfile)  
        ret:setBackgroundSpriteForState(disSprite, 
                                        cc.CONTROL_STATE_DISABLED);
    end
    ret:setPreferredSize(btnsize)

    setNodeProps(ret, options)

    return ret
end

local function labelTTFCreateFunc(options)
    print("label ttf options is")
    print_r(options)
    local label = display.newTTFLabel({ 
                                        text = options.string,
                                        font = options.fontName, 
                                        size = options.fontSize,
                                        color = options.color,
                                        dimensions = options.dimensions,
                                        align = options.horizontalAlignment,
                                        valign = options.verticalAlignment
                                        })
    setNodeProps(label, options)
    return label
end

local function labelBMFontCreateFunc(options)
    local label = display.newBMFontLabel{font = options.fntFile, text = options.string}
    setNodeProps(label, options)
    setLabelBMFontProps(label, options)
    return label
end

local function ListViewCreateFunc(options)
    print("ListViewCreateFunc")
    print_r(options)
    local spriteFrameName = "#" .. options.spriteFrame.spriteFrameName
    local w = options.preferedSize.width
    local h = options.preferedSize.height
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
    local w = options.preferedSize.width
    local h = options.preferedSize.height
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

local baseClassCreateFuncs = {
    CCLayer = layerCreateFunc,
    CCNode = nodeCreateFunc,
    CCSprite = spriteCreateFunc,
    CCScale9Sprite = scale9SpriteCreateFunc,
    CCControlButton = controllButtonCreateFunc,
    CCLabelTTF = labelTTFCreateFunc,
    CCLabelBMFont  = labelBMFontCreateFunc,
    CCListView = ListViewCreateFunc,
    CCPageView = PageViewCreateFunc,
}

local function positionparseFunc(data)
    return {x = data[1], y = data[2]}
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
    return cc.c3b(data[1], data[2], data[3])
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

local function preferedSizeParseFunc(data)
    return {width = data[1], height = data[2]}
end

local function ccControlParseFunc(data)
    return {callback_func_name = data[1] }
end

local function ccControlTTFSizeParseFunc(data)
    return data[1]
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
    flip = flipParseFunc,
    blendFunc = BlendFuncParseFunc,
    spriteFrame = spriteFrameParseFunc,
    preferedSize = preferedSizeParseFunc,
    opacity = "self",
    insetLeft = "self",
    insetTop = "self",
    insetRight = "self",
    insetBottom = "self",
    fntFile = "self",
    string = "self",
    ccControl = ccControlParseFunc,
    enabled = "self",
    labelAnchorPoint = labelAnchorPointParseFunc,
    zoomOnTouchDown = "self",
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
}
-- cocosbuilder有的key也太奇葩了。 为了这个 | 只好这么写了
propParseFuncs["title|1"] = "self"
propParseFuncs["titleTTF|1"] = "self"
propParseFuncs["titleTTFSize|1"] = ccControlTTFSizeParseFunc
propParseFuncs["backgroundSpriteFrame|1"] = spriteFrameParseFunc
propParseFuncs["titleColor|1"] = colorParseFunc
propParseFuncs["backgroundSpriteFrame|2"] = spriteFrameParseFunc
propParseFuncs["titleColor|2"] = colorParseFunc
propParseFuncs["backgroundSpriteFrame|3"] = spriteFrameParseFunc
propParseFuncs["titleColor|3"] = colorParseFunc


local function parseProps(props)
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
            ret[name] = func(v)
        elseif func and type(func) == "string" and func == "self" then
            ret[name] = v
        end
    end
    return ret
end

local function parseSequenceProps(seqs, callbacks)
    local ret = {}
    local CCSeq = require("app.statics.CCBLoader.CCBSeq")
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

local function createNodeWithBaseClassName(rootdata, childrenList, seq)
    local baseClassName = rootdata["baseClass"]
    local props = rootdata["properties"]
    local sequenses = rootdata["sequences"]
    local options = parseProps(props)
    local node = baseClassCreateFuncs[baseClassName](options)
    setNodeBaseValue(node, baseClassName, options)
    -- 把animatedProprties存起来，方便后面创建Action的时候使用
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
            if #child.children > 0 then
                childrenList[child.memberVarAssignmentName] = {}
                nextList = childrenList[child.memberVarAssignmentName]
            end

            -- 递归创建子节点
            local c = createNodeWithBaseClassName(child, nextList, seq)
            if c then
                node:addChild(c)
            else
                printf("!!!!!! fail to parse node name = %s, type = %s,memberVarAssignmentName = %s", 
                    child.displayName, child.baseClass, child.memberVarAssignmentName)
                assert(false)
            end

            -- 这里遍历到根节点了，进行赋值
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
    local data = cc.HelperFunc:getFileData(jsonFileName)
    local layoutdata = json.decode(data)
    local rootdata = layoutdata["nodeGraph"]
    local seqdata = layoutdata["sequences"]
    local childrenList = {}
    local seq = parseSequenceProps(seqdata, callbacks)
    local ccbNode = createNodeWithBaseClassName(rootdata, childrenList, seq)
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
    -- 处理循环播放或者连续播放的情况
    local function playNextSeq(runningNode, allseq, seq)
        local nextid = seq.chainedSequenceId
        if tonumber(nextid) == -1 then
            return
        end
        local nextSeq = getSeqWithId(allseq, nextid)
        playSeq(runningNode, allseq, nextSeq)
    end
    local next = delaycall(s.length, playNextSeq, node, allseq, s) 
    node:runAction(next)

end

function CCBLoader.playTimeline(node, allseq, name)
    playSeq(node, allseq, allseq[name])
end

return CCBLoader


