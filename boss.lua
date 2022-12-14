boss = {}
slash = {}
local slashHeight = 184
local slashWidth = 181
local height = 96
local width = 96
local anim8 = require 'anim8'
local grid = anim8.newGrid(width, height, width * 3, height * 4)
local grid2 = anim8.newGrid(slashWidth, slashHeight, slashWidth * 5, slashHeight * 3)
boss.anim = {}
slash.anim = {} 
boss.health = 100 
wf = require "windfield"
world = wf.newWorld()
boss.sprite = love.graphics.newImage("Sprites/Boss.png")
slash.sprite = love.graphics.newImage("Sprites/Slash.png")
boss.anim.standing = anim8.newAnimation(grid("1-3", 4), 0.7)
slash.anim = anim8.newAnimation(grid2("2-5", 2), 0.1)