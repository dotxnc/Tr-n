
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
	if mdl.isVox then
		mdl.loading = false
		mdl:loadModel()
	else
		mdl:loadImage()
	end

	mdl:createQuads(true)
	
	return mdl

end

function ModelViewer:loadModel()
    self.file:open("r")
    local model = vox_model.new(self.file:read())
    self.file:close()

    local tex = vox_texture.new(model)
    tex.canvas:setFilter("nearest","nearest")
    self.canvas = tex.canvas
    self.quadWidth = tex.sizeX
    self.quadHeight = tex.sizeZ
    self.image = love.graphics.newImage(tex.canvas:newImageData())
    self.image:setFilter(self.nearest and "nearest" or "linear", self.nearest and "nearest" or "linear")
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

function ModelViewer:draw()
    if  self.model then

        local scale = math.min(WINDOW_W/self.image:getWidth(), WINDOW_H/self.image:getHeight())
        love.graphics.draw(self.image, WINDOW_W/2, WINDOW_H-self.image:getHeight()*scale, 0, scale,scale, self.image:getWidth()/2, 0)

        local tw = self.quadWidth
        local th = self.quadHeight
        local sx = WINDOW_W/2 - self.image:getWidth()*scale/2
        local sy = WINDOW_H - self.image:getHeight()*scale

        for x=1,self.image:getWidth()/tw do
            for y=1,self.image:getHeight()/th do
                if (y+x)%2==0 then
                    love.graphics.setColor(50, 50, 50, 100)
                else
                    love.graphics.setColor(100, 100, 100, 100)
                end
                love.graphics.rectangle("fill", sx+x*tw*scale - tw*scale, sy+y*th*scale - th*scale, tw*scale, th*scale)
            end
        end
        love.graphics.setColor(255, 255, 255, 255)

        self:drawModel(WINDOW_W/2,WINDOW_H/2)
    end
end

function ModelViewer:drawModel(x,y)
    local scale = 100/math.max(self.quadWidth, #self.quads) * self.zoom
    local sy = #self.quads/2 * self.layer_spacing*scale

    for i=1,#self.quads do
        local index = self.flip and #self.quads-i+1 or i
        for j=1,math.max(1,self.layer_spacing)*scale do
            love.graphics.draw(self.image, self.quads[index], x, y+sy - i*scale*self.layer_spacing - j, math.rad(self.rotation), scale,scale,self.quadWidth/2, self.quadHeight/2)
            if j>1 and not self.voxelMode then break end
        end
    end

    scale = WINDOW_W/self.image:getWidth()
    if not self.isVox then
        --love.graphics.draw(self.image, 0, WINDOW_H-self.image:getHeight()*scale, 0, scale, scale)
    else
        love.graphics.draw(self.canvas, 0, WINDOW_H-self.image:getHeight()*1, 0, 1, 1)
    end

end

return ModelViewer
