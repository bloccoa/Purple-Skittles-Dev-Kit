--!strict
local LightingModule = {}

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

function LightingModule:update(v: Folder | any, theTweenInfo: TweenInfo?)
    if not v:FindFirstChild("child") then
        warn("LightingModule: Invalid folder")
        return
    end

    local tweenInfo: TweenInfo = theTweenInfo or TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    local goal = {
        Brightness = v.Brightness.Value,
        Ambient = v.Ambient.Value,
        FogColor = v.FogColor.Value,
        ClockTime = v.ClockTime.Value,
        FogEnd = v.FogEnd.Value,
        FogStart = v.FogStart.Value,
        EnvironmentDiffuseScale = v.EnvironmentDiffuseScale.Value,
        EnvironmentSpecularScale = v.EnvironmentSpecularScale.Value,
        GeographicLatitude = v.GeographicLatitude.Value,
        OutdoorAmbient = v.OutdoorAmbient.Value,
        ColorShift_Top = v.ColorShift_Top.Value,
        ColorShift_Bottom = v.ColorShift_Bottom.Value,
        ShadowSoftness = v.ShadowSoftness.Value,
        ExposureCompensation = v.ExposureCompensation.Value,
    }
    local tween1 = TweenService:Create(Lighting, tweenInfo, goal)
    if Lighting:FindFirstChild("ColorCorrection") and v.child:FindFirstChild("ColorCorrection") then
        local colorcorrection = TweenService:Create(
            Lighting.ColorCorrection,
            tweenInfo,
            {
                Brightness = v.child.ColorCorrection.Brightness,
                Contrast = v.child.ColorCorrection.Contrast,
                Saturation = v.child.ColorCorrection.Saturation,
                TintColor = v.child.ColorCorrection.TintColor,
            }
        )
        colorcorrection:Play()
    end
    tween1:Play()

    for _, oink in ipairs(Lighting:GetChildren()) do
        if not oink:IsA("ColorCorrectionEffect") then
            oink:Destroy()
        end
    end
    for _, oink in ipairs(v.child:GetChildren()) do
        if not oink:IsA("ColorCorrectionEffect") then
            oink:Clone().Parent = Lighting
        end
    end
    Lighting.GlobalShadows = v.GlobalShadows.Value
end

function LightingModule:create(parent: any, name: string)
    local lightfolder = script.sample:Clone()
    lightfolder.Parent = parent
    lightfolder.Name = name

    for i, v in pairs(Lighting:GetChildren()) do
        v.Parent = lightfolder.child
    end

    lightfolder.Ambient.Value = Lighting.Ambient -- theres no other way btw Thx roblox
    lightfolder.Brightness.Value = Lighting.Brightness
    lightfolder.ClockTime.Value = Lighting.ClockTime
    lightfolder.ColorShift_Bottom.Value = Lighting.ColorShift_Bottom
    lightfolder.ColorShift_Top.Value = Lighting.ColorShift_Top
    lightfolder.EnvironmentDiffuseScale.Value = Lighting.EnvironmentDiffuseScale
    lightfolder.EnvironmentSpecularScale.Value = Lighting.EnvironmentSpecularScale
    lightfolder.FogColor.Value = Lighting.FogColor
    lightfolder.FogEnd.Value = Lighting.FogEnd
    lightfolder.FogStart.Value = Lighting.FogStart
    lightfolder.GeographicLatitude.Value = Lighting.GeographicLatitude
    lightfolder.OutdoorAmbient.Value = Lighting.OutdoorAmbient
    lightfolder.GlobalShadows.Value = Lighting.GlobalShadows
    lightfolder.ShadowSoftness.Value = Lighting.ShadowSoftness
    lightfolder.ExposureCompensation.Value = Lighting.ExposureCompensation
end

return LightingModule
