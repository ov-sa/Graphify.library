
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

function applyNormalToPedTexture(texName,normalTex,...)
	assert(type(texName) == "string", "Expected string at argument 1 , got "..type(texName))
    if normalTex ~= nil then
	    assert(isElement(normalTex), "Expected element at argument 2, got "..type(normalTex))
	    assert(getElementType(normalTex) == "texture", "Expected texture element at argument 2, got "..getElementType(normalTex))
    end
    local optParam = {...}
	
	if (type(optParam[1]) ~= "number") then
		optParam[1] = 0.5
	end
	if isElement(optParam[2]) then
		assert(getElementType(optParam[2]) == "ped" or getElementType(optParam[2]) == "player", "Expected ped element at argument 4, got "..type(optParam[2]))		
	else
		optParam[2] = nil
	end
	if (type(optParam[3]) ~= "number") then
		optParam[3] = 255
	end
	if (type(optParam[4]) ~= "number") then
		optParam[4] = 255
	end
	if (type(optParam[5]) ~= "number") then
		optParam[5] = 255
	end

    outputChatBox(tostring(thisEntity))
	local lerpNormal, thisEntity, colRed, colGreen, colBlue = unpack(optParam)	
	return functionTable.createPedNormalShader(texName, normalTex, lerpNormal, thisEntity, colRed, colGreen, colBlue)
end