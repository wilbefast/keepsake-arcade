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

local w, h = 1024, 1280

local games = { }

local current_music = nil
function play_music(new_music)
	if current_music then
		current_music:stop()
	end
	new_music:play()
	new_music:setLooping(true)
	new_music:setVolume(1)
	current_music = new_music
end

function love.load(arg)

	-- set 'best' screen mode
 --  local modes = love.graphics.getModes()
 --  table.sort(modes, function(a, b) return (a.width*a.height > b.width*b.height) end)
 --  for i, m in ipairs(modes) do
 --    if love.graphics.setMode(m.width, m.height, true) then
 --    	w = m.width
 --    	h = m.height
 --    	break -- success !
	-- 	end
	-- end

	love.window.setMode(w, h, { fullscreen = true, borderless = true })

  -- initialise random
  math.randomseed(os.time())

  -- no mouse
  love.mouse.setVisible(false)

  -- load game files and flavour text
  games[1] = 
  {
  	executable_file = "love eggz/src",
  	preview_image = love.graphics.newImage("images/eggz.jpg"),
  	music = love.audio.newSource("music/eggz.ogg", "stream")
	}
  games[2] = 
  {
  	executable_file = "love-hg zweinflugger/src",
  	preview_image = love.graphics.newImage("images/zwein.png"),
  	music = love.audio.newSource("music/zwein.ogg", "stream")
	}
  games[3] = 
  {
  	executable_file = "love-hg zeroday/src",
  	preview_image = love.graphics.newImage("images/0day.png"),
  	music = love.audio.newSource("music/zeroday.ogg", "stream")
	}
  games[4] = 
  {
  	executable_file = "love-hg gecaye/src",
  	preview_image = love.graphics.newImage("images/gecshot.png"),
  	music = love.audio.newSource("music/colorintro.ogg", "stream")
	}

	-- play initial music
	play_music(games[1].music)

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
  elseif (key~="left") and (key~="right") then
  --elseif key=="return" then
  	if current_game_i == desired_game_i then
  		love.window.setMode(0, 0, { fullscreen = false, borderless = true })
  		current_music:stop()
	  		os.execute(games[current_game_i].executable_file)
  		current_music:play()
	  	love.window.setMode(w, h, { fullscreen = true, borderless = true })
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

  -- start switching left
  if love.keyboard.isDown("left") then
		desired_game_i = before(current_game_i)
	end

  -- start switching right
  if love.keyboard.isDown("right") then
		desired_game_i = after(current_game_i)
  end

	-- switch game in 1/3 second
	if desired_game_i ~= current_game_i then
		game_switch = game_switch + dt*3
		current_music:setVolume(1 - game_switch)

		if game_switch > 1 then
			current_game_i = desired_game_i
			game_switch = 0
			play_music(games[desired_game_i].music)
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
		love.graphics.draw(preview, 0, 0)
	else

			local next_preview = games[desired_game_i].preview_image

			if desired_game_i == before(current_game_i) then
				-- push current preview right
				love.graphics.draw(preview, game_switch*w, 0)
				love.graphics.draw(next_preview, -(1-game_switch)*w, 0)
			else
				-- push current preview left
				love.graphics.draw(preview, -game_switch*w, 0)
				love.graphics.draw(next_preview, (1-game_switch)*w, 0)
			end
	end


	-- debug console
	--log:draw()

end
