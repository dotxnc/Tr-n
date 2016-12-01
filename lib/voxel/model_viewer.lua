
local ModelViewer = {}
ModelViewer.__index = ModelViewer

function ModelViewer:new(file, isVox)
	local mdl =
	{
	    model = false,
	    isVox = false,
	    src,
	    file,
	    image,
	    quads,
	    quadWidth=16,
	    quadHeight=16,
	    updateTimer=0,
	    widthInput  = {text="16"},
	    heightInput = {text="16"},
	    spaceInput  = {text="1"},
	    hideUI = false,
	    --View
	    rotation = 0,
	    layer_spacing = 1,
	    voxelMode = true,
	    autoRotate = true,
	    rotateDir = 1,
	    flip = false,
	    rotate_speed = 30,
	    rotateSlider = {value = 50, min = 0, max = 150},
	    zoom = 0.25,
	    nearest=true,
	}
	setmetatable(mdl, ModelViewer)
	
	mdl.src = file:getFilename()
	mdl.file = file
	mdl.model = true
	mdl.zoom = 0.25

	mdl.isVox = isVox or false
	mdl:loadImage()

	mdl:createQuads(true)
	
	return mdl

end

function ModelViewer:loadImage()
    self.file:open("r")
    local imageData = love.image.newImageData(self.file)
    self.file:close()
    self.image = love.graphics.newImage(imageData)
    self.image:setFilter(self.nearest and "nearest" or "linear", self.nearest and "nearest" or "linear")

    self.quadWidth=self.image:getHeight()
    self.quadHeight=self.quadWidth

    self.heightInput.text   = self.quadWidth..""
    self.widthInput.text    = self.quadHeight..""

    return true
end

function ModelViewer:createQuads(first)
    self.quads = {}

    local steps = self.image:getWidth()/self.quadWidth
    for i=1,steps do
        self.quads[i] = love.graphics.newQuad((i-1)*self.quadWidth, 0, self.quadWidth, self.quadHeight, self.image:getWidth(), self.image:getHeight())
    end

    if first then
        if not self.isVox then
            self.layer_spacing = math.floor(math.max(((self.quadWidth+self.quadHeight)/3)/#self.quads, 1)+.5)
        else
            self.layer_spacing = 1
        end
        self.spaceInput.text = self.layer_spacing..""
    end

end

function ModelViewer:drawModel(x,y)

    local WINDOW_W,WINDOW_H = love.graphics.getWidth(), love.graphics.getHeight()
    local scale = 100/math.max(self.quadWidth, #self.quads) * self.zoom
    local sy = #self.quads/2 * self.layer_spacing*scale

    for i=1,#self.quads do
        local index = self.flip and #self.quads-i+1 or i
        for j=1,math.max(1,self.layer_spacing)*scale do
            love.graphics.draw(self.image, self.quads[index], x, y+sy - i*scale*self.layer_spacing - j, math.rad(self.rotation), scale,scale,self.quadWidth/2, self.quadHeight/2)
            if j>1 and not self.voxelMode then break end
        end
    end

end

return ModelViewer
