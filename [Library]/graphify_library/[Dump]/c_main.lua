
shaderParams = { 
	SHWaterWake = {"fx/RTinput_water_detail.fx", 3, 0, false, "world,object"}, -- world (waterwake)
	SHWaterDetail = {"fx/RTinput_water_detail.fx", 3, 0, false, "world,object"}, -- world (waterwake)
	SHWater = {"fx/RTinput_water.fx", 0, 0, false, "world,object"}, -- world (water)
				}

functionTable = {}

function functionTable.enableCore()    
    engineApplyShaderToWorldTexture(shaderTable.SHWater, "water*")
    engineRemoveShaderFromWorldTexture(shaderTable.SHWater, "waterwake")
    
    engineApplyShaderToWorldTexture(shaderTable.SHWaterWake, "waterwake")
    dxSetShaderValue(shaderTable.SHWaterWake, "sWorldZBias", 0.45 )
    
    setShaderTextureList(shaderTable.SHWaterDetail, textureListTable.Detail, true)
    dxSetShaderValue(shaderTable.SHWaterDetail, "sWorldZBias", 0.01 )
end

function functionTable.createPedNormalShader(texName, normalTex, lerpNormal, thisEntity, colRed, colGreen, colBlue)
	local pedNormalShader = dxCreateShader("fx/RTinput_ped_normal.fx", 1, 0, false, "ped")
	if pedNormalShader then
		functionTable.syncRTWithShader(pedNormalShader)
		dxSetShaderValue(pedNormalShader, "fLerpNormal", lerpNormal) 
        if normalTex then
            dxSetShaderValue(pedNormalShader, "gTextureNormal", normalTex)
        end
        dxSetShaderValue(pedNormalShader, "gTexColor", colRed/255, colGreen/255, colBlue/255)
		engineApplyShaderToWorldTexture(pedNormalShader, texName, thisEntity)
		return pedNormalShader
	else 
		return false
	end
end