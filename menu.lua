menu = {}

function menu:init()
	
end

function menu:enter()
	love.graphics.setBackgroundColor(0, 0, 0)
	-- Timer.add(2, function() Gamestate.switch(game) end)

	menu.currentWord = ''

	love.audio.setVolume(.3)

	menu.commandCorrect = false

end

function menu:update(dt)

	Timer.update(dt)

end

function menu:draw()
	love.graphics.setColor(color_white)
	love.graphics.setFont(titleFont)
	love.graphics.printf('TyPong', WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2 - 200, 0, 'center')
	-- love.graphics.rectangle('fill', WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, 10, 10)
	love.graphics.setFont(largeFont)
	love.graphics.print('Type \'play\' to get started!', 10, WINDOW_HEIGHT - 80)
	love.graphics.printf('Top Score: ' .. tostring(math.floor(HIGH_SCORE)), WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2 - 100, 0, 'center')

	if menu.commandCorrect then
		love.graphics.setColor(color_green)
	end
	love.graphics.print(menu.currentWord, 10, WINDOW_HEIGHT - 40)
end

function menu:keypressed(key)
	if key == 'backspace' then
		menu.currentWord = string.sub(menu.currentWord, 1, #menu.currentWord - 1)
		if #menu.currentWord > 0 then
			menu:checkWord()
		end
	elseif contains(letters, key) then

		sound_tw_arr[math.random(1, #sound_tw_arr)]:play()
		menu.currentWord = menu.currentWord .. key
		menu:checkWord()
	end
end

function menu:checkWord()
	if menu.currentWord == 'play' then
		menu.commandCorrect = true
		Timer.add(1, function() Gamestate.switch(game) end)
	elseif menu.currentWord == 'resetstats' then
		menu.commandCorrect = true
		Timer.add(1, setErrorsToDefault)
		Timer.add(1, function() menu:clearCurrentWord() end)
	end
end

function menu:clearCurrentWord()
	menu.currentWord = ''
end