local Chip = class("Chip")

function Chip:getBatchNode(num)
	num = num or 200
    local batch = display.newBatchNode("common.png",num)
    return batch
end

function Chip:new(x,y,batchnode)
    local id = "#gold/gold.png"
    x, y = x or 0 , y or 0
    local chip = display.newSprite(id,x,y)
    if chip == nil then return nil end
    if batchnode then
        batchnode:addChild(chip)
    end
    return chip
end

return Chip