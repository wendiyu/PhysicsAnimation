-----------------------------------------------------------------------------------------
--
-- main.lua
--
-- Created by: Wendi Yu
-- Created on: May 2018
-- 
-- make a character animate and then move forward, while being on a physics world
-----------------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)

centerX = display.contentWidth * .5
centerY = display.contentHeight * .5

-- Gravity
local physics = require("physics")

local playerBullets = {} -- Table that holds the players Bullets

physics.start()
physics.setGravity(0, 20)
--physics.setDrawMode("hybrid")

local leftWall = display.newRect( 0, display.contentHeight / 2, 1, display.contentHeight )
-- myRectangle.strokeWidth = 3
-- myRectangle:setFillColor( 0.5 )
-- myRectangle:setStrokeColor( 1, 0, 0 )
leftWall.alpha = 1.0
physics.addBody( leftWall, "static", { 
    friction = 0.5, 
    bounce = 0.3 
    } )

local theGround = display.newImageRect( "./assets/sprites/land.png", 2040, 150 )
theGround.x = display.contentCenterX 
theGround.y = display.contentCenterY + 690
theGround.id = "the ground"
physics.addBody(theGround, "static", {
	friction = 0.5,
	bounce = 0.3
	})
 
local dPad = display.newImageRect( "./assets/sprites/d-pad.png", 300, 300 )
dPad.x = 150
dPad.y = display.contentHeight - 160
dPad.id = "d-pad"
dPad.alpha = 0.5

local leftArrow = display.newImage( "./assets/sprites/leftArrow.png" )
leftArrow.x = 40
leftArrow.y = display.contentHeight - 160
leftArrow.id = "left arrow"
leftArrow.alpha = 0.5

local rightArrow = display.newImage( "./assets/sprites/rightArrow.png" )
rightArrow.x = 260
rightArrow.y = display.contentHeight - 160
rightArrow.id = "right arrow"
rightArrow.alpha = 0.5

local jumpButton = display.newImage( "./assets/sprites/jumpButton.png" )
jumpButton.x = display.contentWidth -80
jumpButton.y = display.contentHeight - 80
jumpButton.id = "jump button"
jumpButton.alpha = 0.5

local shootButton = display.newImage( "./assets/sprites/jumpButton.png" )
shootButton.x = display.contentWidth - 250
shootButton.y = display.contentHeight - 80
shootButton.id = "shoot button"
shootButton.alpha = 0.5

local sheetOptionsIdle1 =
{
    width = 232,
    height = 439,
    numFrames = 10
}
local sheetIdleNinja = graphics.newImageSheet( "./assets/spritesheets/ninjaBoyIdle.png", sheetOptionsIdle1 )


local sheetOptionsIdle2 =
{
    width = 567,
    height = 556,
    numFrames = 10
}
local sheetIdleRobot = graphics.newImageSheet( "./assets/spritesheets/robotIdle.png", sheetOptionsIdle2 )

local sheetOptionsAttact =
{
    width = 377,
    height = 451,
    numFrames = 10
}
local sheetAttactNinja = graphics.newImageSheet( "./assets/spritesheets/ninjaBoyThrow.png", sheetOptionsAttact )

local sheetOptionsJump =
{
    width = 362,
    height = 483,
    numFrames = 10
}
local sheetJumpNinja = graphics.newImageSheet( "./assets/spritesheets/ninjaBoyJump.png", sheetOptionsJump )

local sheetOptionsDead =
{
    width = 362,
    height = 483,
    numFrames = 10
}
local sheetDeadRobot = graphics.newImageSheet( "./assets/spritesheets/ninjaBoyJump.png", sheetOptionsDead )

local sheetOptionsWalk =
{
    width = 363,
    height = 458,
    numFrames = 10
}
local sheetWalkNinja = graphics.newImageSheet( "./assets/spritesheets/ninjaBoyRun.png", sheetOptionsWalk )

-- sequences table
local sequence_data_ninja = {
    -- consecutive frames sequence
    {
        name = "idle",
        start = 1,
        count = 10,
        time = 800,
        loopCount = 0,
        sheet = sheetIdleNinja
    }, 
    {
        name = "attack",
        start = 1,
        count = 10,
        time = 800,
        loopCount = 0,
        sheet = sheetAttactNinja
    },
    {
        name = "walk",
        start = 1,
        count = 10,
        time = 800,
        loopCount = 0,
        sheet = sheetWalkNinja
    },
    {
        name = "jump",
        start = 1,
        count = 8,
        time = 1000,
        loopCount = 0,
        sheet = sheetJumpNinja
    }              
}

local sequence_data_robot = {
	-- consecutive frames sequence
	{
        name = "idle",
        start = 1,
        count = 10,
        time = 800,
        loopCount = 0,
        sheet = sheetIdleRobot
    },
    {
        name = "dead",
        start = 1,
        count = 8,
        time = 1000,
        loopCount = 0,
        sheet = sheetOptionsDead
    }
}

local Ninja = display.newSprite( sheetIdleNinja, sequence_data_ninja )
Ninja.x = centerX
Ninja.y = centerY
Ninja.id = "the character"
physics.addBody(Ninja, "dynamic", {
	density = 2.5,
	friction = 0.1,
	bounce = 0.2
	})
Ninja.isFixedRotation = true -- If you apply this property before the physics.addBody() command for the object, it will merely be treated as a property of the object like any other custom property and, in that case, it will not cause any physical change in terms of locking rotation. 

Ninja:setSequence( "idle" )
Ninja:play()

local Robot = display.newSprite( sheetIdleRobot, sequence_data_robot )
Robot.x = centerX + 400
Robot.y = centerY
Robot.id = "bad character"
physics.addBody(Robot, "dynamic", {
	density = 2.5,
	friction = 0.1,
	bounce = 0.2
	})

Robot:setSequence( "idle" )
Robot:play()

-- After a short time, swap the sequence to 'seq2' which uses the second image sheet
local function swapSheet()
    Ninja:setSequence( "idle" )
    Ninja:play()
    print("idle")
end

local function characterCollision( self, event )
 
    if ( event.phase == "began" ) then
        print( self.id .. ": collision began with " .. event.other.id )
 
    elseif ( event.phase == "ended" ) then
        print( self.id .. ": collision ended with " .. event.other.id )
    end
end

function checkPlayerBulletsOutOfBounds()
	-- check if any bullets have gone off the screen
	local bulletCounter

    if #playerBullets > 0 then
        for bulletCounter = #playerBullets, 1 ,-1 do
            if playerBullets[bulletCounter].x > display.contentWidth + 1000 then
                playerBullets[bulletCounter]:removeSelf()
                playerBullets[bulletCounter] = nil
                table.remove(playerBullets, bulletCounter)
                print("remove bullet")
            end
        end
    end
end

local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2
        local whereCollisonOccurredX = obj1.x
        local whereCollisonOccurredY = obj1.y

        if ( ( obj1.id == "bad character" and obj2.id == "bullet" ) or
             ( obj1.id == "bullet" and obj2.id == "bad character" ) ) then
            -- Remove both the laser and asteroid
            --display.remove( obj1 )
            display.remove( obj2 )

 			
 			-- remove the bullet
 			local bulletCounter = nil
 			
            for bulletCounter = #playerBullets, 1, -1 do
                if ( playerBullets[bulletCounter] == obj1 or playerBullets[bulletCounter] == obj2 ) then
                    playerBullets[bulletCounter]:removeSelf()
                    playerBullets[bulletCounter] = nil
                    table.remove( playerBullets, bulletCounter )
                    break
                end
            end

            Robot:setSequence( "dead" )
            Robot:play()


           --remove character
            --Robot:removeSelf()
            --Robot = nil

            -- Increase score
            print ("you could increase a score here.")

            -- make an explosion sound effect
            local expolsionSound = audio.loadStream( "./assets/sounds/8bit_bomb_explosion.wav" )
            local explosionChannel = audio.play( expolsionSound )
            -- make an explosion happen
            -- Table of emitter parameters
			local emitterParams = {
			    startColorAlpha = 1,
			    startParticleSizeVariance = 250,
			    startColorGreen = 0.3031555,
			    yCoordFlipped = -1,
			    blendFuncSource = 770,
			    rotatePerSecondVariance = 153.95,
			    particleLifespan = 0.7237,
			    tangentialAcceleration = -1440.74,
			    finishColorBlue = 0.3699196,
			    finishColorGreen = 0.5443883,
			    blendFuncDestination = 1,
			    startParticleSize = 400.95,
			    startColorRed = 0.8373094,
			    textureFileName = "./assets/sprites/fire.png",
			    startColorVarianceAlpha = 0.5,
			    maxParticles = 256,
			    finishParticleSize = 320,
			    duration = 0.25,
			    finishColorRed = 1,
			    maxRadiusVariance = 72.63,
			    finishParticleSizeVariance = 250,
			    gravityy = -671.05,
			    speedVariance = 90.79,
			    tangentialAccelVariance = -420.11,
			    angleVariance = -142.62,
			    angle = -240.11
			}
			local emitter = display.newEmitter( emitterParams )
			emitter.x = whereCollisonOccurredX
			emitter.y = whereCollisonOccurredY
        end
    end
end

function rightArrow:touch( event )
    if ( event.phase == "ended" ) then
        -- move the character right
        transition.moveBy( Ninja, { 
            x = 150, 
            y = 0, 
            time = 800 
            } )
        Ninja:setSequence( "walk" )
        Ninja:play()  
        timer.performWithDelay( 1000, swapSheet )      
    end

    return true
end


function leftArrow:touch( event )
    if ( event.phase == "ended" ) then
        -- move the character left
        transition.moveBy( Ninja, { 
            x = -150, 
            y = 0, 
            time = 1000 
            } )
        Ninja:setSequence( "idle" )
        Ninja:play()
    end

    return true
end

function jumpButton:touch( event )
	-- body
	if ( event.phase == "ended" ) then
        -- move the character jump
       Ninja:setLinearVelocity( 0, -750 )
       Ninja:setSequence( "jump" )
       Ninja:play()
       timer.performWithDelay( 1500, swapSheet )
    end 
    
    return true    
end

function shootButton:touch( event )
    if ( event.phase == "began" ) then
        -- make a bullet appear
        local aSingleBullet = display.newImage( "./assets/sprites/Kunai.png" )
        aSingleBullet.x = Ninja.x + 200
        aSingleBullet.y = Ninja.y 
        physics.addBody( aSingleBullet, 'dynamic' )
        -- Make the object a "bullet" type object
        aSingleBullet.isBullet = true
        aSingleBullet.isFixedRotation = true
        aSingleBullet.gravityScale = 0
        aSingleBullet.id = "bullet"
        aSingleBullet:setLinearVelocity( 1500, 0 )

        table.insert(playerBullets,aSingleBullet)
        print("# of bullet: " .. tostring(#playerBullets))

        Ninja:setSequence( "attack" )
        Ninja:play()
        timer.performWithDelay( 800, swapSheet )
    end

    return true
end

function checkCharacterPosition( event )
	-- check every frame to see if character has fallen
	if Ninja.y > display.contentHeight + 400 then
		Ninja.x = display.contentCenterX + 190
        Ninja.y = display.contentCenterY
    end

end

local function resetToIdle (event)
    if event.phase == "ended" then
        Ninja:setSequence("idle")
        Ninja:play()
    end
end


rightArrow:addEventListener( "touch", rightArrow )
leftArrow:addEventListener( "touch", leftArrow )
Ninja:addEventListener("sprite", resetToIdle)

jumpButton:addEventListener( "touch", jumpButton )
shootButton:addEventListener( "touch", shootButton)

Runtime:addEventListener("enterFrame", checkCharacterPosition )
Runtime:addEventListener( "enterFrame", checkPlayerBulletsOutOfBounds )
Runtime:addEventListener( "collision", onCollision )

Ninja.collision = characterCollision
Ninja:addEventListener( "collision" )