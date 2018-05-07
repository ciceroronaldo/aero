local composer = require("composer")
local scene = composer.newScene()



local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )
-- Seed the random number generator
math.randomseed( os.time() )
-- Initialize variables
local vidas = 3
local pontos = 0
local died = false
local aliensTable = {}

local ship
local gameLoopTimer
local vidasText
local pontosText
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

-- Load the background
local background = display.newImageRect( backGroup, "background.jpg", 590, 1100 )
background.x = display.contentCenterX
background.y = display.contentCenterY

aero = display.newImageRect( mainGroup,"nave.png", 80, 80 )
aero.x = display.contentWidth/2

aero.y = display.contentHeight - 40
physics.addBody( aero, { radius=30, isSensor=true } )
aero.myName = "aero"

vidasText = display.newText( uiGroup, "vidas: " .. vidas, 250, 70, native.systemFont, 40)
pontosText = display.newText( uiGroup, "pontos: " .. pontos, 500, 70, native.systemFont, 40 )

local function updateText()

  livesText.text = "vidas: " .. vidas 
  livesscoreText.text = "pontos: " .. pontos 

end

local function endGame()
  composer.setVariable( "finalScore", pontos )
  composer.removeScene( "ranking" )
  composer.gotoScene( "ranking", { time=800, effect="crossFade" } )
end

local function createAliens()
  if (#aliensTable <pontos/200+2) then
   newAlien = display.newImageRect( mainGroup,"alien.gif", 60, 60 )
   newAlien.x = display.contentWidth +50 
   table.insert( aliensTable, newAlien )
   physics.addBody( newAlien, "dynamic", { radius=10, bounce=0.5 } )
   newAlien.myName = "alien"


   local whereFrom = math.random(3)

   if ( whereFrom == 1) then

       newAlien.x = -60
       newAlien.y = math.random(500)
       newAlien:setLinearVelocity( math.random(40,120), math.random(20,60))
    elseif ( whereFrom == 2 ) then

        newAlien.x = math.random( display.contentWidth )
        newAlien.y = -60
        newAlien:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then

        newAlien.x = display.contentWidth + 60
        newAlien.y = math.random( 500 )
        newAlien:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
   end

   newAlien:applyTorque( math.random( -6,6 ) )
  end 
end

local function fireLaser()

    local newLaser = display.newImageRect( mainGroup, "laser.png", 30, 30 )
    physics.addBody( newLaser, "dynamic", { isSensor=true } )
    media.playEventSound("shot.wav")
    newLaser.isBullet = true
    newLaser.myName = "laser"
    newLaser.x = aero.x
    newLaser.y = aero.y
    newLaser:toBack()

    transition.to( newLaser, { x= aero.x, y= 20, time=1000,
        onComplete = function() display.remove( newLaser ) end
    } )
end

aero:addEventListener( "tap", fireLaser )

local function dragAero( event )
    local aero = event.target
    local phase = event.phase

    if ( "began" == phase ) then
        -- Set touch focus on the bh
        display.currentStage:setFocus( aero)
         -- Store initial offset position
        aero.touchOffsetX = event.x - aero.x
        aero.touchOffsetY = event.y - aero.y

    elseif ( "moved" == phase ) then
        -- Move the bh to the new touch position
        aero.x = event.x - aero.touchOffsetX
        aero.y = event.y - aero.touchOffsetY

    elseif ( "ended" == phase or "cancelled" == phase ) then
        display.currentStage:setFocus( nil ) 
    end

    return true
end

aero:addEventListener("touch", dragAero)

local function gameLoop()
	createAliens()
	
	for i = #aliensTable, 1, -1 do
		local thisAlien = aliensTable[i]

		if ( thisAlien.x < -100 or
             thisAlien.x > display.contentWidth + 100 or
             thisAlien.y < -100 or
             thisAlien.y > display.contentHeight + 100 )
        then
            display.remove( thisAlien )
            table.remove( aliensTable, i )
        end
    end
end

gameLoopTimer = timer.performWithDelay( 1000, gameLoop, 0 )

local function restoreAero()
 
    aero.isBodyActive = false
    aero.x = display.contentCenterX
    aero.y = display.contentHeight - 100
 
    -- Fade in the ship
    transition.to( aero, { alpha=1, time=4000,
        onComplete = function()
            aero.isBodyActive = true
            died = false
        end
    } )
end


local function onCollision( event )

  if ( event.phase == "began" ) then

    local obj1 = event.object1
    local obj2 = event.object2

    if ( ( obj1.myName == "laser" and obj2.myName == "alien" ) or
       ( obj1.myName == "alien" and obj2.myName == "laser" ) )
    then
      -- Remove both the laser and asteroid
      display.remove( obj1 )
      display.remove( obj2 )

      -- Play explosion sound!
      audio.play( explosionSound )

      for i = #aliensTable, 1, -1 do
        if ( aliensTable[i] == obj1 or aliensTable[i] == obj2 ) then
          table.remove( aliensTable, i )
          break
        end
      end

      -- Increase score
      pontos = pontos + 100
      pontosText.text = "pontos: " .. pontos

    elseif ( ( obj1.myName == "aero" and obj2.myName == "alien" ) or
         ( obj1.myName == "alien" and obj2.myName == "aero" ) )
    then
      if ( died == false ) then
        died = true

        -- Play explosion sound!
        --audio.play( explosionSound )

        -- Update lives
        vidas = vidas - 1
        vidasText.text = "vidas: " .. vidas

        if ( vidas == 0 ) then
          display.remove( aero )
          timer.performWithDelay( 2000, endGame )
        else
          aero.alpha = 0
          timer.performWithDelay( 1000, restoreAero )
        end
      end
    end
  end
end

local physics = require ("physics") 
physics.start()
Runtime:addEventListener("collision", onCollision)









function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)

  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen
    physics.start()
    Runtime:addEventListener( "collision", onCollision )
    gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
    -- Start the music!
    audio.play( musicTrack, { channel=1, loops=-1 } )
  end
end


-- hide()
function scene:hide( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    timer.cancel( gameLoopTimer )

  elseif ( phase == "did" ) then
    -- Code here runs immediately after the scene goes entirely off screen
    Runtime:removeEventListener( "collision", onCollision )
    physics.pause()
    -- Stop the music!
    audio.stop( 1 )
  end
end


-- destroy()
function scene:destroy( event )

  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  -- Dispose audio!
  audio.dispose( explosionSound )
  audio.dispose( fireSound )
  audio.dispose( musicTrack )
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

  
return scene
