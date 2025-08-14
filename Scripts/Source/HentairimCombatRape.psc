Scriptname HentairimCombatRape extends ActiveMagicEffect  

IVDTControllerScript Property MasterScript Auto
SexLabFramework Property SexLab Auto 
SexLabThread CurrentThread = None
actor Actorref
actor playerref
actor[] actorlist
bool isplayer
Bool OnHitprocessing

Spell CombatRapeTrackerSpell
string CurrentSceneID
string CurrentStageID
float updateRate
String CombatRapeFile  = "HentairimDirector/CombatRape.json"
Event OnEffectStart(Actor akTarget, Actor akCaster)
	
	PerformInitialization()
	Actorref = akTarget
	playerref = game.getplayer()
	isplayer = Actorref == playerref
EndEvent
Bool InScene
int enablehentairimcombatrape
int enablefemalefollowercombatrape
int enablemalefollowercombatrape
int enablenonfollowernpccombatrape
int combatrapecooldownhours
int onhitcooldownchecksseconds
int femalexfemaleusemalepositions
int futaxfutausemalepositions
int futaxmaleusefemalefemdompositions
int malexmaleusefemalepositions
int malexfutausefemalepositions
float minhealthpercentagetotrigger
float maxhealthpercentagetotrigger
float chancetotriggeronpowerattack
float chancetotriggeronnormalattack
float pccombatrapetimermodifier
float health
float LastHitTime
Float LastRapeTime

Function PerformInitialization()
	;register events
	;RegisterForTheEventsWeNeed()
	CombatRapeTrackerSpell =  Game.GetFormFromFile(0x801, "Hentairim Director.esp") as Spell
	;load Combat config
	enablehentairimcombatrape = JsonUtil.GetIntValue(CombatRapeFile, "enablehentairimcombatrape" ,0)
	enablefemalefollowercombatrape = JsonUtil.GetIntValue(CombatRapeFile, "enablefemalefollowercombatrape" ,0)
	enablemalefollowercombatrape = JsonUtil.GetIntValue(CombatRapeFile, "enablemalefollowercombatrape" ,0)
	combatrapecooldownhours = JsonUtil.GetIntValue(CombatRapeFile, "combatrapecooldownhours" ,0)
	onhitcooldownchecksseconds = JsonUtil.GetIntValue(CombatRapeFile, "onhitcooldownchecksseconds" ,0)
	femalexfemaleusemalepositions = JsonUtil.GetIntValue(CombatRapeFile, "femalexfemaleusemalepositions" ,0)
	futaxfutausemalepositions = JsonUtil.GetIntValue(CombatRapeFile, "futaxfutausemalepositions" ,0)
	futaxmaleusefemalefemdompositions = JsonUtil.GetIntValue(CombatRapeFile, "futaxmaleusefemalefemdompositions" ,0)
	malexmaleusefemalepositions = JsonUtil.GetIntValue(CombatRapeFile, "malexmaleusefemalepositions" ,0)
	malexfutausefemalepositions = JsonUtil.GetIntValue(CombatRapeFile, "malexfutausefemalepositions" ,0)
	minhealthpercentagetotrigger = JsonUtil.GetFloatValue(CombatRapeFile, "minhealthpercentagetotrigger" ,0)
	maxhealthpercentagetotrigger = JsonUtil.GetFloatValue(CombatRapeFile, "maxhealthpercentagetotrigger" ,0)
	chancetotriggeronpowerattack = JsonUtil.GetFloatValue(CombatRapeFile, "chancetotriggeronpowerattack" ,0)
	chancetotriggeronnormalattack = JsonUtil.GetFloatValue(CombatRapeFile, "chancetotriggeronnormalattack" ,0)
	pccombatrapetimermodifier = JsonUtil.GetFloatValue(CombatRapeFile, "pccombatrapetimermodifier" ,0)
	
EndFunction

Event OnPlayerLoadGame()
	PerformInitialization()
	OnHitprocessing = false
	RefreshFollowersTrackers()
	LastHitTIme = 0
	LastRapeTime = 0
EndEvent


Actor Aggressor

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	 if akSource == None || akAggressor == None || akSource as Spell != None || sexlab.ValidateActor(actorref) <= 0
        return
    endif
	
	Aggressor = akAggressor as actor

	;Check CD
	if  OnHitprocessing || !CanGetRaped(actorref) ||  Utility.getcurrentrealtime() - LastHitTIme <= onhitcooldownchecksseconds ||  sexlabutil.GetCurrentGameTimeHours() - LastRapeTime <= combatrapecooldownhours
		;miscutil.PrintConsole("CD Check - OnHit: " + (Utility.GetCurrentRealTime() - LastHitTIme) + "<=" + onhitcooldownchecksseconds + " = " + ((Utility.GetCurrentRealTime() - LastHitTIme) <= onhitcooldownchecksseconds) + ", RapeCD: " + (SexLabUtil.GetCurrentGameTimeHours() - LastRapeTime) + "<=" + combatrapecooldownhours + " = " + ((SexLabUtil.GetCurrentGameTimeHours() - LastRapeTime) <= combatrapecooldownhours))
		return
	endif
	
	LastHitTime = Utility.getcurrentrealtime()
	;if CD conditions met, check other conditions
	if !CanTriggerOnAttack(abPowerAttack , abHitBlocked) || Aggressor.isplayerteammate() || !HealthWithinRapeLimit(actorref) || Aggressor == playerref 
		;miscutil.PrintConsole("Cond Check - !CanTrigger: " + !CanTriggerOnAttack(abPowerAttack , abHitBlocked) + ", !CanBeRaped: " + ", !CanGetRaped: " + !CanGetRaped(actorref) + ", Teammate: " + Aggressor.IsPlayerTeammate() + ", !Health OK: " + !HealthWithinRapeLimit(actorref) + ", aggressor IsPlayer: " + (Aggressor == playerref))
		return
	endif
	OnHitprocessing = true

	Utility.wait(2)
	;trigger combat rape
	SetHentairimTimerandSceneType()

	string applytags = ChangeAggressorandVictimSex(Aggressor , actorref)
	actor[] ActorsToFuck = new actor[2]
	Actorstofuck[0] = Actorref
	Actorstofuck[1] = Aggressor

	sexlab.startscene(Actorstofuck,applytags,actorref)
	
	LastRapeTime = sexlabutil.GetCurrentGameTimeHours()
	OnHitprocessing = false
EndEvent


Bool Function HealthWithinRapeLimit(actor char)
	float basehealth = char.GetBaseActorValue("Health")
	float Currenthealth = char.GetActorValue("Health")
	float RemainingHealthPc = Currenthealth / basehealth
;	miscutil.PrintConsole("Health Check - Base: " + basehealth + ", Current: " + Currenthealth + ", %: " + RemainingHealthPc + ", Range: " + minhealthpercentagetotrigger + "-" + maxhealthpercentagetotrigger + ", Pass: " + (RemainingHealthPc >= minhealthpercentagetotrigger && RemainingHealthPc <= maxhealthpercentagetotrigger))

	return RemainingHealthPc >= minhealthpercentagetotrigger && RemainingHealthPc <= maxhealthpercentagetotrigger
EndFunction

function RefreshFollowersTrackers()
if actorref != playerref
	return
endif
actor[] Followers = PO3_SKSEFunctions.GetPlayerFollowers()

int z
while z < followers.length

	if followers[z].hasspell(CombatRapeTrackerSpell)
		followers[z].removespell(CombatRapeTrackerSpell)
	endif
	
	if enablehentairimcombatrape == 1 && ((sexlab.GetGender(followers[z]) == 1 && enablefemalefollowercombatrape) || (sexlab.GetGender(followers[z]) == 0 && enablemalefollowercombatrape))
		followers[z].addspell(CombatRapeTrackerSpell)
	endif
	z += 1
endwhile
endfunction


Bool Function CanGetRaped(actor char)
	if enablehentairimcombatrape != 1
		return false
	elseif char.isplayerteammate() && enablefemalefollowercombatrape != 1 && sexlab.GetGender(char) == 1
		return false
	elseif char.isplayerteammate() && enablemalefollowercombatrape != 1 && sexlab.GetGender(char) == 0
		return false
	else
		return true
	endIf
EndFunction

Bool Function CanTriggerOnAttack(Bool isPowerAttack , bool isBlocked)
	float blockmultiplier = 1
	if isBlocked
		blockmultiplier = 0.3
	endif
	if enablehentairimcombatrape != 1
		return false
	elseif isPowerAttack && chancetotriggeronpowerattack * blockmultiplier >= Utility.randomfloat(0,1)
		return true
	elseif chancetotriggeronnormalattack * blockmultiplier >= Utility.randomfloat(0,1)
		return true
	else
		return false
	endIf
EndFunction

Function SetHentairimTimerandSceneType()
	storageutil.setfloatvalue(none,"HentairimTimerModifier",pccombatrapetimermodifier)
	
	storageutil.Setintvalue(none,"HentairimNextUseLinearScene",1)
endfunction

string Function ChangeAggressorandVictimSex(actor Aggressoractor,actor Victimactor)
	int AggressorGender = Sexlab.getsex(Aggressoractor)
	int VictimGender = Sexlab.getsex(Victimactor)
	string tagstoapply
	if AggressorGender == 0 && VictimGender == 2 && malexfutausefemalepositions == 1 ;male is aggressor , victim is futa
		sexlab.treatasfemale(Victimactor)
		tagstoapply = "Aggressive"
	elseif AggressorGender == 2 && VictimGender == 2 && futaxfutausemalepositions == 1
		sexlab.treatasfemale(Victimactor)
		tagstoapply = "Aggressive"
	elseif AggressorGender == 2 && VictimGender == 0 && futaxmaleusefemalefemdompositions == 1 ;futa is aggressor , male is victim
		sexlab.treatasfemale(Aggressoractor)
		if Utility.randomint(1,2) == 1
			tagstoapply = "femdom"
		else
			tagstoapply = "cowgirl"
		endif
	elseif AggressorGender == 1 && VictimGender == 1 && femalexfemaleusemalepositions == 1
		sexlab.treatasfuta(Aggressoractor)
		tagstoapply = "Aggressive"
	elseif  AggressorGender == 0 && VictimGender == 0 && malexmaleusefemalepositions == 1
		sexlab.treatasfemale(Victimactor)
		tagstoapply = "Aggressive"
	elseif AggressorGender > 2
		sexlab.treatasfemale(Victimactor)
		tagstoapply = "~2ASVP,~3ASVP,~3AFVP,~4AFVP,~5AFVP,~6AFVP,~7AFVP,-2ASCG,-3ASCG,-4ASCG"
	endif
	return tagstoapply
EndFunction

; Return this actors sex
; Mapping: Male = 0 | Female = 1 | Futa = 2 | CrtMale = 3 | CrtFemale = 4
;int Function GetSex(Actor akActor)
;  return SexlabRegistry.GetSex(akActor, false)
;EndFunction