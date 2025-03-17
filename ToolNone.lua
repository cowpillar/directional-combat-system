local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Animate").toolnone.ToolNoneAnim.AnimationId = ""
	end)
end)