WINDOW_W = 1280
WINDOW_H = 720

lg = love.graphics--require ("lib.autobatch")
local play = require ("states.play")

local bloom = lg.newShader[[
extern number threshold = 8.0;

extern number canvas_w = 1280;
extern number canvas_h = 720;
         
const number offset_1 = 1.5;
const number offset_2 = 3.5;

const number alpha_0 = 0.23;
const number alpha_1 = 0.32;
const number alpha_2 = 0.07;

float luminance(vec3 color)
{
   // numbers make 'true grey' on most monitors, apparently
   return ((0.212671 * color.r) + (0.715160 * color.g) + (0.072169 * color.b));
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
   vec4 texcolor = Texel(texture, texture_coords);

   // Vertical blur
   vec3 tc_v = texcolor.rgb * alpha_0;
   
   tc_v += Texel(texture, texture_coords + vec2(0.0, offset_1)/canvas_h).rgb * alpha_1;
   tc_v += Texel(texture, texture_coords - vec2(0.0, offset_1)/canvas_h).rgb * alpha_1;
   
   tc_v += Texel(texture, texture_coords + vec2(0.0, offset_2)/canvas_h).rgb * alpha_2;
   tc_v += Texel(texture, texture_coords - vec2(0.0, offset_2)/canvas_h).rgb * alpha_2;
   
   // Horizontal blur
   vec3 tc_h = texcolor.rgb * alpha_0;

   tc_h += Texel(texture, texture_coords + vec2(offset_1, 0.0)/canvas_w).rgb * alpha_1;
   tc_h += Texel(texture, texture_coords - vec2(offset_1, 0.0)/canvas_w).rgb * alpha_1;
   
   tc_h += Texel(texture, texture_coords + vec2(offset_2, 0.0)/canvas_w).rgb * alpha_2;
   tc_h += Texel(texture, texture_coords - vec2(offset_2, 0.0)/canvas_w).rgb * alpha_2;
   
   // Smooth
   vec3 extract = smoothstep(threshold * 0.7, threshold, luminance(texcolor.rgb)) * texcolor.rgb;
   return vec4(extract + tc_v * 0.8 + tc_h * 0.8, 1.0);
}]]
function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end
function checkIntersect(l1p1, l1p2, l2p1, l2p2)
	local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
	return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function lerp(a,b,t) return a+(b-a)*t end

local scene = lg.newCanvas()

function love.load()
	lg.setNewFont("assets/font.ttf", 16)
	min_dt = 1/60
	next_time = love.timer.getTime()
end

maxdt = 1
function love.update(dt)
	next_time = next_time + min_dt

	if dt > 0 then
        local tempdt = dt --you should rename this to something more useful, but for the sake of examples
         if tempdt > maxdt then tempdt = maxdt end
        --do your update stuff with tempdt instead of dt
		play:update(tempdt)
    end
end


function love.draw()
	lg.setCanvas(scene)
	play:draw()
	lg.setCanvas()
	lg.setColor(255, 255, 255)
	lg.setShader(bloom)
	lg.draw(scene)
	lg.setShader()
	play:drawus() -- draw unshadered
	lg.setColor(255, 255, 255)
	lg.print("FPS: " .. love.timer.getFPS())

	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

function love.keypressed(key)
	play:keypressed(key)
end
