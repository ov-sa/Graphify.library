local Light = {
	buffer = {},
	APIs = {
		"createPointLight",
		"setPointLightPosition",
		"setPointLightAttenuation",
		"setPointLightAttenuationPower",
		"setPointLightColor",
		"setPointLightFadeDistance"
	}
}

function Light.createPointLight(position, attenuation, color)
	local cShader = {
		tickCount = 0,
		shader = dxCreateShader(getPointLightFX()),
		position = position,
		attenuation = attenuation,
		attenuationPower = 2,
		fadeDist = Vector2(950, 850),
		tesselationState = false,
		tesselationShape = 8
	}
	Light.buffer[(cShader.shader)] = cShader
	dxSetShaderValue(cShader.shader, "lightPixelSize", 1/sX, 1/sY)
	dxSetShaderValue(cShader.shader, "lightHalfPixel", 1/(sX*2), 1/(sY*2))
	dxSetShaderValue(cShader.shader, "layerRT", layerRT)
	Light.setPointLightPosition(cShader.shader, cShader.position)
	Light.setPointLightAttenuation(cShader.shader, cShader.attenuation)
	Light.setPointLightAttenuationPower(cShader.shader, cShader.attenuationPower)
	Light.setPointLightColor(cShader.shader, color)
	Light.setPointLightFadeDistance(cShader.shader, cShader.fadeDist)
	Light.setPointLightTesselationByDistance(cShader.shader)
	return cShader.shader
end

function Light.setPointLightPosition(shader, position)
	local self = Light.buffer[shader]
	if not self then return false end
	self.position = position
	dxSetShaderValue(self.shader, "lightPosition", self.position.x, self.position.y, self.position.z)
	return true
end

function Light.setPointLightAttenuation(shader, attenuation)
	local self = Light.buffer[shader]
	if not self then return false end
	self.attenuation = attenuation
	dxSetShaderValue(self.shader, "lightAttenuation", self.attenuation)
	Light.setPointLightTesselationByDistance(shader)
	return true
end

function Light.setPointLightAttenuationPower(shader, attenuationPower)
	local self = Light.buffer[shader]
	if not self then return false end
	self.attenuationPower = attenuationPower
	dxSetShaderValue(self.shader, "lightAttenuationPower", self.attenuationPower)
	return true
end

function Light.setPointLightColor(shader, color)
	local self = Light.buffer[shader]
	if not self then return false end
	self.color = tocolor(color[1], color[2], color[3], color[4])
	return true
end

function Light.setPointLightFadeDistance(shader, fadeDist)
	local self = Light.buffer[shader]
	if not self then return false end
	self.fadeDist = fadeDist
	dxSetShaderValue(self.shader, "lightFadeDist", self.fadeDist.x, self.fadeDist.y)
	return true
end

function Light.setPointLightTesselationByDistance(shader)
	local self = Light.buffer[shader]
	if not self or not isSM3DBSupported then return false end
	local distFromCam = (self.position - cameraElement.matrix.position).length
	if distFromCam < 4*self.attenuation then 
		if not self.tesselationState then
			self.tesselationState = true
			dxSetShaderTessellation(self.shader, self.tesselationShape, self.tesselationShape)
			dxSetShaderValue(self.shader, "lightSubdivUnit", self.tesselationShape)
		end
	else
		if self.tesselationState then
			self.tesselationState = false
			dxSetShaderTessellation(self.shader, 0, 0)
			dxSetShaderValue(self.shader, "lightSubdivUnit", 1)
		end
	end
	return true
end

addEventHandler("onClientElementDestroy", root, function()
	if not Light.buffer[source] then return false end
	Light.buffer[source] = nil
end)

addEventHandler("onClientHUDRender", root, function()
	for shader, self in pairs(Light.buffer) do
		local clipDist = math.min(self.fadeDist.x, localCamera.farClipDistance + self.attenuation)
		local distFromCam = (self.position - cameraElement.matrix.position).length
		if (distFromCam < clipDist) and isEntityInFrontalSphere(self.position, self.attenuation) then		
			self.tickCount = self.tickCount + lastFrameTickCount + math.random(500)
			if self.tickCount > tesselationUpdateDelay then            
				Light.setPointLightTesselationByDistance(shader)
				self.tickCount = 0
			end
			dxDrawImage(0, 0, sX, sY, self.shader, 0, 0, 0, self.color)	
		end
	end
end, true, "high+100")

for i = 1, #Light.APIs, 1 do
	local j = Light.APIs[i]
	_G[j] = Light[j]
end