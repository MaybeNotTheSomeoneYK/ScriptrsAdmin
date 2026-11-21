local guis = script.Parent:WaitForChild("ScriptrsAdminClient")
local remotes = game.ReplicatedStorage:WaitForChild("SARemotes")
local starttime = DateTime.now().UnixTimestampMillis

local actions = {
	EditClientInsProp = function(fullName,property,value)
		local c = game
		for _,i in fullName:split(".") do
			c = c:FindFirstChild(i)
			if not c then return end
		end
		pcall(function()c[property]=value end)
	end,
	NotifyClient = function(success,corename,message)
		local states = {
			[1] = {"Success","rbxassetid://85407855798945"};
			[2] = {"Error","rbxassetid://109525780243857"};
			[3] = {"Restricted","rbxassetid://129300755592624"};
		}
		local notice = script:WaitForChild("Elements").Notification:Clone()
		notice.Name = game.HttpService:GenerateGUID()
		notice.NotificationTitle.Text = corename.." / "..states[success][1]
		notice.NotificationText.Text = message
		notice.NotificationImage.Image = states[success][2]
		notice.Parent = guis.NotificationFrame
		notice.AnchorPoint = Vector2.new(1,1)
		local move = notice.AbsoluteSize.Y+5
		notice.AnchorPoint = Vector2.new(0,1)
		local tweens = {}
		for _,i in guis.NotificationFrame:GetChildren() do
			if i==notice then continue end
			table.insert(tweens,game.TweenService:Create(i,TweenInfo.new(.7),{Position = UDim2.new(i.Position.X.Scale,0,i.Position.Y.Scale,i.Position.Y.Offset-move)}))
		end
		table.insert(tweens,game.TweenService:Create(notice,TweenInfo.new(.7),{AnchorPoint = Vector2.new(1,1)}))
		for _,i in tweens do
			i:Play()
		end
		task.delay(90,function()
			game.TweenService:Create(notice,TweenInfo.new(.7),{AnchorPoint = Vector2.new(0,1)}):Play()
			game.Debris:AddItem(notice,.7)
		end)
	end,
	HintClient = function(text)
		local hint = script:WaitForChild("Elements").Hint:Clone()
		hint.Name = game.HttpService:GenerateGUID()
		hint.Text = text
		hint.LayoutOrder = starttime - DateTime.now().UnixTimestampMillis
		hint.Parent = guis.Hint.Container
		game.Debris:AddItem(hint,5)
		task.spawn(function()
			for i = 1,5 do
				guis.Hint.Container.ChildAdded:Wait()
			end
			game.Debris:AddItem(hint,0)
		end)
	end,
	AnnounceClient = function(text)
		local msg = script:WaitForChild("Elements").Message:Clone()
		msg.Name = game.HttpService:GenerateGUID()
		msg.Text = text
		msg.Parent = guis.Messages
		game.Debris:AddItem(msg,5)
		task.spawn(function()
			for i = 1,2 do
				guis.Messages.ChildAdded:Wait()
			end
			game.Debris:AddItem(msg,0)
		end)
	end,
	SendSystemChat = function(message)
		(game.TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem")::TextChannel):DisplaySystemMessage(message,"SASystemMessagte")
	end,
}

for _,i in remotes:GetChildren() do
	if i:IsA("RemoteEvent") and actions[i.Name] then
		i.OnClientEvent:Connect(function(...)actions[i.Name](...)end)
	elseif i:IsA("RemoteFunction") and actions[i.Name] then
		i.OnClientInvoke = (function(...)actions[i.Name](...)end)
	end
end

local function onchild()
	if #guis.Hint.Container:GetChildren() > 1 then
		guis.Hint.Size = UDim2.new(1,0,0,math.abs(game.GuiService:GetInsetArea(Enum.ScreenInsets.None).Min.Y))
	else
		guis.Hint.Size = UDim2.fromScale(1,0)
	end
end

guis.Hint.Container.ChildAdded:Connect(onchild)
guis.Hint.Container.ChildRemoved:Connect(onchild)

onchild()