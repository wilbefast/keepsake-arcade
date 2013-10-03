--[[---------------------------------------------------------------------------
DEBUG CONSOLE
--]]---------------------------------------------------------------------------

log = { "", "", "", "", "", "", "", "", "", "" }
function log:push(message)
	-- shift right
	for i = #self, 2, -1 do
		self[i] = self[i-1]
	end
	-- add to beginning
	self[1] = message
end

function log:draw()
	love.graphics.rectangle("line", 16, 16, 256, 32*#self + 16)
	for i = 1, #self do
		love.graphics.printf(self[i], 32, 32*i, 256)
	end
end

--[[---------------------------------------------------------------------------
LOAD RESOURCES
--]]---------------------------------------------------------------------------

local w, h = 0, 0

local games = { }

function love.load(arg)
	-- set 'best' screen mode
  local modes = love.graphics.getModes()
  table.sort(modes, function(a, b) return (a.width*a.height > b.width*b.height) end)
  for i, m in ipairs(modes) do
    if love.graphics.setMode(m.width, m.height, true) then
    	w = m.width
    	h = m.height
    	break -- success !
		end
	end

  -- initialise random
  math.randomseed(os.time())

  -- no mouse
  love.mouse.setVisible(false)

  -- load game files and flavour text
  games[1] = 
  {
  	executable_file = "EGGZ.exe",
  	flavour_text = "EGGZ is a game with eggz in it.",
  	preview_image = love.graphics.newImage("images/eggz.png")
	}
  games[2] = 
  {
  	executable_file = "Zweinflugger!.exe",
  	flavour_text = "pew pew pew pew pew pew pew pew ^_^",
  	preview_image = love.graphics.newImage("images/zwein.png")
	}

	-- log love.load
	log:push("love.load")

end


--[[---------------------------------------------------------------------------
MENU SELECTIONS
--]]---------------------------------------------------------------------------

local current_game_i = 1
local desired_game_i = 1
local game_switch = 0

local before = function(i)
  local result = i - 1
  if result < 1 then
    result = #games
  end
  return result
end

local after = function(i)
  local result = i + 1
  if result > #games then
    result = 1
  end
  return result
end

function love.keypressed(key, uni)

	-- exit the boot-loader
	--! SHOULD BE INACCESSIBLE TO THE PLAYERS
  if key=="escape" then
  	love.event.push("quit")

  -- launch the current game
  elseif key=="return" then
  	if game_switch == 0 then
	  	love.graphics.setMode(0, 0, false)
	  		os.execute(games[current_game_i].executable_file)
	  	love.graphics.setMode(w, h, true)
  	end

  -- switch left
  elseif key=="left" then
  	if game_switch == 0 then
  		desired_game_i = before(current_game_i)
  	end

  -- switch right
  elseif key=="right" then
  	if game_switch == 0 then
  		desired_game_i = after(current_game_i)
  	end
  end


  log:push("love.keypressed(" .. key .. ")")
end

function keyreleased(key, uni)
end

function love.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
end

function love.quit()
end


--[[---------------------------------------------------------------------------
PARTICLE EFFECTS
--]]---------------------------------------------------------------------------

local MAX_DT = 1/60
function love.update(dt)

	-- switch game in 1 second
	if desired_game_i ~= current_game_i then
		game_switch = game_switch + dt
		if game_switch > 1 then
			current_game_i = desired_game_i
			game_switch = 0
		end
	end


end


--[[---------------------------------------------------------------------------
RENDERING
--]]---------------------------------------------------------------------------

function love.draw()

	local preview = games[current_game_i].preview_image

	
	if game_switch == 0 then
		-- switch not currently taking place
		love.graphics.draw(preview, (w-preview:getWidth())/2, (h-preview:getHeight())/2)
	elseif game_switch < 0.5 then
		-- switching out old game
		love.graphics.setColor(255, 255, 255, 255*(1 - game_switch*2))
			love.graphics.draw(preview, (w-preview:getWidth())/2, (h-preview:getHeight())/2)
		love.graphics.setColor(255, 255, 255)
	else
		-- switching in new game
		local preview = games[desired_game_i].preview_image
		love.graphics.setColor(255, 255, 255, 255*(game_switch-0.5)*2)
			love.graphics.draw(preview, (w-preview:getWidth())/2, (h-preview:getHeight())/2)
		love.graphics.setColor(255, 255, 255)
	end


	-- debug console
	log:draw()

end
