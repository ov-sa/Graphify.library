local Light = {
	buffer = {},
	APIs = {
		"createSpotLight",
		"setSpotLightPosition",
		"setSpotLightRotation",
		"setSpotLightAttenuation",
		"setSpotLightAttenuationPower",
		"setSpotLightTheta",
		"setSpotLightPhi",
		"setSpotLightFallOff",
		"setSpotLightDirection",
		"setSpotLightColor",
		"setSpotLightFadeDistance"
	}
}

function Light.createSpotLight(position, attenuation, color)
	local cShader = {
		tickCount = 0,
		shader = dxCreateShader(getSpotLightFX()),
		position = position,
		attenuation = attenuation,
		attenuationPower = 2,
		theta = 0.1,
		phi = 0.6,
		falloff = 1,
		direction = Vector3(0, 0, -1),
		fadeDist = Vector2(950, 850),
		tesselationState = false,
		tesselationShape = 8
	}
	Light.buffer[(cShader.shader)] = cShader
	dxSetShaderValue(cShader.shader, "lightPixelSize", 1/sX, 1/sY)
	dxSetShaderValue(cShader.shader, "lightHalfPixel", 1/(sX*2), 1/(sY*2))
	dxSetShaderValue(cShader.shader, "layerRT", layerRT)
	Light.setSpotLightPosition(cShader.shader, cShader.position)
	Light.setSpotLightAttenuation(cShader.shader, cShader.attenuation)
	Light.setSpotLightAttenuationPower(cShader.shader, cShader.attenuationPower)
	Light.setSpotLightTheta(cShader.shader, cShader.theta)
	Light.setSpotLightPhi(cShader.shader, cShader.phi)
	Light.setSpotLightFallOff(cShader.shader, cShader.falloff)
	Light.setSpotLightDirection(cShader.shader, cShader.direction)
	Light.setSpotLightColor(cShader.shader, color)
	Light.setSpotLightFadeDistance(cShader.shader, cShader.fadeDist)
	Light.setSpotLightTesselationByDistance(cShader.shader)
	return cShader.shader
end

function Light.setSpotLightPosition(shader, position)
	local self = Light.buffer[shader]
	if not self then return false end
	self.position = position
	dxSetShaderValue(self.shader, "lightPosition", self.position.x, self.position.y, self.position.z)
	return true
end

function Light.setSpotLightRotation(shader, rotation)
	local self = Light.buffer[shader]
	if not self then return false end
	local rot = {math.rad(rotation.x), math.rad(rotation.y), math.rad(rotation.z)}
	self.direction = Vector3(-math.cos(rot[1])*math.sin(rot[3]), math.cos(rot[3])*math.cos(rot[1]), math.sin(rot[1]))
	dxSetShaderValue(self.shader, "lightViewDirection", self.direction.x, self.direction.y, self.direction.z)
	return true
end

function Light.setSpotLightAttenuation(shader, attenuation)
	local self = Light.buffer[shader]
	if not self then return false end
	self.attenuation = attenuation
	dxSetShaderValue(self.shader, "lightAttenuation", self.attenuation)
	Light.setSpotLightTesselationByDistance(shader)
	return true
end

function Light.setSpotLightAttenuationPower(shader, attenuationPower)
	local self = Light.buffer[shader]
	if not self then return false end
	self.attenuationPower = attenuationPower
	dxSetShaderValue(self.shader, "lightAttenuationPower", self.attenuationPower)
	return true
end

function Light.setSpotLightTheta(shader, theta)
	local self = Light.buffer[shader]
	if not self then return false end
	self.theta = theta
	dxSetShaderValue(self.shader, "lightTheta", self.theta)
	return true
end

function Light.setSpotLightPhi(shader, phi)
	local self = Light.buffer[shader]
	if not self then return false end
	self.phi = phi 
	dxSetShaderValue(self.shader, "lightPhi", self.phi)
	return true
end

function Light.setSpotLightFallOff(shader, falloff)
	local self = Light.buffer[shader]
	if not self then return false end
	self.falloff = falloff 
	dxSetShaderValue(self.shader, "lightFallOff", self.falloff)
	return true
end

function Light.setSpotLightDirection(shader, direction)
	local self = Light.buffer[shader]
	if not self then return false end
	self.direction = direction
	dxSetShaderValue(self.shader, "lightViewDirection", self.direction.x, self.direction.y, self.direction.z)
	return true
end	

function Light.setSpotLightColor(shader, color)
	local self = Light.buffer[shader]
	if not self then return false end
	self.color = tocolor(color[1], color[2], color[3], color[4])
	return true
end

function Light.setSpotLightFadeDistance(shader, fadeDist)
	local self = Light.buffer[shader]
	if not self then return false end
	self.fadeDist = fadeDist
	dxSetShaderValue(self.shader, "lightFadeDist", self.fadeDist.x, self.fadeDist.y)
	return true
end

function Light.setSpotLightTesselationByDistance(shader)
	local self = Light.buffer[shader]
	if not self or not isSM3DBSupported then return false end
	local distFromCam = (self.position - cameraElement.matrix.position).length
	if distFromCam < 12*self.attenuation then 
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
				Light.setSpotLightTesselationByDistance(shader)
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