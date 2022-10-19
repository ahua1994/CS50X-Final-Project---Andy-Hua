wf = require "windfield"
world = wf.newWorld()
local anim8 = require 'anim8'

enemies = {}
enemies.cat = {}
enemies.monster = {}
enemies.monster2 = {}
enemies.monster3 = {}
enemies.monster4 = {}
enemies.monster5 = {}

enemies.cat.sprite = love.graphics.newImage("Sprites/Cat.png")
enemies.monster.sprite = love.graphics.newImage("Sprites/Enemy.png")
enemies.monster2.sprite = enemies.monster.sprite
enemies.monster3.sprite = enemies.monster.sprite
enemies.monster4.sprite = enemies.monster.sprite
enemies.monster5.sprite = enemies.monster.sprite

local height = 194/4 - 0.5
local width = 130/4 - 0.5
grid2 = anim8.newGrid(32, 32, 96, 128)

enemies.cat.down = anim8.newAnimation(grid2("1-3", 1), 0.35)
enemies.cat.up = anim8.newAnimation(grid2("1-3", 4), 0.35)
enemies.cat.left = anim8.newAnimation(grid2("1-3", 2), 0.35)
enemies.cat.anim = enemies.cat.up
enemies.monster.anim = anim8.newAnimation(grid2("1-3", 1), 0.65)
enemies.monster2.anim = anim8.newAnimation(grid2("1-3", 1), 0.65)
enemies.monster3.anim = anim8.newAnimation(grid2("1-3", 1), 0.65)
enemies.monster4.anim = anim8.newAnimation(grid2("1-3", 1), 0.65)
enemies.monster5.anim = anim8.newAnimation(grid2("1-3", 1), 0.65)
