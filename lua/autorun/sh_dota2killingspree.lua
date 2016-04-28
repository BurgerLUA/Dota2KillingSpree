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
				attacker.KN_ResetKill = CurTime() + 17
				
				KN_SendData(attacker,victim)
				
			end
			
			victim.KN_Spree = 0
			victim.KN_Multikill = 0
			
		end

	end

	hook.Add("PlayerDeath","KN_PlayerDeath",KN_PlayerDeath)
	
	function KN_PlayerSpawn(ply)
		ply.KN_Spree = 0
		ply.KN_Multikill = 0
	end
	
	hook.Add("PlayerSpawn","KN_PlayerSpawn",KN_PlayerSpawn)
	

	function KN_Think()

		for k,v in pairs(player.GetAll()) do
			if v.KN_ResetKill then
				if v.KN_ResetKill ~= 0 then 
					if v.KN_ResetKill <= CurTime() then
						v.KN_Multikill = 0
						v.KN_ResetKill = 0
					end
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
			chat.AddText(team.GetColor(Attacker:Team()),Attacker:Nick(),White,SpreeCorrection,KN_TranslateKillingSpreeColor(SpreeNum),KN_TranslateKillingSpreeText(SpreeNum),White," with a ",KN_TranslateMultiKillColor(KillNum),KN_TranslateMultiKillText(KillNum))
		
			KN_EmitSound( KN_TranslateKillingSpreeSound(SpreeNum) )
			
			timer.Simple(1.5,function()
				KN_EmitSound( KN_TranslateMultiKillSound(KillNum) )
			end)
			
			timer.Simple(3,function()
				KN_EmitSound( "bill/wow"..math.random(1,12)..".wav" )
			end)
			
		elseif WriteSpree then
			chat.AddText(team.GetColor(Attacker:Team()),Attacker:Nick(),White,SpreeCorrection,KN_TranslateKillingSpreeColor(SpreeNum),KN_TranslateKillingSpreeText(SpreeNum))
			KN_EmitSound( KN_TranslateKillingSpreeSound(SpreeNum) )
		elseif WriteMultikill then
			chat.AddText(team.GetColor(Attacker:Team()),Attacker:Nick(),White," got a ",KN_TranslateMultiKillColor(KillNum),KN_TranslateMultiKillText(KillNum))
			KN_EmitSound( KN_TranslateMultiKillSound(KillNum) )
		end
		
	
	
	end)
	
	function KN_EmitSound(sound)
	
		EmitSound( sound, LocalPlayer():GetPos(), LocalPlayer():EntIndex(), CHAN_VOICE2, 1, SNDLVL_180dB, SND_CHANGE_VOL, 100 )
	
	end
	
	function KN_TranslateKillingSpreeSound(num)
	
		local SpreeTable = {}
		SpreeTable[3] = "dota/Announcer_kill_spree_01.mp3"
		SpreeTable[4] = "dota/Announcer_kill_dominate_01.mp3"
		SpreeTable[5] = "dota/Announcer_kill_mega_01.mp3"
		SpreeTable[6] = "dota/Announcer_kill_unstop_01.mp3"
		SpreeTable[7] = "dota/Announcer_kill_wicked_01.mp3"
		SpreeTable[8] = "dota/Announcer_kill_monster_01.mp3"
		SpreeTable[9] = "dota/Announcer_kill_godlike_01.mp3"
		SpreeTable[10] = "dota/Announcer_kill_holy_01.mp3"
		
		return SpreeTable[math.Clamp(num,3,10)]
	
	end
	
	function KN_TranslateMultiKillSound(num)
	
		local KillTable = {}
		KillTable[2] = "dota/Announcer_kill_double_01.mp3"
		KillTable[3] = "dota/Announcer_kill_triple_01.mp3"
		KillTable[4] = "dota/Announcer_kill_ultra_01.mp3"
		KillTable[5] = "dota/Announcer_kill_rampage_01.mp3"
		
		return KillTable[math.Clamp(num,2,5)]

	end
	
	function KN_TranslateKillingSpreeColor(num)
	
		local SpreeTable = {}
		SpreeTable[3] = Color(0,255,255,255)
		SpreeTable[4] = Color(200,0,200,255)
		SpreeTable[5] = Color(100,0,100,255)
		SpreeTable[6] = Color(0,255,0,255)
		SpreeTable[7] = Color(255,255,0,255)
		SpreeTable[8] = Color(255,100,0,255)
		SpreeTable[9] = Color(255,0,0,255)
		SpreeTable[10] = Color(255,0,0,255)
		
		return SpreeTable[math.Clamp(num,3,10)]

	end
	
	function KN_TranslateMultiKillColor(num)
	
		local KillTable = {}
		KillTable[2] = Color(255,255,0,255)
		KillTable[3] = Color(255,200,0,255)
		KillTable[4] = Color(255,100,0,255)
		KillTable[5] = Color(255,0,0,255)
		
		return KillTable[math.Clamp(num,2,5)]

	end

	

	function KN_TranslateKillingSpreeText(num)
	
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
	
	function KN_TranslateMultiKillText(num)
	
		local KillTable = {}
		KillTable[2] = "Double Kill!"
		KillTable[3] = "TRIPLE Kill!"
		KillTable[4] = "ULTRA KILL!"
		KillTable[5] = "RAMPAGE!!!"
		
		return KillTable[math.Clamp(num,2,5)]

	end


end