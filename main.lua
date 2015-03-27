require('words')
require('menu')
Gamestate = require('gamestate')
vector = require('vector')
Timer = require('timer')
Shake = require('shake')

local game = {}

local tickCounter = 0
local tickMax = 60

local letters = {
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
}

local errorsPerLetter = {
	{'a', 1000}, {'b', 1000}, {'c', 1000}, {'d', 1000}, {'e', 1000}, {'f', 1000}, {'g', 1000}, {'h', 1000}, {'i', 1000}, {'j', 1000}, {'k', 1000}, {'l', 1000}, {'m', 1000}, {'n', 1000}, {'o', 1000}, {'p', 1000}, {'q', 1000}, {'r', 1000}, {'s', 1000}, {'t', 1000}, {'u', 1000}, {'v', 1000}, {'w', 1000}, {'x', 1000}, {'y', 1000}, {'z', 1000}
}

local answerWord = ''
local currentWord = ''

local PADDLE_HEIGHT = 10
local PADDLE_WIDTH = 100

local cpu_paddle = {pos = vector(100, 0), vel = vector(0,0), accel = vector(0,0)}

local color_red = {255, 0, 0}
local color_green = {0, 255, 0}
local color_black = {0, 0, 0}
local color_white = {255, 255, 255}
local color_grey = {150, 150, 150}

nextLetter = ''

local wrong = false

local started = false

local debugMode = false

local wordCompleted = false

local gameIsOver = false

local cpuTargetX = 0

local SCORE = 0

mult = 1

xmult = 1

local wordStartTime = 0

local justHitCPU = false

function love.load()

	WINDOW_HEIGHT = 500
	WINDOW_WIDTH = 700

	-- Gamestate.registerEvents()
 --    Gamestate.switch(menu)

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {resizable=true, vsync=enableVsync, fsaa=4})
	love.window.setTitle('TyPong')
	love.graphics.setBackgroundColor(color_black)

	if love.filesystem.exists('errorsPerLetter.txt') and true then
		readErrors()
	end

	math.randomseed(os.time())

	getScoreOfWord('asshole')

	love.keyboard.setKeyRepeat( true )

	love.audio.setVolume(.3)

	Shake.reset()
	Shake.amplitude = 0.1

	-- answerWord = words[math.random(1, #words)]

	sound_bounce_arr = {
		love.audio.newSource('bounce1.mp3'),
		love.audio.newSource('bounce2.mp3')
	}

	sound_tw_arr = {
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
		love.audio.newSource('tw2.mp3'),
	}

	sound_lineend = love.audio.newSource('lineend.wav')

	sound_bounce_cpufail = love.audio.newSource('bounce3.mp3')

	ball = {pos = vector(WINDOW_WIDTH / 2, 100), vel = vector(0, math.random(100, 200) / -100), size = 10}
	if math.random(0,1) == 0 then
		ball.vel.x = math.random(-200, -100) / 100
	else
		ball.vel.x = math.random(100, 200) / 100
	end
	ball2 = {pos = ball.pos, vel = ball.vel, size = ball.size}
	
	largeFont = love.graphics.newFont('Courier_Prime_Bold.ttf', 26)
	normalFont = love.graphics.newFont(12)

	waitToStartCount = 3

	testBool = true

	xPos = 0
	newX = 0
	endXPos = xPos
	ratio = (newX - endXPos - PADDLE_WIDTH * .5) / (#answerWord)

	spawnNewSimBall()

	wordCompleted = false

	-- checkWord()

end

function love.resize(w, h)
	WINDOW_HEIGHT = h
	WINDOW_WIDTH = w
end

function love.update(dt)

	Shake.update(dt)

	Timer.update(dt)

	tickCounter = tickCounter + 1
	if tickCounter >= tickMax then
		tick()
		tickCounter = 0
	end

	if started and not gameIsOver then
		ball.pos = ball.pos + ball.vel
	end
	ball2.pos = ball2.pos + ball2.vel

	if ball.vel.y < 0 then
		if cpu_paddle.pos.x < cpuTargetX - PADDLE_WIDTH / 2 then
			cpu_paddle.vel.x = 5
		elseif cpu_paddle.pos.x > cpuTargetX - PADDLE_WIDTH / 2 then
			cpu_paddle.vel.x = -5
		else
			cpu_paddle.vel.x = 0
		end
	else
		cpuTargetX = ball.pos.x
		if cpu_paddle.pos.x < cpuTargetX - PADDLE_WIDTH / 2 then
			cpu_paddle.vel.x = 5
		elseif cpu_paddle.pos.x > cpuTargetX - PADDLE_WIDTH / 2 then
			cpu_paddle.vel.x = -5
		else
			cpu_paddle.vel.x = 0
		end
	end

	-- if cpu_paddle.pos.x > cpuTargetX - PADDLE_WIDTH / 2 + 5 or cpu_paddle.pos.x < cpuTargetX + PADDLE_WIDTH / 2 - 5 then
	if cpu_paddle.pos.x > cpuTargetX - PADDLE_WIDTH / 2 - 5 and cpu_paddle.pos.x < cpuTargetX - PADDLE_WIDTH / 2 + 5 then
		cpu_paddle.vel.x = 0
	end

	-- umass amherst
	-- 9-5 eastern 413 577 2610
	-- outreach@honors.umass.edu

	cpu_paddle.pos = cpu_paddle.pos + cpu_paddle.vel

	if cpu_paddle.pos.x < 0 then
		cpu_paddle.pos.x = 0
	elseif cpu_paddle.pos.x + PADDLE_WIDTH > WINDOW_WIDTH then
		cpu_paddle.pos.x = WINDOW_WIDTH - PADDLE_WIDTH
	end

	if ball.pos.x > WINDOW_WIDTH - ball.size then
		ball.vel.x = -ball.vel.x
		ball.pos.x = WINDOW_WIDTH - ball.size
		bounce()
	end

	if ball.pos.x < 0 then
		ball.pos.x = 0
		ball.vel.x = -ball.vel.x
		bounce()
	end

	if ball2.pos.x > WINDOW_WIDTH - ball2.size then
		ball2.pos.x = WINDOW_WIDTH - ball2.size
		ball2.vel.x = -ball2.vel.x
	end

	if ball2.pos.x < 0 then
		ball2.pos.x = 0
		ball2.vel.x = -ball2.vel.x
	end

	if testBool and ball2.pos.y > WINDOW_HEIGHT - 45 then
		testBool = false
		setNewTargetAndRatio()
	end

	if ball2.pos.y < 10 then
		cpuTargetX = ball2.pos.x - ball2.size / 2
	end

	--BOUNCE OFF OF PADDLE
	if ball.pos.y > WINDOW_HEIGHT - 40 - PADDLE_HEIGHT and isBallBetweenPaddle(ball, vector(xPos, 0)) then
		ball.pos.y = WINDOW_HEIGHT - 40 - PADDLE_HEIGHT
		bounce()
		xmult = math.random(75, 125) / (100)
		ball.vel = ball.vel * 1.2
		ball.vel.x = ball.vel.x * xmult
		ball.vel.y = -ball.vel.y
		spawnNewSimBall()
	end

	--BOUNCE OFF OF TOP
	if isBallBetweenPaddle(ball, cpu_paddle.pos) and not justHitCPU then
		if ball.pos.y < cpu_paddle.pos.y + PADDLE_HEIGHT then
			bounce()
			Shake.amplitude = 0.1
			ball.pos.y = cpu_paddle.pos.y + PADDLE_HEIGHT
			if ball.vel.y < 0 then
				ball.vel.y = -ball.vel.y
			end

			newWord()
			ratio = (newX - endXPos - PADDLE_WIDTH * .5) / (#answerWord)
			-- spawnNewSimBall()
		end
	else
		if ball.pos.y < 0 then
			sound_bounce_cpufail:play()
			justHitCPU = true
			SCORE = SCORE + 1000
			ball.pos.y = 0
			if ball.vel.y < 0 then
				ball.vel.y = -ball.vel.y
			end

			newWord()
			ratio = (newX - endXPos - PADDLE_WIDTH * .5) / (#answerWord)
			-- spawnNewSimBall()
		end
	end

	if ball.pos.y + ball.size > WINDOW_HEIGHT then
		gameOver()
	end
	

	if xPos < 0 then
		xPos = 0
	end

	if xPos > WINDOW_WIDTH - PADDLE_WIDTH then
		xPos = WINDOW_WIDTH - PADDLE_WIDTH
	end

	if ball2.pos.y < 0 then
		ball2.vel.y = -ball2.vel.y
		-- spawnNewSimBall()
	end

end

function love.draw()

	love.graphics.setColor(color_white)

	love.graphics.print(math.floor(SCORE), WINDOW_WIDTH / 2, WINDOW_HEIGHT - 22)
	-- love.graphics.print(nextLetter, WINDOW_WIDTH / 2, 200)

	if gameIsOver then
		love.graphics.print("FINAL SCORE", WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)
		love.graphics.print(math.floor(SCORE), WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2 + 40)
	end

	if not wordCompleted then
		love.graphics.print(answerWord, 10, 10)
	end
	-- love.graphics.print(progress, 10, 200)
	love.graphics.setFont(largeFont)

	Shake.preDraw()

	love.graphics.rectangle('fill', xPos, WINDOW_HEIGHT - 40, PADDLE_WIDTH, PADDLE_HEIGHT)
	love.graphics.rectangle('fill', cpu_paddle.pos.x, cpu_paddle.pos.y, PADDLE_WIDTH, PADDLE_HEIGHT)
	love.graphics.rectangle('fill', ball.pos.x, ball.pos.y, ball.size, ball.size)

	Shake.postDraw()

	if waitToStartCount > 0 then
		love.graphics.print(waitToStartCount, WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)
	end

	if debugMode then
		love.graphics.setColor(color_grey)
		love.graphics.rectangle('fill', ball2.pos.x, ball2.pos.y, ball2.size, ball2.size)
		love.graphics.rectangle('fill', newX, 0, 1, WINDOW_HEIGHT)
		love.graphics.rectangle('line', cpuTargetX, 0, 3, WINDOW_HEIGHT)
	end

	if wrong then
		love.graphics.setColor(color_red)
	else
		love.graphics.setColor(color_green)
	end
	if not wordCompleted then
		for x = 1, #currentWord, 1 do
			local letter = string.sub(currentWord, x, x)
			if letter == 'e' then
				love.graphics.print(letter, 10 + (x - 1) * 16, 38)
			else
				love.graphics.print(letter, 10 + (x - 1) * 16, 40)
			end

		end
		-- love.graphics.print(currentWord, 10, 30)
	end
	
end

function love.keypressed(key)
	if not gameIsOver then
		if key == 'backspace' then
			currentWord = string.sub(currentWord, 1, #currentWord - 1)
			if #currentWord > 0 then
				checkWord()
			end
		elseif contains(letters, key) then
			writeErrors()
			sound_tw_arr[math.random(1, #sound_tw_arr)]:play()
			currentWord = currentWord .. key
			if nextLetter ~= nil and nextLetter ~= '' then
				-- print(key, nextLetter)
				if key == nextLetter then
					letterCorrect(nextLetter)
				else
					letterIncorrect(nextLetter)
				end
			end
			checkWord()
			if currentWord == answerWord then
				Timer.add(.3, wordComplete)
			end
		end
	end
end

function love.quit()
	return false
end

function writeErrors()
	love.filesystem.remove('errorsPerLetter.txt')
	love.filesystem.write('errorsPerLetter.txt', '')
	for i, v in pairs(errorsPerLetter) do
		love.filesystem.append('errorsPerLetter.txt', v[2] .. '\n')
	end
end

function readErrors()
	local i = 1
	local curLetter = letters[i]
	for line in love.filesystem.lines("errorsPerLetter.txt") do

		errorsPerLetter[i][2] = line

		i = i + 1
		curLetter = letters[i]
	end
end

function getIndexByLetter(letter)
	for i,v in ipairs(errorsPerLetter) do
		if v[1] == letter then
			return i 
		end
	end
end

function letterCorrect(letter)
	errorsPerLetter[getIndexByLetter(letter)][2] = errorsPerLetter[getIndexByLetter(letter)][2] - 2
end

function letterIncorrect(letter)
	-- print(letter)
	errorsPerLetter[getIndexByLetter(letter)][2] = errorsPerLetter[getIndexByLetter(letter)][2] + 11
end

function wordComplete()
	sound_lineend:play()
	SCORE = SCORE + 100 * mult
	wordCompleted = true
	if ball.vel.y > 0 then
		mult = ((WINDOW_HEIGHT - 40 - ball.pos.y) / (WINDOW_HEIGHT - 40)) * 6
		if mult > 6 then
			mult = 6
		end
		if mult < 2 then
			mult = 2
		end
		ball.vel = ball.vel * mult
		Shake.amplitude = mult
	end
end

function newWord()
	wordStartTime = love.timer.getTime()
	ball.vel = ball.vel / mult
	currentWord = ''
	answerWord = selectNextWord()
	wordCompleted = false
	ratio = (newX - endXPos - PADDLE_WIDTH * .5) / (#answerWord)
	checkNextLetter()
end

function checkNextLetter()
	nextLetter = string.sub(answerWord, #currentWord + 1, #currentWord + 1)
end

function getNewX()
	return math.random(0, WINDOW_WIDTH - PADDLE_WIDTH)
end

function checkWord()
	selectNextWord()
	if string.sub(currentWord, 1, #currentWord) == string.sub(answerWord, 1, #currentWord) then
		wrong = false
		checkNextLetter()
		-- print(nextLetter)
		xPos = endXPos + #string.sub(currentWord, 1, #currentWord) * ratio
		-- progress = (#string.sub(currentWord, 1, #currentWord) * ratio) / newX
	else
		wrong = true
	end
end

function contains(table, value)
	for i,v in ipairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

function tick()
	if waitToStartCount <= 0 then
		start()
	else
		waitToStartCount = waitToStartCount - 1
	end
	justHitCPU = false
end

function start()
	started = true
end


function isBallBetweenPaddle(_ball, _paddle)
	local margin = 5
	if _ball.pos.x + _ball.size - margin >= _paddle.x and _ball.pos.x <= _paddle.x + PADDLE_WIDTH + margin then
		return true
	else
		return false
	end
end

function spawnNewSimBall()
	ball2.pos = ball.pos
	ball2.vel = ball.vel
	ball2.vel = ball2.vel * 2
	testBool = true
end

function setNewTargetAndRatio()
	newX = ball2.pos.x
	endXPos = xPos
	ratio = (newX - endXPos - PADDLE_WIDTH * .5) / (#answerWord)
end

function bounce(shake)
	sound_bounce_arr[math.random(1, #sound_bounce_arr)]:play()
	if true then
		Shake.more()
	end
end

function gameOver()
	gameIsOver = true
end

function getScoreOfWord(word)

	local score = 0

	for x = 1, string.len(word), 1 do
		score = score + errorsPerLetter[getIndexByLetter(word:sub(x,x))][2]
	end

	return score


end

function selectNextWord()

	local possibleWords = {}

	for i = 1, 3, 1 do
		possibleWords[i] = words[math.random(1, #words)]
		-- print(possibleWords[i])
	end

	local highestScore = -100
	local bestWord = possibleWords[1]

	for i,v in ipairs(possibleWords) do
		if getScoreOfWord(v) > highestScore then
			highestScore = getScoreOfWord(v) - #v * 5
			bestWord = v 
		end
	end

	-- print('BEST WORD', bestWord)

	return bestWord

end