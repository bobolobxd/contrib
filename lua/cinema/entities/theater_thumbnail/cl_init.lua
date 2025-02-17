﻿-- This file is subject to copyright - contact swampservers@gmail.com for more information.
include('sh_init.lua')
ENT.RenderGroup = RENDERGROUP_OPAQUE
local ThumbWidth = 512 -- Expected to be PO2
local ThumbHeight = 384 -- Expected <= width

function ENT:Draw()
    self:DrawModel()
    self:SetModelScale(0.8)
    local scl = self:GetModelScale()
    local rscl = 0.98 * 0.1875 * scl
    local pos, ang = LocalToWorld(Vector(0.6, rscl * ThumbWidth * -0.5, rscl * ThumbHeight * 0.5), Angle(0, 90, 90), self:GetPos(), self:GetAngles())

    cam.Culled3D2D(pos, ang, rscl, function()
        self:DrawThumbnail()
    end)
end

function ENT:DrawThumbnail()
    local theatername_esc = self:GetTheaterName():gsub("<", "&lt;")

    if self:GetNWBool("Rentable") then
        location = self:GetNWInt("Location")
        local tb = protectedTheaterTable[location]

        if tb ~= nil and tb["time"] > 1 then
            theatername_esc = theatername_esc .. (theatername_esc ~= "" and "<br>" or "") .. [[<span style="color:#33ff33;">Protected</span>]]
        end
    end

    local videotitle = self:GetTitle()
    local thumbnail = self:GetThumbnail()

    if thumbnail == "" then
        thumbnail = "http://swamp.sv/s/img/default_thumbnail.png"
    end

    local background = [[background:black url(]] .. thumbnail:gsub("<", "&lt;") .. [[) no-repeat fixed center;]]

    if self:GetService() == "" then
        surface.SetDrawColor(80, 80, 80)
        surface.SetMaterial(Material["theater/static.vmt"])
        surface.DrawTexturedRect(0, 0, ThumbWidth - 1, ThumbHeight - 1)
        background = ""
    elseif IsValid(Me) and Me:FlashlightIsOn() then
        surface.SetDrawColor(80, 80, 80)
        surface.SetMaterial(Material["theater/static.vmt"]) --FIX WEIRD BUG
        surface.DrawTexturedRect(0, 0, 1, 1)
    end

    local setting = theatername_esc .. ":" .. videotitle .. ":" .. background

    if self.ThumbMat then
        local t = self.ThumbMat:GetTexture("$basetexture")

        if self.ThumbMat:IsError() or t == nil or t:IsError() or t:IsErrorTexture() then
            self.ThumbMat = nil
        end
    end

    if self.LastSetting ~= setting then
        if IsValid(self.HTML) then
            self.HTML:Remove()
        end

        -- 
        self.LastSetting = setting
        self.ThumbMat = nil
    elseif self.LastSetting and not self.ThumbMat then
        if not IsValid(self.HTML) then
            self.HTML = vgui.Create("HTML")
            self.HTML:SetSize(ThumbWidth, ThumbHeight)
            self.HTML:SetPaintedManually(true)
            self.HTML:SetKeyBoardInputEnabled(false)
            self.HTML:SetMouseInputEnabled(false)
            --<link href="https://fonts.googleapis.com/css2?family=Open+Sans+Condensed:wght@700&family=Righteous&display=swap" rel="stylesheet">
            self.HTML:SetHTML([[
<html>
<head>
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Open+Sans+Condensed:wght@700&display=swap" rel="stylesheet">
<style>
@font-face {
    font-family: 'Circular Std Medium';
    src: url(https://swamp.sv/fonts/circular.ttf);
    }
body {
    margin:0;
    ]] .. background .. [[
    background-size:contain;
    overflow: hidden;
}
div {
    color:white; 
    text-align: center;
    background-color: rgba(0,0,0,0.5);
}
#div1 {
    font-family: 'Circular Std Medium', sans-serif; /*'Righteous', sans-serif;*/
    text-transform: uppercase;
    font-size: 10vw;
}
#div2 {
    font-family: 'Circular Std Medium', sans-serif; /*'Times New Roman', serif;*/
    position:absolute;
    bottom:0;left:0;right:0;
}
span {
    white-space:nowrap;
}
</style>
</head>
<body>
    <div id="div1"><span id="span1">]] .. theatername_esc .. [[</span></div>
    <div id="div2"><span id="span2">]] .. videotitle:gsub("<", "&lt;") .. [[</span></div>
    <script>
    function autofont(el) {
        //div.style.fontSize = Math.min(10,((div.innerText.length > 45 ? 440 : 220)/div.innerText.length))+"vw";
        for(var i=10.0; i>0; i-=0.5) {
            el.style.fontSize = i+"vw";    
            if (el.getBoundingClientRect().width < 512) {
                break;
            }
        }
    }
    autofont(document.getElementById("span1"));
    autofont(document.getElementById("span2"));
    </script>
</body>
</html>
            ]])
            self.HTML.ConsoleMessage = function(self, msg) end

            return
        elseif not self.HTML:IsLoading() and not self.JSDelay then
            self.JSDelay = true

            -- Add delay to wait for JS to run
            timer.Simple(0.1, function()
                if not IsValid(self) then return end
                if not IsValid(self.HTML) then return end
                self.HTML:UpdateHTMLTexture()
                self.ThumbMat = self.HTML:GetHTMLMaterial()
                self.HTML:Remove()
                self.JSDelay = nil
            end)
        else
            -- Waiting for download to finish
            return
        end
    end

    -- Draw the HTML material
    if self.ThumbMat then
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(self.ThumbMat)
        surface.DrawTexturedRectUV(0, 0, ThumbWidth, ThumbHeight, 0, 0, 1, ThumbHeight / ThumbWidth)
    end
end
