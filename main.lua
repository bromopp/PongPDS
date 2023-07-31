Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'
require 'Projectile'

VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 858, 525 --fixed game resolution
WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
WINDOW_WIDTH, WINDOW_HEIGHT = WINDOW_WIDTH*.7, WINDOW_HEIGHT*.7 --make the window a bit smaller than the screen itself


function love.load()

	love.window.setTitle('Pong')

	math.randomseed(os.time())

	love.graphics.setDefaultFilter('nearest','nearest')

	smallFont = love.graphics.newFont('04B_30__.TTF', 14)
	scoreFont = love.graphics.newFont('PressStart2P.TTF', 22)
	fpsFont = love.graphics.newFont('PressStart2P.TTF', 7)
	victoryFont = love.graphics.newFont('04B_30__.TTF',32)
	push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT, {
		fullscreen = false,
		vsync = true,
		resizable = true
	})

	Player1Score = 0
	Player2Score = 0

	servingPlayer = math.random(2) == 1 and 1 or 2

	LeftPaddle = Paddle(40, VIRTUAL_HEIGHT/2, 10, 40)
	RightPaddle = Paddle(VIRTUAL_WIDTH - 50, VIRTUAL_HEIGHT/2, 10, 40)
	
	PADDLE_SPEED = 250

	Ball = Ball(VIRTUAL_WIDTH/2 -2, VIRTUAL_HEIGHT/2 -2, 10, 10)

	projectiles_table = {}
	GameState = 'start'

end

function love.resize(w, h)
	push:resize(w, h)
end

function love.update(dt)

	--score
		if Ball.x <= 0 then
			Player2Score = Player2Score + 1
			servingPlayer = 1
			Ball:reset()
			Ball.dx = 100	
			if Player2Score >= 3 then
				GameState = 'victory'
				winningPlayer = 2
			else
				GameState = 'serve'
			end
		end

		if Ball.x >= VIRTUAL_WIDTH - 10 then
			Player1Score = Player1Score + 1
			servingPlayer = 2
			Ball:reset()
			Ball.dx = -100
			if Player1Score >= 3 then
				GameState = 'victory'
				winningPlayer = 1
			else
				GameState = 'serve'
			end

		end
	--end

	if GameState ==  'play' then


	--Ball bounce
		if Ball:collides(LeftPaddle) then
			--deflect Ball to the right
			Ball.dx = -Ball.dx
			
		end

		if Ball:collides(RightPaddle) then
			--deflect Ball to the left
			Ball.dx = -Ball.dx
		end

		if Ball.y >= VIRTUAL_HEIGHT -10 then
			--deflect the Ball up
			Ball.dy = -Ball.dy
			Ball.y = VIRTUAL_HEIGHT - 10
		end

		if Ball.y <= 0 then
			--deflect the Ball down
			Ball.dy =-Ball.dy
			Ball.y = 0
		end
		--end
		LeftPaddle:update(dt)
		RightPaddle:update(dt)
	--region paddlemovement
		if love.keyboard.isDown('w') then
			LeftPaddle.dy = -PADDLE_SPEED
		elseif love.keyboard.isDown('s') then
			LeftPaddle.dy = PADDLE_SPEED
		else
			LeftPaddle.dy = 0
		end

		if love.keyboard.isDown('up') then
			RightPaddle.dy = -PADDLE_SPEED
		elseif love.keyboard.isDown('down')then
			RightPaddle.dy = PADDLE_SPEED
		else
			RightPaddle.dy = 0
		end
	--endregion
	--region Projectile
		if love.keyboard.isDown('1') and LeftPaddle.iceSpikeCD <= 0 then
			projectile = Projectile(LeftPaddle.x, LeftPaddle.y, 5, 5, 1)
			table.insert(projectiles_table, projectile)
			LeftPaddle.iceSpikeCD = 10
		end
		local removeIndices = {}
		for i,projectile in ipairs(projectiles_table) do
			projectile:update(dt)
			if projectile.isActive == false then
				table.insert(removeIndices, i)
			end
			if projectile.owner == 1 and projectile.collides(RightPaddle) then
				RightPaddle.freeztime = 3
			end
			 if projectile.owner == 2 and projectile.collides(LeftPaddle) then
				LeftPaddle.freeztime = 3
			end
		end
		for i = #removeIndices, 1 , -1 do
			table.remove(projectiles_table, removeIndices[i])
		end
		if LeftPaddle.iceSpikeCD > 0 then
			LeftPaddle.iceSpikeCD = LeftPaddle.iceSpikeCD - dt
		end
	--endregion

	
		Ball:update(dt)
	end
	if GameState == 'serve' then

		LeftPaddle.y = VIRTUAL_HEIGHT/2
		RightPaddle.y = VIRTUAL_HEIGHT/2 
	end

end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'enter' or key == 'return' then
		if GameState == 'start' then
			GameState = 'play'
		elseif GameState == 'play' then
			GameState = 'pause'
		elseif GameState == 'serve' then
			GameState = 'play'
		elseif GameState == 'pause' then
			GameState = 'play'
		elseif GameState == 'victory' then
			GameState = 'start'
			Player1Score = 0
			Player2Score = 0
		end
	end
end

function love.draw()
	push:apply('start')

	love.graphics.clear(40/255, 45/255, 52/255, 255/255)
--region rBall center
	Ball:render()
--endregion
--region rPaddles
	LeftPaddle:render()
	RightPaddle:render()
--endregion
	displayFPS()
--region rTitle
	love.graphics.setFont(smallFont)
	if GameState == 'start' then
		love.graphics.printf("Press Enter To Start", 0, 20, VIRTUAL_WIDTH, 'center')
	elseif GameState == 'serve'then
		displayScore()
		love.graphics.setFont(smallFont)
		love.graphics.printf("Player " .. tostring(servingPlayer), 0, VIRTUAL_HEIGHT/3 - 20, VIRTUAL_WIDTH, 'center')
		love.graphics.printf("Press Enter to Serve!", 0, VIRTUAL_HEIGHT/3, VIRTUAL_WIDTH, 'center')
	elseif GameState == 'play' or GameState == 'pause' then
		displayScore()
	elseif GameState == 'victory' then
		love.graphics.setFont(victoryFont)
		love.graphics.printf("Player " .. tostring(winningPlayer) .. " Wins!", 0, VIRTUAL_HEIGHT/3 - 40, VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(smallFont)
		love.graphics.printf("Press Enter to Restart!", 0, VIRTUAL_HEIGHT/3, VIRTUAL_WIDTH, 'center')
	end
--endregion
--region rProjectiles
	for _,projectile in ipairs(projectiles_table) do
		projectile:render()
	end
--endregion
	push:apply('end')
end

function displayFPS()
	love.graphics.setColor(0, 1, 0, 1/3)
	love.graphics.setFont(fpsFont)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS( )), 780, 10)
	love.graphics.setColor(1, 1, 1, 1)
end

function displayScore()
	love.graphics.setFont(scoreFont)	
	love.graphics.print(Player1Score, VIRTUAL_WIDTH/2 - 60, VIRTUAL_HEIGHT/12)
	love.graphics.print('-', VIRTUAL_WIDTH/2 - 15, VIRTUAL_HEIGHT/12)
	love.graphics.print(Player2Score, VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/12)
end