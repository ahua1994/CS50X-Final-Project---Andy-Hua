local height = 194/4 - 0.5
local width = 130/4 - 0.5
local anim8 = require 'anim8'
local Dialove = require('Dialove')
player = {}
player.animations = {}
player.health = 100
player.dead = false
respawnX = love.graphics.getWidth()/2 + 100
respawnY = 1570
state = 1
deathTimer = 2
timer = 30
score = 0
knightOpacity = 1
opacity = 1
turn = false
turn2 = false
turn3 = false
turn5 = false
deathFont = love.graphics.newFont('PressStart2P-Regular.ttf', 16)
knightTimer = 17
firstDeath = 2
one = 1
demonTimer = 20
bossTimer = 120
bossfight = false
blackout = 1
change = false
stab = 0
distanceX = 0
distanceY = 0
bossDeath = 1
gameover = 1

function love.load()
    dialogManager = Dialove.init({
        font = love.graphics.newFont('PressStart2P-Regular.ttf', 16)
      })
     
    dialogManager:show({text = 'Brave hero, you are humanity\'s last hope. For too long we have grown weak and lazy under the kingdom\'s prosperity.', title = 'King'})
    dialogManager:push({text = 'Please fight for us so we can continue to stuff our faces.', title = 'King'})
    dialogManager:push({text = 'If all of our citizens die, we cannot collect any taxes. You will be in my prayers, hero.', title = 'Queen'})
    dialogManager:push({text = 'But if you die we will send the next foo-... I mean hero.', title = 'Queen'})
    dialogManager:push({text = 'Beware of the cat.', title = 'Guard 1'})
    dialogManager:push({text = 'Godspeed.', title = 'Guard 2'})
    
    sti = require 'sti'
    gameMap = sti('maps/castle.lua')
    camera = require 'camera'
    cam = camera()
    love.window.setMode(1080, 720)
    require("sound")
    require("NPCs")
    require("enemies")
    require("boss")
    wf = require "windfield"
    world = wf.newWorld()
    hero = love.graphics.newImage("Sprites/Hero.png")
    local grid = anim8.newGrid(width, height, (width + 0.5)*4, (height + 0.5)*4)
    sword = love.graphics.newImage("Sprites/Sword.png")
    orb = love.graphics.newImage("Sprites/Orb.png")
    player.animations.walkingDown = anim8.newAnimation(grid("1-4", 1), 0.125)
    player.animations.walkingUp = anim8.newAnimation(grid("1-4", 4), 0.125)
    player.animations.walkingLeft = anim8.newAnimation(grid("1-4", 2), 0.125)
    player.animations.walkingRight = anim8.newAnimation(grid("1-4", 3), 0.125)
    player.anim = player.animations.walkingUp
    world:addCollisionClass('player')
    world:addCollisionClass('npc')
    world:addCollisionClass('enemy')
    world:addCollisionClass('boss')
    player.collider = world:newCircleCollider(love.graphics.getWidth()/2, 360, 32)
    player.collider:setCollisionClass('player')
    npcs.knight.collider = world:newCircleCollider(love.graphics.getWidth()/2 - 200, 160, 36)
    npcs.knight.collider:setType('static')
    npcs.knight.collider:setCollisionClass('npc')
    guard = world:newCircleCollider(love.graphics.getWidth()/2 + 200, 160, 36)
    guard:setType('static')
    guard:setCollisionClass('npc')
    npcs.king.collider = world:newCircleCollider(love.graphics.getWidth()/2 + width, 160, 36)
    npcs.king.collider:setType('static')
    npcs.king.collider:setCollisionClass('npc')
    npcs.queen.collider = world:newCircleCollider(love.graphics.getWidth()/2 - width, 160, 36)
    npcs.queen.collider:setType('static')
    npcs.queen.collider:setCollisionClass('npc')
    npcs.pumpking.collider = world:newCircleCollider(3600, 1350, 35)
    npcs.pumpking.collider:setType('static')
    npcs.pumpking.collider:setCollisionClass('npc')
    npcs.zombride.collider = world:newCircleCollider(3710, 1350, 35)
    npcs.zombride.collider:setType('static')
    npcs.zombride.collider:setCollisionClass('npc')
    npcs.martianbuu.collider = world:newCircleCollider(3950, 1350, 35)
    npcs.martianbuu.collider:setType('static')
    npcs.martianbuu.collider:setCollisionClass('npc')
    npcs.george.collider = world:newCircleCollider(4060, 1350, 35)
    npcs.george.collider:setType('static')
    npcs.george.collider:setCollisionClass('npc')
    enemies.cat.collider = world:newCircleCollider(540, 1040, 25)
    enemies.cat.collider:setType('static')
    enemies.cat.collider:setCollisionClass('enemy')
    enemies.monster.collider = world:newCircleCollider(1630, 1520, 35)
    enemies.monster.collider:setType('static')
    enemies.monster.collider:setCollisionClass('enemy')
    enemies.monster2.collider = world:newCircleCollider(1275, 1330, 35)
    enemies.monster2.collider:setType('static')
    enemies.monster2.collider:setCollisionClass('enemy')
    enemies.monster3.collider = world:newCircleCollider(3250, 1630, 35)
    enemies.monster3.collider:setType('static')
    enemies.monster3.collider:setCollisionClass('enemy')
    enemies.monster4.collider = world:newCircleCollider(2900, 1700, 35)
    enemies.monster4.collider:setType('static')
    enemies.monster4.collider:setCollisionClass('enemy')
    enemies.monster5.collider = world:newCircleCollider(2000, 1290, 35)
    enemies.monster5.collider:setType('static')
    enemies.monster5.collider:setCollisionClass('enemy')
    boss.collider = world:newCircleCollider(3805+24, 150, 60)
    boss.collider:setCollisionClass('boss')
    boss.collider:setType('static')

    walls = {}
    if gameMap.layers["Objects"] then
       for i, obj in pairs(gameMap.layers["Objects"].objects) do
           local wall = world:newRectangleCollider(obj.x*2.1, obj.y*2.1, obj.width*2.1, obj.height*2.1)   
           wall:setType("static")
           table.insert(walls, wall)       
       end 
    end  

end

function love.update(dt)

    dialogManager:update(dt)

    if timer > 0 then
        timer = timer - dt
    end

    vectorX = 0
    vectorY = 0

    world:update(dt)

    boss.anim.standing:update(dt)
    npcs.pumpking.anim:update(dt)
    npcs.zombride.anim:update(dt)
    npcs.martianbuu.anim:update(dt)
    npcs.george.anim:update(dt)
    enemies.cat.anim:update(dt)
    enemies.monster.anim:update(dt) 
    enemies.monster2.anim:update(dt) 
    enemies.monster3.anim:update(dt) 
    enemies.monster4.anim:update(dt)
    enemies.monster5.anim:update(dt)

    if timer <= 10 and player.dead == false and firstDeath ~= 1 and bossTimer > 55 then

        if love.keyboard.isDown('up') then
            vectorY = -1
            player.anim = player.animations.walkingUp
            player.dir = 'up'
        end    

        if love.keyboard.isDown('down') then
            vectorY = 1
            player.anim = player.animations.walkingDown
            player.dir = 'down'
        end   

        if love.keyboard.isDown('left') then
            vectorX = -1
            player.anim = player.animations.walkingLeft 
            player.dir = 'left'  
        end  

        if love.keyboard.isDown('right') then
            vectorX = 1
            player.anim = player.animations.walkingRight
            player.dir = 'right'
        end    

        player.collider:setLinearVelocity(280 * vectorX, 280 * vectorY)
        
    end

    if state == 1 then
        sounds.Castle:play()
    end
    
    if state > 1 and state < 5 then
        sounds.Castle:stop()
        sounds.Walk:play()
    end    

    if state == 4 then
        player.collider:setX(3830)
        player.collider:setY(1420)
    end

    if state == 5 and bossfight == true then
        sounds.Walk:stop()
        player.collider:setX(3830)
        player.collider:setY(360)
    end    

    if vectorX == 0 and vectorY == 0 then
        player.anim:gotoFrame(3)
    else 
        player.anim:update(dt)
    end  
     
    cam:lookAt(player.collider:getX(), player.collider:getY())
    if cam.x < love.graphics.getWidth()/2 then
        cam.x = love.graphics.getWidth()/2
    end    
    if cam.y < love.graphics.getHeight()/2 then
        cam.y = love.graphics.getHeight()/2
    end
    if cam.x > ((gameMap.width * gameMap.tilewidth)*2.1 - love.graphics.getWidth()/2) then
        cam.x = ((gameMap.width * gameMap.tilewidth)*2.1 - love.graphics.getWidth()/2) 
    end
    if cam.y > ((gameMap.height * gameMap.tileheight)*2.1 - love.graphics.getHeight()/2) then
        cam.y = ((gameMap.height * gameMap.tileheight)*2.1 - love.graphics.getHeight()/2)
    end            

    
    if enemies.monster.collider:getX() <= 1630 or enemies.monster.collider:getX() < 3000 and turn == false then
        enemies.monster.collider:setX(enemies.monster.collider:getX() + (280 * dt))
    elseif enemies.monster.collider:getX() > 3000 or enemies.monster.collider:getX() < 1630 then 
        turn = true
    end  
    if turn == true then      
        enemies.monster.collider:setX(enemies.monster.collider:getX() - (280 * dt))
        if enemies.monster.collider:getX() <= 1630 then
            turn = false
        end 
    end

    if enemies.monster2.collider:getY() <= 1320 or enemies.monster2.collider:getY() < 1700 and turn2 == false then
        enemies.monster2.collider:setY(enemies.monster2.collider:getY() + (240 * dt))
    elseif enemies.monster2.collider:getY() > 1700 or enemies.monster2.collider:getY() < 1320 then 
        turn2 = true
    end  
    if turn2 == true then      
        enemies.monster2.collider:setY(enemies.monster2.collider:getY() - (240 * dt))
        if enemies.monster2.collider:getY() <= 1320 then
            turn2 = false
        end 
    end

    if enemies.monster3.collider:getY() <= 1250 or enemies.monster3.collider:getY() < 1650 and turn3 == false then
        enemies.monster3.collider:setY(enemies.monster3.collider:getY() + (240 * dt))
    elseif enemies.monster3.collider:getY() > 1250 or enemies.monster3.collider:getY() < 1650 then 
        turn3 = true
    end  
    if turn3 == true then      
        enemies.monster3.collider:setY(enemies.monster3.collider:getY() - (240 * dt))
        if enemies.monster3.collider:getY() <= 1250 then
            turn3 = false
        end 
    end

    if enemies.monster4.collider:getX() <= 1660 or enemies.monster4.collider:getX() < 3000 and turn4 == false then
        enemies.monster4.collider:setX(enemies.monster4.collider:getX() + (280 * dt))
    elseif enemies.monster4.collider:getX() > 1660 or enemies.monster4.collider:getX() < 3000 then 
        turn4 = true
    end  
    if turn4 == true then      
        enemies.monster4.collider:setX(enemies.monster4.collider:getX() - (280 * dt))
        if enemies.monster4.collider:getX() <= 1660 then
            turn4 = false
        end 
    end

    if enemies.monster5.collider:getX() <= 1660 or enemies.monster5.collider:getX() < 3000 and turn5 == false then
        enemies.monster5.collider:setX(enemies.monster5.collider:getX() + (280 * dt))
    elseif enemies.monster5.collider:getX() > 1660 or enemies.monster5.collider:getX() < 3000 then 
        turn5 = true
    end  
    if turn5 == true then      
        enemies.monster5.collider:setX(enemies.monster5.collider:getX() - (280 * dt))
        if enemies.monster5.collider:getX() <= 1660 then
            turn5 = false
        end 
    end



    local catColliders = world:queryCircleArea(enemies.cat.collider:getX(), enemies.cat.collider:getY(), 60, {'player'})
    if #catColliders > 0 and bossfight == false then
        player.dead = true
        firstDeath = one 
    end

    deathTimer = 2

    local monsterColliders = world:queryCircleArea(enemies.monster.collider:getX(), enemies.monster.collider:getY(), 60, {'player'})
    if #monsterColliders > 0 then
        player.dead = true
    end

    local monster2Colliders = world:queryCircleArea(enemies.monster2.collider:getX(), enemies.monster2.collider:getY(), 60, {'player'})
    if #monster2Colliders > 0 then
        player.dead = true
    end

    local monster3Colliders = world:queryCircleArea(enemies.monster3.collider:getX(), enemies.monster3.collider:getY(), 60, {'player'})
    if #monster3Colliders > 0 then
        player.dead = true
    end

    local monster4Colliders = world:queryCircleArea(enemies.monster4.collider:getX(), enemies.monster4.collider:getY(), 60, {'player'})
    if #monster4Colliders > 0 then
        player.dead = true
    end

    local monster5Colliders = world:queryCircleArea(enemies.monster5.collider:getX(), enemies.monster5.collider:getY(), 60, {'player'})
    if #monster5Colliders > 0 then
        player.dead = true
    end

    if state == 1 and timer <= 0 then
        enemies.cat.collider:setX((player.collider:getX() + enemies.cat.collider:getX())/2 - (50 * dt))
        enemies.cat.collider:setY((player.collider:getY() + enemies.cat.collider:getY())/2 - (50 * dt))
    end

    if knightTimer < 17 and change == false then
        blackout = blackout - dt/3
        if blackout < -0.1 then
            change = true
        end     
    end
    if blackout <= 1 and change == true then
        blackout = blackout + dt/2.5
    end     

    if bossTimer < 100 and bossTimer > 94 and stab < 36 then
        stab = stab + dt*9
    end    

    if opacity < 1 and opacity > 0.95 then
        sounds.Death:play()
    end

    if player.dead == true then
        opacity = opacity - (dt / 5)
        if opacity < 0.4 then 
            state = 2
            player.collider:setX(respawnX) 
            player.collider:setY(respawnY)
            player.anim = player.animations.walkingUp
            opacity = 1
        end    
    end

    if state == 2 and player.dead == true then 
        player.dead = false 
        enemies.cat.collider:setX(540) 
        enemies.cat.collider:setY(1040)
        enemies.cat.anim = enemies.cat.down
        state = 3 
    end

    if firstDeath == 1 then
        vectorX = 0
        vectorY = 0
        knightTimer = knightTimer - dt
        if knightTimer <= 0 then
            firstDeath = 0 
        end
    end

    

    if firstDeath < 1 and knightOpacity > 0 then
        knightOpacity = knightOpacity - (dt / 3.5)
        if knightOpacity < 1 and knightOpacity > 0.95 then
            sounds.Death:play()
        end
    end    

    if player.collider:getX() > 3777 and player.collider:getY() < 1450 and demonTimer > 0 then
        state = 4
        demonTimer = demonTimer - (dt)
        if demonTimer <= 0 then
            state = 5
        end    
    end

    if player.collider:getX() < 3980 and player.collider:getX() > 3650 and player.collider:getY() <= 360 and state == 5 and bossTimer >= 0 then
        bossTimer = bossTimer - dt
        if bossTimer > 56 then
            bossfight = true
        end
        player.anim = player.animations.walkingUp 
    end  

    if bossfight == true then  
        sounds.Battle:play()
    end 

    distance = 0

    if bossTimer < 81 and bossTimer > 75 and boss.collider:getY() < 250 then 
        distance = distance + dt * 35
        boss.collider:setY(boss.collider:getY() + distance)
    end    

    if bossTimer < 66 and bossTimer > 63 then
        distanceX = distanceX + 50*dt
        distanceY = distanceY + 200*dt
    end
    if bossTimer < 66 and bossTimer > 63 then
        enemies.cat.collider:setX(4065 - distanceX)
        enemies.cat.collider:setY(870 - distanceY)
        enemies.cat.anim = enemies.cat.left
        if bossTimer < 63.5 and bossTimer > 63 then
            sounds.Slash:play() 
        end 
    end
    if bossTimer < 63 and bossDeath >= 0 then
        bossDeath = bossDeath - (dt / 3.5)
        if bossTimer > 62.5 then 
            sounds.Death:play()
        end
    end 
    if bossTimer < 1 then 
        love.event.quit()
    end

    if bossTimer < 55 and gameover >= 0 then
        bossfight = false
        sounds.Battle:stop()  
        sounds.Victory:play()   
        gameover = gameover - (dt / 5)
    end
    --if state == 2 then (crashes for some reason I don't get it)
        --player.dead = false 
        --dialogManager:show({text = 'You have been defeated'})
        --state = 3 
    --end
    --if player.collider:getX() > 3600 and player.collider:getY() < 1450 and state == 3 then
        --dialogManager:show({text = 'It is breaktime for us, so we are doing aerobics.', title = 'Pumpking'})
        --dialogManager:push({text = 'The sun on my skin... I almost feel alive!', title = 'Zombride'})
        --dialogManager:push({text = 'I\'m on break, so don\'t do anything to get me fired!', title = 'Martian Buu'})
        --dialogManager:push({text = 'My mom told me to find a job, so I applied here.', title = 'George'})
        --state = 4
    --end      (also crashes)

end
 
function love.draw()

    cam:attach()
        if knightTimer < 17 and knightTimer > 11 then
            love.graphics.setColor(255,255,255,blackout)
        end     
        love.graphics.push()
            love.graphics.scale(2.1)
                gameMap:drawLayer(gameMap.layers["FloorWall"])
                gameMap:drawLayer(gameMap.layers["Water"])
                gameMap:drawLayer(gameMap.layers["Props"])
                gameMap:drawLayer(gameMap.layers["Candles"])
        love.graphics.pop()        
        npcs.knight.anim:draw(npcs.knight.sprite, npcs.knight.collider:getX() - width, 
            npcs.knight.collider:getY() - height, 0, 2, 2)
        npcs.knight.anim:draw(npcs.knight.sprite, love.graphics.getWidth()/2 + 200 - width, 
            npcs.knight.collider:getY() - height, 0, 2, 2)
        npcs.king.anim:draw(npcs.king.sprite, npcs.king.collider:getX() - width, 
            npcs.king.collider:getY() - height, 0, 2, 2)
        npcs.queen.anim:draw(npcs.queen.sprite, npcs.queen.collider:getX() - width, 
            npcs.queen.collider:getY() - height, 0, 2, 2)
        npcs.pumpking.anim:draw(npcs.pumpking.sprite, npcs.pumpking.collider:getX() - 32,
            npcs.pumpking.collider:getY() - 32, 0, 2, 2)
        npcs.zombride.anim:draw(npcs.zombride.sprite, npcs.zombride.collider:getX() - 32,
            npcs.zombride.collider:getY() - 32, 0, 2, 2)
        npcs.martianbuu.anim:draw(npcs.martianbuu.sprite, npcs.martianbuu.collider:getX() - 32,
            npcs.martianbuu.collider:getY() - 32, 0, 2, 2)
        npcs.george.anim:draw(npcs.george.sprite, npcs.george.collider:getX() - 32,
            npcs.george.collider:getY() - 32, 0, 2, 2)    
        if bossDeath < 1 then
            love.graphics.setColor(255,255,255,bossDeath) 
        end  
        boss.anim.standing:draw(boss.sprite, boss.collider:getX() - 96, 
            boss.collider:getY() - 96, 0, 2, 2)
        love.graphics.setColor(255,255,255,1) 
        enemies.cat.anim:draw(enemies.cat.sprite, enemies.cat.collider:getX() - 32, 
            enemies.cat.collider:getY() - 32, 0, 2, 2)
        enemies.monster.anim:draw(enemies.monster.sprite, enemies.monster.collider:getX() - 32, 
            enemies.monster.collider:getY() - 32, 0, 2, 2)  
        enemies.monster2.anim:draw(enemies.monster2.sprite, enemies.monster2.collider:getX() - 32, 
            enemies.monster2.collider:getY() - 32, 0, 2, 2)
        enemies.monster3.anim:draw(enemies.monster3.sprite, enemies.monster3.collider:getX() - 32, 
            enemies.monster3.collider:getY() - 32, 0, 2, 2) 
        enemies.monster4.anim:draw(enemies.monster4.sprite, enemies.monster4.collider:getX() - 32, 
            enemies.monster4.collider:getY() - 32, 0, 2, 2) 
        enemies.monster5.anim:draw(enemies.monster5.sprite, enemies.monster5.collider:getX() - 32, 
            enemies.monster5.collider:getY() - 32, 0, 2, 2)      
        if player.dead == true then
            love.graphics.setColor(255,255,255,opacity)
        end         
        player.anim:draw(hero, player.collider:getX() - width, 
            player.collider:getY() - height, 0, 2, 2)
        love.graphics.setColor(255,255,255,1)    
        if knightTimer <= 1 then
            love.graphics.setColor(255,255,255,knightOpacity)
        end 
        npcs.knight.anim:draw(npcs.knight.sprite, respawnX - width, 
            respawnY - 155, 0, 2, 2)    
        --world:draw()
        love.graphics.setColor(255,255,255,1)
    cam:detach()
    love.graphics.push()
        love.graphics.scale(1.15)
        dialogManager:draw()
    love.graphics.pop()
    love.graphics.setFont(deathFont, 16)
    --love.graphics.print(player.collider:getX(), 0, 0, 0, 2)
    --love.graphics.print(player.collider:getY(), 0, 50, 0, 2)
    --love.graphics.print(enemies.cat.collider:getX(), 0, 100, 0, 2)
    --love.graphics.print(enemies.cat.collider:getY(), 0, 150, 0, 2)
    --love.graphics.print(bossTimer, 0, 200, 0, 2)
    if opacity ~= 1 then
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("You have been defeated", love.graphics.getWidth()/3 - 111, love.graphics.getHeight() - 200, 0, 1.5)
    end  
    if knightTimer > 1 and firstDeath == 1 and opacity == 1 then
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Knight", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("You've been in a coma for a week. 'Twas", love.graphics.getWidth()/3 - 215, love.graphics.getHeight() - 220, 0, 1.2)
        love.graphics.print("a most valiant battle against that cat!", love.graphics.getWidth()/3 - 215, love.graphics.getHeight() - 190, 0, 1.2)
        love.graphics.print("I am the strongest knight in the", love.graphics.getWidth()/3 - 215, love.graphics.getHeight() - 160, 0, 1.2)
        love.graphics.print("kingdom, allow me to aid in your journey.", love.graphics.getWidth()/3 - 215, love.graphics.getHeight() - 130, 0, 1.2)
    end
    if knightTimer <= 1 and knightOpacity > 0 then
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Knight has died from sun exposure", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 200, 0, 1.5)
    end    
    if demonTimer < 20 and demonTimer > 15 then
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Pumpking", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("It is breaktime for us,", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 220, 0, 1.2)
        love.graphics.print("so we are doing aerobics.", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 190, 0, 1.2)
    end
    if demonTimer < 15 and demonTimer > 10 then
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Zombride", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("The sun on my skin...", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 220, 0, 1.2)
        love.graphics.print("I almost feel alive!", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 190, 0, 1.2)
    end  
    if demonTimer < 10 and demonTimer > 5 then
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Martian Bu", love.graphics.getWidth()/3 - 228, love.graphics.getHeight() - 308, 0, 1.35)
        love.graphics.print("I'm on break, so don't do", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 220, 0, 1.2)
        love.graphics.print("anything to get me fired!", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 190, 0, 1.2)
    end
    if demonTimer < 5 and demonTimer >= 0 then
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("George", love.graphics.getWidth()/3 - 190, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("My mom told me to find a job,", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 220, 0, 1.2)
        love.graphics.print("so I applied to the local", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 190, 0, 1.2)
        love.graphics.print("demon castle.", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 160, 0, 1.2)
    end  
    if bossTimer < 52 then
        love.graphics.print("Thanks For Playing!!", 80, 80, 0, 3) 
        love.graphics.print("You Are The Hero!!", 140, 180, 0, 3)
        love.graphics.print("RPG Where", 100, 300, 0, 2)
        love.graphics.print("Everyone", 100, 360, 0, 2)
        love.graphics.print("Is Useless", 100, 420, 0, 2)
        love.graphics.print("- By Andy Hua", 100, 480, 0, 2)
        love.graphics.print("Credits in the", 100, 540, 0, 2)
        love.graphics.print("README.md", 100, 600, 0, 2)
    end    
    if bossTimer < 120 and bossTimer > 55 then
        love.graphics.print("Hero", 240, 140, 0, 1.4)
        love.graphics.print("Laplace", 790, 140, 0, 1.4)
    end
    if bossTimer < 120 and bossTimer > 111 then
        love.graphics.draw(healthbar_full, 200, 100, 0, 1)
        love.graphics.draw(healthbar_full, 780, 100, 0, 1)
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Laplace", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("So... someone has finally made it.", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 220, 0, 1.2)
        love.graphics.print("To have come this far... you must've", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 190, 0, 1.2)
        love.graphics.print("defeated my minions and 4 Demon Lords.", love.graphics.getWidth()/3 - 165, love.graphics.getHeight() - 160, 0, 1.2)
    end  
    if bossTimer < 111 and bossTimer > 106 then
        love.graphics.draw(healthbar_full, 200, 100, 0, 1)
        love.graphics.draw(healthbar_full, 780, 100, 0, 1)
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Laplace", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("From your exp, skills and power-ups,", love.graphics.getWidth()/3 - 185, love.graphics.getHeight() - 220, 0, 1.2)
        love.graphics.print("your abilities must surpass my own.", love.graphics.getWidth()/3 - 185, love.graphics.getHeight() - 190, 0, 1.2)
        love.graphics.print("That is precisely why you will lose!", love.graphics.getWidth()/3 - 185, love.graphics.getHeight() - 160, 0, 1.2)
    end 
    if bossTimer < 106 and bossTimer > 100 then
        love.graphics.draw(healthbar_full, 200, 100, 0, 1)
        love.graphics.draw(healthbar_full, 780, 100, 0, 1)
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Laplace", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("From your exp, skills and power-ups,", love.graphics.getWidth()/3 - 185, love.graphics.getHeight() - 220, 0, 1.2)
        love.graphics.print("your abilities must surpass my own.", love.graphics.getWidth()/3 - 185, love.graphics.getHeight() - 190, 0, 1.2)
        love.graphics.print("That is precisely why you will lose!", love.graphics.getWidth()/3 - 185, love.graphics.getHeight() - 160, 0, 1.2)
    end  
    if bossTimer < 100 and bossTimer > 94 then
        love.graphics.draw(healthbar_full, 200, 100, 0, 1)
        if bossTimer < 100 and bossTimer > 99.5 then
            sounds.Sword:play()
        end
        if bossTimer < 100 and bossTimer > 96 then
            love.graphics.draw(healthbar_full, 780, 100, 0, 1)
        elseif bossTimer < 96 and bossTimer > 94 then   
            love.graphics.draw(healthbar_empty, 780, 100, 0, 1)
        end    
        love.graphics.draw(sword, love.graphics.getWidth()/2 + 24, love.graphics.getHeight()/2 - 170 - stab, 0, 0.25) 
        if bossTimer < 96.5 and bossTimer > 94 then
            if bossTimer < 96.5 and bossTimer > 96 then
                sounds.Stab:play()
            end
            love.graphics.draw(blood, love.graphics.getWidth()/2 + 20, love.graphics.getHeight()/2 - 220, 0, 0.20)
        end    
    end   
    if bossTimer < 94 and bossTimer > 89 then
        love.graphics.draw(healthbar_full, 200, 100, 0, 1)
        love.graphics.draw(healthbar_empty, 780, 100, 0, 1)
        love.graphics.draw(sword, love.graphics.getWidth()/2 + 24, love.graphics.getHeight()/2 - 170 - stab, 0, 0.25) 
        love.graphics.draw(blood, love.graphics.getWidth()/2 + 20, love.graphics.getHeight()/2 - 220, 0, 0.20)
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Laplace", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("HAHAHAHAHAHAHAHA!!!", love.graphics.getWidth()/3 - 190, love.graphics.getHeight() - 210, 0, 1.4)
        love.graphics.print("*cough* *cough*", love.graphics.getWidth()/3 - 190, love.graphics.getHeight() - 170, 0, 1.4)
    end 
    if bossTimer < 89 and bossTimer > 81 then
        if bossTimer < 89 and bossTimer > 84 then
            love.graphics.draw(healthbar_full, 200, 100, 0, 1)
        elseif bossTimer < 84 and bossTimer > 81 then
            love.graphics.draw(healthbar_empty, 200, 100, 0, 1)
        end    
        if bossTimer < 89 and bossTimer > 84 then
            love.graphics.draw(healthbar_empty, 780, 100, 0, 1)
        elseif bossTimer < 84 and bossTimer > 81 then
            if bossTimer < 84 and bossTimer > 83 then
                sounds.Orb:play()
            end
            love.graphics.draw(healthbar_full, 780, 100, 0, 1)
        end     
        love.graphics.draw(orb, love.graphics.getWidth()/2 - 10, love.graphics.getHeight()/2 - 130, 0, 0.6)
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Laplace", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("With this Orb of Permutation, our", love.graphics.getWidth()/3 - 185, love.graphics.getHeight() - 220, 0, 1.2)
        love.graphics.print("stats will be temporarily swapped!", love.graphics.getWidth()/3 - 185, love.graphics.getHeight() - 190, 0, 1.2)
    end
    if bossTimer < 81 and bossTimer > 75 then
        love.graphics.draw(healthbar_empty, 200, 100, 0, 1)
        love.graphics.draw(healthbar_full, 780, 100, 0, 1)
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Laplace", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("HAHAHAHAHA!", love.graphics.getWidth()/3 - 190, love.graphics.getHeight() - 210, 0, 1.4)
        love.graphics.print("NOW DIE!", love.graphics.getWidth()/3 - 190, love.graphics.getHeight() - 170, 0, 1.4)
    end
    if bossTimer < 75 and bossTimer > 72 then
        love.graphics.draw(healthbar_empty, 200, 100, 0, 1)
        love.graphics.draw(healthbar_full, 780, 100, 0, 1)
    end    
    if bossTimer < 75 and bossTimer > 74 then
        slash.anim:draw(slash.sprite, love.graphics.getWidth()/2 - 45, love.graphics.getHeight()/2 - 90, 0, 1)
        sounds.Slash:play() 
    elseif bossTimer < 73 and bossTimer > 72 then
        slash.anim:draw(slash.sprite, love.graphics.getWidth()/2 - 45, love.graphics.getHeight()/2 - 90, 0, 1) 
        sounds.Slash:play()  
    end    
    if bossTimer < 72 and bossTimer > 69 then
        love.graphics.draw(healthbar_empty, 200, 100, 0, 1)
        love.graphics.draw(healthbar_full, 780, 100, 0, 1)
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Laplace", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("HAHAHA...hahaha...huh!?", love.graphics.getWidth()/3 - 190, love.graphics.getHeight() - 210, 0, 1.4)
    end
    if bossTimer < 69 and bossTimer > 63 then
        love.graphics.draw(healthbar_empty, 200, 100, 0, 1)
        love.graphics.draw(healthbar_full, 780, 100, 0, 1)
        love.graphics.draw(npcs.dialogBox, -10, 60, 0, 0.65)
        love.graphics.print("Laplace", love.graphics.getWidth()/3 - 210, love.graphics.getHeight() - 308, 0, 1.4)
        love.graphics.print("What!? Impossible!?", love.graphics.getWidth()/3 - 190, love.graphics.getHeight() - 220, 0, 1.4)
        love.graphics.print("How are you unscathed!? Do I not", love.graphics.getWidth()/3 - 190, love.graphics.getHeight() - 180, 0, 1.4)
        love.graphics.print("wield your heroic strength!?", love.graphics.getWidth()/3 - 190, love.graphics.getHeight() - 140, 0, 1.4)
    end
    if bossTimer < 63 and bossTimer > 55 then
        love.graphics.draw(healthbar_empty, 200, 100, 0, 1)
        love.graphics.draw(healthbar_empty, 780, 100, 0, 1)
        if bossTimer > 62.5 then
            slash.anim:draw(slash.sprite, love.graphics.getWidth()/2 + 5, love.graphics.getHeight()/2 - 170, 0, 1)
        end    
    end 
    if bossTimer < 55 then
        love.graphics.setColor(255,255,255,gameover)
    end
end

function love.keypressed(key)
    if key == 'a' then
        dialogManager:pop()
    --elseif key == 'b' then
        --dialogManager:complete()  
    end
end