WINDOW_W = 1280
WINDOW_H = 720

love.graphics.setDefaultFilter("nearest", "nearest")
lg = love.graphics--require ("lib.autobatch")
local play = require ("states.play")

local bloom = lg.newShader[[
extern vec2 size = vec2(1280, 720);
extern int samples = 5; // pixels per axis; higher = bigger glow, worse performance
extern float quality = 2.5; // lower = smaller glow, better quality

vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
{
  vec4 source = Texel(tex, tc);
  vec4 sum = vec4(0);
  int diff = (samples - 1) / 2;
  vec2 sizeFactor = vec2(1) / size * quality;
  
  for (int x = -diff; x <= diff; x++)
  {
    for (int y = -diff; y <= diff; y++)
    {
      vec2 offset = vec2(x, y) * sizeFactor;
      sum += Texel(tex, tc + offset);
    }
  }
  
  return ((sum / (samples * samples)) + source) * colour;
}]]
function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end
function checkIntersect(l1p1, l1p2, l2p1, l2p2)
	local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
	return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
function lerp(a,b,t) return a+(b-a)*t end
function inradius(x,y,cx,cy,r) return(x - cx)^2 + (y - cy)^2 < r^2 end

math.doLinesIntersect = function( a, b, c, d )
        -- parameter conversion
        local L1 = {X1=a.x,Y1=a.y,X2=b.x,Y2=b.y}
        local L2 = {X1=c.x,Y1=c.y,X2=d.x,Y2=d.y}
        
        -- Denominator for ua and ub are the same, so store this calculation
        local d = (L2.Y2 - L2.Y1) * (L1.X2 - L1.X1) - (L2.X2 - L2.X1) * (L1.Y2 - L1.Y1)
        
        -- Make sure there is not a division by zero - this also indicates that the lines are parallel.
        -- If n_a and n_b were both equal to zero the lines would be on top of each
        -- other (coincidental).  This check is not done because it is not
        -- necessary for this implementation (the parallel check accounts for this).
        if (d == 0) then
                return false
        end
        
        -- n_a and n_b are calculated as seperate values for readability
        local n_a = (L2.X2 - L2.X1) * (L1.Y1 - L2.Y1) - (L2.Y2 - L2.Y1) * (L1.X1 - L2.X1)
        local n_b = (L1.X2 - L1.X1) * (L1.Y1 - L2.Y1) - (L1.Y2 - L1.Y1) * (L1.X1 - L2.X1)
        
        -- Calculate the intermediate fractional point that the lines potentially intersect.
        local ua = n_a / d
        local ub = n_b / d
        
        -- The fractional point will be between 0 and 1 inclusive if the lines
        -- intersect.  If the fractional calculation is larger than 1 or smaller
        -- than 0 the lines would need to be longer to intersect.
        if (ua >= 0 and ua <= 1 and ub >= 0 and ub <= 1) then
                local x = L1.X1 + (ua * (L1.X2 - L1.X1))
                local y = L1.Y1 + (ua * (L1.Y2 - L1.Y1))
                return true, {x=x, y=y}
        end
        
        return false
end


local scene = lg.newCanvas()

function love.load()
	lg.setNewFont("assets/font.ttf", 16)
	min_dt = 1/60
	next_time = love.timer.getTime()
end


maxdt = 1
function love.update(dt)

  --PRESS F5 to dump performance stats
  if not ProFI_ENABLED and love.keyboard.isDown("f5") then ProFI_ENABLED = true; ProFI:start(); end

	next_time = next_time + min_dt
	if dt > 0 then
        local tempdt = dt --you should rename this to something more useful, but for the sake of examples
         if tempdt > maxdt then tempdt = maxdt end
        --do your update stuff with tempdt instead of dt
		play:update(tempdt)
    end
end

ProFI = require('lib.ProFI')
ProFI_ENABLED = false

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

  if ProFI_ENABLED then 
     ProFI:stop()
     ProFI:writeReport( 'performance.txt' )
     ProFI_ENABLED=false
  end

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

function love.keyreleased(key)
	play:keyreleased(key)
end

function love.mousepressed(x, y, b)
	play:mousepressed(x, y, b)
end

function love.mousereleased(x, y, b)
	play:mousereleased(x, y, b)
end

function love.mousemoved(x, y)
	play:mousemoved(x, y)
end

function love.textinput(text)
	play:textinput(text)
end
