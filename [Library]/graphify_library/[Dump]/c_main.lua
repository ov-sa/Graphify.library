
local enablePedVS = true

---------------------------------------------------------------------------------------------------
-- shader lists
---------------------------------------------------------------------------------------------------
if enablePedVS then pedShader = "fx/RTinput_ped.fx" else pedShader = "fx/RTinput_ped_noVS.fx" end --TODO: SWITCH B/W VS NO VS SOMEHOW/...


shaderParams = { 
    --TODO: MOFIEID
	SHWaterWake = {"fx/RTinput_water_detail.fx", 3, 0, false, "world,object"}, -- world (waterwake)
	SHWaterDetail = {"fx/RTinput_water_detail.fx", 3, 0, false, "world,object"}, -- world (waterwake)
	SHWater = {"fx/RTinput_water.fx", 0, 0, false, "world,object"}, -- world (water)
	SHVehPaint = {"fx/RTinput_car_paint.fx", 0, 0, false, "vehicle"}, -- vehicle paint
				}

isDRShValid = false
isDRRtValid = false
isDREnabled = false
		

---------------------------------------------------------------------------------------------------
-- manage render targets
---------------------------------------------------------------------------------------------------
functionTable = {}

function functionTable.enableCore()
	if isDREnabled then return end
	if functionTable.createWorldShaders() and functionTable.createRenderTargets() then
		for i, thisPart in pairs(shaderTable) do
			functionTable.syncRTWithShader(thisPart)
		end

		setShaderTextureList(shaderTable.SHVehPaint, textureListTable.TextureGrun, true)		
		engineApplyShaderToWorldTexture(shaderTable.SHVehPaint, "vehiclegeneric256")
		engineApplyShaderToWorldTexture(shaderTable.SHVehPaint, "*")
		engineRemoveShaderFromWorldTexture(shaderTable.SHVehPaint, "unnamed")
        
		engineApplyShaderToWorldTexture(shaderTable.SHWater, "water*")
		engineRemoveShaderFromWorldTexture(shaderTable.SHWater, "waterwake")
		
		engineApplyShaderToWorldTexture(shaderTable.SHWaterWake, "waterwake")
		dxSetShaderValue(shaderTable.SHWaterWake, "sWorldZBias", 0.45 )
		
		setShaderTextureList(shaderTable.SHWaterDetail, textureListTable.Detail, true)
		dxSetShaderValue(shaderTable.SHWaterDetail, "sWorldZBias", 0.01 )
		isDREnabled = true
	end
end
-------
shaderTable = {}
function functionTable.createWorldShaders()
	if not isDRShValid then
		shaderTable = {}

		shaderTable.SHWaterWake = dxCreateShader(unpack(shaderParams.SHWaterWake))
		shaderTable.SHWaterDetail = dxCreateShader(unpack(shaderParams.SHWaterDetail))
		shaderTable.SHWater = dxCreateShader(unpack(shaderParams.SHWater))
		shaderTable.SHVehPaint = dxCreateShader(unpack(shaderParams.SHVehPaint))
		isDRShValid = true
        for i,thisPart in pairs(shaderTable) do
            isDRShValid = thisPart and isDRShValid
        end
	end
	return isDRShValid
end

function functionTable.createPedNormalShader(texName, normalTex, lerpNormal, thisEntity, colRed, colGreen, colBlue)
	local pedNormalShader = dxCreateShader("fx/RTinput_ped_normal.fx", 1, 0, false, "ped")
	if pedNormalShader then
		functionTable.syncRTWithShader(pedNormalShader)
		dxSetShaderValue(pedNormalShader, "fLerpNormal", lerpNormal) 
        if normalTex then
            dxSetShaderValue(pedNormalShader, "gTextureNormal", normalTex)
        end
        dxSetShaderValue(pedNormalShader, "gTexColor", colRed / 255, colGreen / 255, colBlue / 255)
		engineApplyShaderToWorldTexture(pedNormalShader, texName, thisEntity)
		return pedNormalShader
	else 
		return false
	end
end