local composer = require("composer")
local scene = composer.newScene( )

local function iniciarJogo()
	composer.removeScene( "game" )
	composer.gotoScene("game", { time=800, effect="crossFade" } )
end

local function ranking1()
    composer.removeScene( "ranking" )
    composer.gotoScene( "ranking", { time=800, effect="crossFade" } )
end

local function exitGame()
    timer.performWithDelay (1000,
    function()
    if(system.getInfo("platformName")=="Android") then
      native.requestExit()
  else
    os.exit()
  end
        
 end )
end


function scene:create(event)
	local sceneGroup = self.view

	local background = display.newImageRect(sceneGroup, "MENUAERO/MENUBACKGROUND.png", 590, 1100)
	background.x = display.contentCenterX+10
    background.y = display.contentCenterY

    local jogar = display.newImageRect( sceneGroup, "MENUAERO/MENUPLAY.png", 527, 155)
    jogar.x = display.contentCenterX
    jogar.y = display.contentCenterY+120

    local ranking = display.newImageRect( sceneGroup, "MENUAERO/MENURANKING.png", 428, 132 )
    ranking.x = display.contentCenterX
    ranking.y = display.contentCenterY +280

    local sair = display.newImageRect( sceneGroup, "MENUAERO/MENUEXIT.png", 321, 95)
    sair.x = display.contentCenterX
    sair.y = display.contentCenterY+400

    jogar:addEventListener( "tap", iniciarJogo )
    sair:addEventListener("tap" , exitGame)
    ranking:addEventListener("tap",ranking1)


end





scene:addEventListener("create", create)	
return scene