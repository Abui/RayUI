local _, t = ...
local server = GetCVar("realmlist")
if ( server and server~="tw.logon.worldofwarcraft.com" ) then
    t.TRA2_S2T_WORD_MAP = nil
    t.TRA2_S2T_MAP = nil
    DEFAULT_CHAT_FRAME:AddMessage("检测到当前不是台湾服务器, 简繁转换自动停用。",1,1,0);
    return
end

TRADITIONALIZE2_REALTIME=true

local MAX_WORD_LENGTH = 0
for k,v in pairs(t.TRA2_S2T_WORD_MAP) do
	MAX_WORD_LENGTH = max(MAX_WORD_LENGTH, k:utf8len())
end

local EDIT_BOXES

local function convert(s)
	--ddebug("coverting "..s)
	local len = string.len(s)
	local result = ""

	--單字處理及中文字节位置處理, a爱c啊 -> {1,2,5,6,9}
	local i = 1
	local pos = {i}
	while i <= len do
		local ulen = utf8charbytes(s, i)
		local uchar = s:sub(i,i+ulen-1)
		result = result..(t.TRA2_S2T_MAP[uchar] or uchar)
		i = i+ulen
		table.insert(pos, i)
	end
	s = result

	local chars = #pos
	i = 1
	result = ""
	while i<chars do
		--假設最大的詞匯長度為3個UTF8字符, 则应截取pos[i]~pos[i+2]以及pos[i]~pos[i+1]两個字符串
		--ddebug(i.." "..min(MAX_WORD_LENGTH, chars-i+1))
		local matched = false
		for j = min(MAX_WORD_LENGTH-1, chars-i), 1, -1 do	--如果是3, 则从2循环到1
			--ddebug("i="..pos[i]..",j="..pos[i+j].." -> "..s:sub(pos[i], pos[i+j]-1))
			local map = t.TRA2_S2T_WORD_MAP[s:sub(pos[i], pos[i+j]-1)]
			if map then
				result = result..map
				matched = true
				i=i+j
				break
			end
		end

		if not matched then
			result = result..s:sub(pos[i], pos[i+1]-1)
			i=i+1
		end
	end

	return result
end

EDIT_BOXES = {
    "SendMailNameEditBox",
    "SendMailSubjectEditBox",
    "CT_MailNameEditBox",
    "CT_MailSubjectEditBox",
    "SendMailBodyEditBox",
    "StaticPopup1EditBox",
    "WhoFrameEditBox",
    "MacroPopupEditBox",
    "MacroFrameText",
    "GuildInfoEditBox",
    "StaticPopup1WideEditBox",
    "LFGComment",
    "ChatFrame1EditBox",
    "ChatFrame2EditBox",
    "ChatFrame3EditBox",
    "ChatFrame4EditBox",
    "ChatFrame5EditBox",
    "ChatFrame6EditBox",
    "ChatFrame7EditBox",
    "ChatFrame8EditBox",
    "ChatFrame9EditBox",
    "ChatFrame10EditBox",
    "AddFriendNoteEditBox",
}

-- if GetLocale() == "zhTW" then
    -- table.insert(EDIT_BOXES, "BrowseName") --简体客户端不需要转换物品名
-- end

local SendChatMessageSave = SendChatMessage;
function SendChatMessage(msg, type, lang, target)
    local status, newmsg = pcall(traditionalize, msg)
	SendChatMessageSave(status and newmsg or msg, type, lang, target);
end

local BNSendWhisperSave = BNSendWhisper
function BNSendWhisper(presenceID, text)
    local status, newmsg = pcall(traditionalize, text)
    BNSendWhisperSave(presenceID, status and newmsg)
end

function traditionalize_fake(str)
	return str;
end

function traditionalize_real(str)
	--ddebug(str)
	if (not str) then return "" end
	local len = string.len(str);
	local i = 1
	local result = ""
	local last = 1

	local flag_H, flag_h

	while i <= len do
		local code = string.byte(str, i)
		if code==124 and ( i==1 or string.byte(str, i-1)~=124 ) then
			local flag = string.byte(str, i+1) --判断|后面的字母
			if flag==72 then	--"H"
				flag_H = true
				result = result..convert(string.sub(str, last, i-1))
			
			elseif flag==104 then	--"h"
				flag_h = flag_h and flag_h+1 or 1
				if flag_h==2 then 
					flag_H=nil 
					flag_h=0
					last = i+2
				end

			elseif flag==99 then	--"c"

			elseif flag==114 then	--"r"

            else
				--error("error tag after \124 : "..string.char(flag))
                return str;
			end

			if flag==72 or flag==104 then
				i=i+1  --add 2 chars
				result=result.."|"..string.char(flag)
			end

		elseif flag_H then
			result = result..string.char(code)
		end

		i=i+1
	end
	--ddebug({str, last, len})
	if last<=len then result = result..convert(string.sub(str, last, len)) end
	return result;
end

traditionalize = traditionalize_real;

local function SetOrHookScript(frame, scriptName, func)
	if( frame:GetScript(scriptName) ) then
		frame:HookScript(scriptName, func);
	else
		frame:SetScript(scriptName, func);
	end
end

local frame = CreateFrame("Frame");
frame.timer = nil
frame:SetScript("OnUpdate", function(self, elapsed) 
	if(not self.timer) then return end
	self.timer = self.timer - elapsed
	if(self.timer<=0) then
		local cursur=frame.box:GetCursorPosition();
		frame.box:SetText(traditionalize(frame.box:GetText()));
		frame.box:SetCursorPosition(cursur);
		self.timer=nil
	end
end)
function TraditionalizeEditBox(frameName)
	if(not TraditionalizedEditBoxes[frameName] and _G[frameName]) then
		SetOrHookScript(_G[frameName], "OnChar", function (self)
			if TRADITIONALIZE2_REALTIME then
				frame.box = self
				frame.timer = frame.timer or 0.00000001
			end
		end);
		TraditionalizedEditBoxes[frameName] = 1;
	end
end

TraditionalizedEditBoxes = {};
frame:RegisterEvent("VARIABLES_LOADED"); --保证在所有插件加载后再hook
frame:RegisterEvent("ADDON_LOADED"); --保证拍卖行搜索框加载

function TraditionalizeFrame_OnEvent(self, event, addon)
	if(event == "VARIABLES_LOADED") then
        DEFAULT_CHAT_FRAME:AddMessage(traditionalize_real("繁体转换助手 by Warbaby 已加载."),1,1,0); --请保留此信息，谢。Warbaby留
		for _,v in pairs(EDIT_BOXES) do
			TraditionalizeEditBox(v);
		end
	elseif event == "ADDON_LOADED" and addon=="Blizzard_AuctionUI" and GetLocale() == "zhTW" then
		self:UnregisterEvent("ADDON_LOADED")
		TraditionalizeEditBox("BrowseName")
	end
end

frame:SetScript("OnEvent", TraditionalizeFrame_OnEvent);

function Traditionalize_Command(cmd)
	TRADITIONALIZE2_REALTIME = not TRADITIONALIZE2_REALTIME
	DEFAULT_CHAT_FRAME:AddMessage(traditionalize_real("<Warbaby's Traditionalize2> 即时转换已"..(TRADITIONALIZE2_REALTIME and "启用" or "关闭")), 1, 1, 0);
end

SLASH_TRADITIONALIZE1 = "/tradition";
SLASH_TRADITIONALIZE2 = "/tra";
SlashCmdList["TRADITIONALIZE"] = Traditionalize_Command;

BINDING_HEADER_TRADITIONALIZE = traditionalize_real("繁体转换助手");
BINDING_NAME_TRADITIONALIZE_TOGGLE = traditionalize_real("停用/启用即时转换");