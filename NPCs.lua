npcs = {}
wf = require "windfield"
world = wf.newWorld()
local anim8 = require 'anim8'

npcs.knight = {}
npcs.king = {}
npcs.queen = {}
npcs.pumpking = {}
npcs.zombride = {}
npcs.martianbuu = {}
npcs.george = {}

npcs.knight.sprite = love.graphics.newImage("Sprites/Knight.png")
npcs.king.sprite = love.graphics.newImage("Sprites/King.png")
npcs.queen.sprite = love.graphics.newImage("Sprites/Queen.png")
npcs.pumpking.sprite = love.graphics.newImage("Sprites/Pumpking.png")
npcs.zombride.sprite = love.graphics.newImage("Sprites/Zombride.png")
npcs.martianbuu.sprite = love.graphics.newImage("Sprites/MartianBuu.png")
npcs.george.sprite = love.graphics.newImage("Sprites/George.png")
npcs.dialogBox = love.graphics.newImage("Sprites/Dialogue.png")
healthbar_full = love.graphics.newImage("Sprites/HPbarfull.png")
healthbar_empty = love.graphics.newImage("Sprites/HPbarempty.png")
blood = love.graphics.newImage("Sprites/Blood.png")

local height = 194/4 - 0.5
local width = 130/4 - 0.5
local grid = anim8.newGrid(width, height, (width + 0.5)*4, (height + 0.5)*4)
local grid2 = anim8.newGrid(32, 32, 96, 128)

npcs.knight.anim = anim8.newAnimation(grid("1-2", 1), 0.15)
npcs.king.anim = anim8.newAnimation(grid("1-2", 1), 0.15)
npcs.queen.anim = anim8.newAnimation(grid("1-2", 1), 0.15)
npcs.pumpking.anim = anim8.newAnimation(grid2("1-3", 1), 0.4)
npcs.zombride.anim = anim8.newAnimation(grid2("1-3", 1), 0.4)
npcs.martianbuu.anim = anim8.newAnimation(grid2("1-3", 1), 0.4)
npcs.george.anim = anim8.newAnimation(grid2("1-3", 1), 0.4)

