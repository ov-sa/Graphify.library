
local enablePedVS = true

---------------------------------------------------------------------------------------------------
-- shader lists
---------------------------------------------------------------------------------------------------
if enablePedVS then pedShader = "fx/RTinput_ped.fx" else pedShader = "fx/RTinput_ped_noVS.fx" end
shaderParams = { 
	SHWorld = {"fx/RTinput_world.fx", 0, 0, false, "world,object"}, -- world
	SHWorldRefAnim = {"fx/RTinput_world_refAnim.fx", 1, 0, false, "world,object"}, --
    --TODO: MOFIEID
    SHWorldEmissive = {"fx/RTinput_world_refAnimEmissive.fx", 0, 0, false, "world,object"},
	SHGrass = {"fx/RTinput_grass.fx", 0, 0, false, "world"}, -- world (grass)
	SHWorldNoZWrite = {"fx/RTinput_world_noZWrite.fx", 2, 0, false, "world,object,vehicle"}, -- world
	SHWaterWake = {"fx/RTinput_water_detail.fx", 3, 0, false, "world,object"}, -- world (waterwake)
	SHWaterDetail = {"fx/RTinput_water_detail.fx", 3, 0, false, "world,object"}, -- world (waterwake)
	SHWater = {"fx/RTinput_water.fx", 0, 0, false, "world,object"}, -- world (water)
	SHVehPaint = {"fx/RTinput_car_paint.fx", 0, 0, false, "vehicle"}, -- vehicle paint
	SHPed = {pedShader, 0, 0, false, "ped"}
				}

isDRShValid = false
isDRRtValid = false
isDREnabled = false
		


---TODO: MODIFIED
emissiveTextures = {
    "lrsrt_light*",
    "weapon_assault_rifle_ammo*",
    "lrsrt_gencoil",
    "lrsrt_mtl_ddda",
    "lrsrt_mtlpnl_hmntcha"
}
-------------------------


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
        engineApplyShaderToWorldTexture(shaderTable.SHWorld, "*")
		setShaderTextureList(shaderTable.SHWorld, DEFAULT_TEXTURE_CONFIG.BLACKLIST, false)
		setShaderTextureList(shaderTable.SHWorld, textureListTable.ZDisable, false)
		setShaderTextureList(shaderTable.SHWorld, textureListTable.ApplyList, true)
        --TODO: MODIFIED
        functionTable.enableEmissive()
        ----------

		setShaderTextureList(shaderTable.SHWorldRefAnim, textureListTable.ApplySpecial, true)
	
		setShaderTextureList(shaderTable.SHWorldNoZWrite, textureListTable.ZDisableApply, true)
		dxSetShaderValue(shaderTable.SHWorldNoZWrite, "sWorldZBias", 0.005 )		

		setShaderTextureList(shaderTable.SHVehPaint, textureListTable.TextureGrun, true)		
		engineApplyShaderToWorldTexture(shaderTable.SHVehPaint, "vehiclegeneric256")
		engineApplyShaderToWorldTexture(shaderTable.SHVehPaint, "*")
		engineRemoveShaderFromWorldTexture(shaderTable.SHVehPaint, "unnamed")

		engineApplyShaderToWorldTexture(shaderTable.SHPed, "*")	
		engineApplyShaderToWorldTexture(shaderTable.SHGrass, "tx*")
		engineApplyShaderToWorldTexture(shaderTable.SHWater, "water*")
		engineRemoveShaderFromWorldTexture(shaderTable.SHWater, "waterwake")
		
		engineApplyShaderToWorldTexture(shaderTable.SHWaterWake, "waterwake")
		dxSetShaderValue(shaderTable.SHWaterWake, "sWorldZBias", 0.45 )
		
		setShaderTextureList(shaderTable.SHWaterDetail, textureListTable.Detail, true)
		dxSetShaderValue(shaderTable.SHWaterDetail, "sWorldZBias", 0.01 )
		isDREnabled = true
	end
end

--TODO: MODIFIED....
function functionTable.enableEmissive()

    --TODO: CHANGE LATER
    dxSetShaderValue(shaderTable.SHWorldEmissive, "colorLayer", targetTable.RTEmissive)
    for i, j in ipairs(emissiveTextures) do
        engineRemoveShaderFromWorldTexture(shaderTable.SHWorld, j)
        engineApplyShaderToWorldTexture(shaderTable.SHWorldEmissive, j)
    end

end
-------

shaderTable = {}
function functionTable.createWorldShaders()
	if not isDRShValid then
		shaderTable = {}
		shaderTable.SHWorld = dxCreateShader(unpack(shaderParams.SHWorld))
		shaderTable.SHWorldRefAnim = dxCreateShader(unpack(shaderParams.SHWorldRefAnim))
        --TODO: MODIFIED
        shaderTable.SHWorldEmissive = dxCreateShader(unpack(shaderParams.SHWorldEmissive))
		shaderTable.SHGrass = dxCreateShader(unpack(shaderParams.SHGrass))
		shaderTable.SHWorldNoZWrite = dxCreateShader(unpack(shaderParams.SHWorldNoZWrite))
		shaderTable.SHWaterWake = dxCreateShader(unpack(shaderParams.SHWaterWake))
		shaderTable.SHWaterDetail = dxCreateShader(unpack(shaderParams.SHWaterDetail))
		shaderTable.SHWater = dxCreateShader(unpack(shaderParams.SHWater))
		shaderTable.SHPed = dxCreateShader(unpack(shaderParams.SHPed))
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