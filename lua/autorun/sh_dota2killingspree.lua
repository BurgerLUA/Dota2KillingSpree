local KN_MESSAGETYPE_KILLJOY = 0
local KN_MESSAGETYPE_KILLINGSPREE = 1
local KN_MESSAGETYPE_MULTIKILL = 2

if SERVER then

	function KN_PlayerInitialSpawn(ply)
		
		ply.KN_Spree = 0
		ply.KN_Multikill = 0
		ply.KN_ResetKill = 0
	
	end

	hook.Add("PlayerInitialSpawn","KN_PlayerInitialSpawn",KN_PlayerInitialSpawn)

	function KN_PlayerDeath(victim,inflictor,attacker)

		if attacker:IsPlayer() and victim:IsPlayer() then

			if attacker ~= victim then

				attacker.KN_Spree = attacker.KN_Spree + 1
				attacker.KN_Multikill = attacker.KN_Multikill + 1
				attacker.KN_ResetKill = CurTime() + 10
				
				KN_SendData(attacker,victim)
				
			end
			
			victim.KN_Spree = 0
			
		end

	end

	hook.Add("PlayerDeath","KN_PlayerDeath",KN_PlayerDeath)

	function KN_Think()

		for k,v in pairs(player.GetAll()) do
			if v.KN_ResetKill ~= 0 then 
				if v.KN_ResetKill <= CurTime() then
					v.KN_Multikill = 0
					v.KN_ResetKill = 0
				end
			end
		end

	end

	hook.Add("Think","KN_Think",KN_Think)

	util.AddNetworkString( "KN_ServerToClient" )
	
	function KN_SendData(attacker,victim)
	
		local Data = {
			attacker = attacker,
			victim = victim,
			victimspree = victim.KN_Spree,
			attackerspree = attacker.KN_Spree,
			attackermultikill = attacker.KN_Multikill
		}

		net.Start("KN_ServerToClient")
			net.WriteTable(Data)
		net.Broadcast()

	end
	
	

	
end


if CLIENT then

	net.Receive("KN_ServerToClient", function(len)
	
		local Data = net.ReadTable()
		
		local WriteSpree = false
		local WriteMultikill = false
		
		local Attacker = Data.attacker
		local Victim = Data.victim
		local SpreeNum = Data.attackerspree
		local KillNum = Data.attackermultikill
		
		local SpreeCorrection = " is "
		
	
		local White = Color(255,255,255,255)
	
		if SpreeNum >= 3 then
			WriteSpree = true
		end
		
		if KillNum >= 2 then
			WriteMultikill = true
		end
		
		if SpreeNum == 3 or SpreeNum == 5 or SpreeNum == 8 then
			SpreeCorrection = " is on a "
		end
		
		
		if WriteSpree and WriteMultikill then
			chat.AddText(team.GetColor(Attacker:Team()),Attacker:Nick(),White,SpreeCorrection,Color(200,0,200,255),KN_TranslateKillingSpree(SpreeNum),White," with a ",Color(200,0,200,255),KN_TranslateMultiKill(KillNum))
		elseif WriteSpree then
			chat.AddText(team.GetColor(Attacker:Team()),Attacker:Nick(),White,SpreeCorrection,Color(200,0,200,255),KN_TranslateKillingSpree(SpreeNum))
		elseif WriteMultikill then
			chat.AddText(team.GetColor(Attacker:Team()),Attacker:Nick(),White," got a ",Color(200,0,200,255),KN_TranslateMultiKill(KillNum))
		end
		
		
	
	
	end)

	function KN_TranslateKillingSpree(num)
	
		local SpreeTable = {}
		SpreeTable[3] = "Killing Spree"
		SpreeTable[4] = "Dominating"
		SpreeTable[5] = "Mega Kill"
		SpreeTable[6] = "Unstoppable"
		SpreeTable[7] = "Wicked Sick"
		SpreeTable[8] = "Monster Kill"
		SpreeTable[9] = "Godlike"
		SpreeTable[10] = "Beyond Godlike"
		
		return SpreeTable[math.Clamp(num,3,10)]

	end
	
	function KN_TranslateMultiKill(num)
	
		local KillTable = {}
		KillTable[2] = "Double Kill!"
		KillTable[3] = "TRIPLE Kill!"
		KillTable[4] = "ULTRA KILL!"
		KillTable[5] = "RAMPAGE!!!"
		
		return KillTable[math.Clamp(num,2,5)]

	end


end