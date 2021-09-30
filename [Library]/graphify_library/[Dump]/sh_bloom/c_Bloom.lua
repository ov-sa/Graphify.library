--
-- c_bloom.lua
--
local orderPriority = "-1.0"	-- The lower this number, the later the effect is applied

Settings = {}
Settings.var = {}

----------------------------------------------------------------
-- enableBloom
----------------------------------------------------------------

function enableBloom()
	if bEffectEnabled then return end
	-- Create things
	myScreenSource = dxCreateScreenSource( scx/2, scy/2)

	blurHShader,tecName = dxCreateShader( "fx/blurH.fx")

	blurVShader,tecName = dxCreateShader( "fx/blurV.fx")

	brightPassShader,tecName = dxCreateShader( "fx/brightPass.fx")

    addBlendShader,tecName = dxCreateShader( "fx/blend.fx")

	-- Get list of all elements used
	effectParts = {
						myScreenSource,
						blurVShader,
						blurHShader,
						brightPassShader,
						addBlendShader,
					}

	-- Check list of all elements used
	bAllValid = true
	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end
	
	setEffectVariables ()
	bEffectEnabled = true
	
	if not bAllValid then
		outputChatBox( "Bloom: Could not create some things. Please use debugscript 3")
		disableBloom()
	end	
end

function disableBloom()
	for i,v in pairs(effectParts) do
		if isElement(v) then
			destroyElement(v)
		end
	end
	effectParts = nil
	bEffectEnabled = nil
	bAllValid = nil
end

function changeBloom(setting)
	-- "Off", "Low", "Medium", "High" 
	if setting == 'Off' then
		disableBloom()
	elseif setting == 'Low' then
		enableBloom()
		setEffectVariables('Low')
	elseif setting == 'Medium' then
		enableBloom()
		setEffectVariables('Medium')
	elseif setting == 'High' then
		enableBloom()
		setEffectVariables('High')
	end
end

addEvent("Bloom", true)
addEventHandler("Bloom", root, changeBloom)

---------------------------------
-- Settings for effect
---------------------------------

levelSettings = {}

levelSettings['Low'] = {}
levelSettings['Low']['cutoff'] = 0.001
levelSettings['Low']['power'] = 2
levelSettings['Low']['blur'] = 1
levelSettings['Low']['bloom'] = 2

levelSettings['Medium'] = {}
levelSettings['Medium']['cutoff'] = 0.001
levelSettings['Medium']['power'] = 1.3
levelSettings['Medium']['blur'] = 1.3
levelSettings['Medium']['bloom'] = 5

levelSettings['High'] = {}
levelSettings['High']['cutoff'] = 0.001
levelSettings['High']['power'] = 1.3
levelSettings['High']['blur'] = 1.3
levelSettings['High']['bloom'] = 3

function setEffectVariables(level)
    local v = Settings.var
    -- Bloom
	
    v.cutoff = levelSettings[level or 'Medium']['cutoff'] or 0.001
    v.power = levelSettings[level or 'Medium']['power'] or 1.5
	v.blur = levelSettings[level or 'Medium']['blur'] or 1
    v.bloom = levelSettings[level or 'Medium']['bloom'] or 2.5
    v.blendR = 204
    v.blendG = 153
    v.blendB = 130
    v.blendA = 80

	-- Debugging
    v.PreviewEnable=0
    v.PreviewPosY=0
    v.PreviewPosX=100
    v.PreviewSize=300
end

-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
addEventHandler( "onClientHUDRender", root,
    function()
		if not bAllValid or not Settings.var then return end
		local v = Settings.var	
			
		-- Reset render target pool
		RTPool.frameStart()
		DebugResults.frameStart()
		-- Update screen
		--dxUpdateScreenSource( myScreenSource, true) --TODO: GET EXPORTS FOR blurMultiplier EMISSIVE
        myScreenSource = exports.dl_core:getEmissiveRT()
			
		-- Start with screen
		local current = myScreenSource

		-- Apply all the effects, bouncing from one render target to another
		current = applyBrightPass( current, v.cutoff, v.power)
		current = applyDownsample( current)
		current = applyDownsample( current)
		current = applyGBlurH( current, v.bloom, v.blur)
		current = applyGBlurV( current, v.bloom, v.blur)

		-- When we're done, turn the render target back to default
		dxSetRenderTarget()

		-- Mix result onto the screen using 'add' rather than 'alpha blend'
		if current then
			dxSetShaderValue( addBlendShader, "rtTexture", current)
			local col = tocolor(v.blendR, v.blendG, v.blendB, v.blendA)
			dxDrawImage( 0, 0, scx, scy, addBlendShader, 0,0,0, col)
		end
		-- Debug stuff
		if v.PreviewEnable > 0.5 then
			DebugResults.drawItems(v.PreviewSize, v.PreviewPosX, v.PreviewPosY)
		end
	end
,true ,"low" .. orderPriority)


-----------------------------------------------------------------------------------
-- Apply the different stages
-----------------------------------------------------------------------------------
function applyDownsample( Src, amount)
	if not Src then return nil end
	amount = amount or 2
	local mx,my = dxGetMaterialSize( Src)
	mx = mx / amount
	my = my / amount
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT)
	dxDrawImage( 0, 0, mx, my, Src)
	DebugResults.addItem( newRT, "applyDownsample")
	return newRT
end

function applyGBlurH( Src, bloom, blur)
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src)
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true) 
	dxSetShaderValue( blurHShader, "rtTexture", Src)
	dxSetShaderValue( blurHShader, "viewportSize", mx,my)
	dxSetShaderValue( blurHShader, "bloomMultiplier", bloom)
	dxSetShaderValue( blurHShader, "blurMultiplier", blur)
	dxDrawImage( 0, 0, mx, my, blurHShader)
	DebugResults.addItem( newRT, "applyGBlurH")
	return newRT
end

function applyGBlurV( Src, bloom, blur)
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src)
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true) 
	dxSetShaderValue( blurVShader, "rtTexture", Src)
	dxSetShaderValue( blurVShader, "viewportSize", mx,my)
	dxSetShaderValue( blurVShader, "bloomMultiplier", bloom)
	dxSetShaderValue( blurVShader, "blurMultiplier", blur)
	dxDrawImage( 0, 0, mx,my, blurVShader)
	DebugResults.addItem( newRT, "applyGBlurV")
	return newRT
end

function applyBrightPass( Src, cutoff, power)
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src)
	local newRT = RTPool.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true) 
	dxSetShaderValue( brightPassShader, "rtTexture", Src)
	dxSetShaderValue( brightPassShader, "CUTOFF", cutoff)
	dxSetShaderValue( brightPassShader, "POWER", power)
	dxDrawImage( 0, 0, mx,my, brightPassShader)
	DebugResults.addItem( newRT, "applyBrightPass")
	return newRT
end


----------------------------------------------------------------
-- Avoid errors messages when memory is low
----------------------------------------------------------------
_dxDrawImage = dxDrawImage
function xdxDrawImage(posX, posY, width, height, image, ...)
	if not image then return false end
	return _dxDrawImage( posX, posY, width, height, image, ...)
end
enableBloom()