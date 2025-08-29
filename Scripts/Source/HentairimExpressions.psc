Scriptname HentairimExpressions extends ActiveMagicEffect  

IVDTControllerScript Property MasterScript Auto
SexLabFramework Property SexLab Auto 
SexLabThread CurrentThread = None
actor Actorref
actor[] actorlist
int position
string role = "c"
String[] PhaseExpressionsArr
string PhaseLookup 
int Phase = 1
int ExpressionPhase
int variance 
float speed = 0.50
string LabelGroup

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Actorref = akTarget
	PrintDebug("Effect Start for " + Actorref.getdisplayname() )	
		
	PerformInitialization()
	
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)

EndEvent

Function PerformInitialization()
PrintDebug("Perform Initialization")	
	
	CurrentThread = Sexlab.GetThreadByActor(Actorref)
	actorlist = CurrentThread.GetPositions()
	
	;establish positions
	position = CurrentThread.GetPositionIdx(actorref)
	
	RegisterForTheEventsWeNeed()
	
	if sexlab == none
		PrintDebug("oh noes sexlab is none!")	
	endif
	
	if CurrentThread == none
		PrintDebug("oh noes Sexlab Thread is none!")	
	endif
	
	if MasterScript == none
		PrintDebug("oh noes Director is none!")	
	endif
	
	PrintDebug("actor list" + actorlist)

	;Base Hentairim Preparation
	InitializeConfigandForms()
	HentairimPrepare()	
	CheckHasMFEE()
	printdebug("initialized complete")
	RegisterForSingleUpdate(0.1)
EndFunction

Function RegisterForTheEventsWeNeed()
	printdebug("Registering Event")
	RegisterForModEvent("AnimationEnd", "ExpressionsSceneEnd")
	RegisterForModEvent("SexLabOrgasmSeparate", "ExpressionsOrgasm") 
	RegisterForModEvent("StageStart", "ExpressionsOnStageStart")

EndFunction

Event ExpressionsSceneEnd(string eventName, string argString, float argNum, form sender);

EndEvent


Event ExpressionsOnStageStart(string eventName, string argString, float argNum, form sender)
	if threadid == argstring
		position = currentthread.getpositionidx(actorref)
	endif
EndEvent

float LastOrgasmtime

Event ExpressionsOrgasm(Form akactor, Int thread)
	If akactor != actorRef
		Return
	EndIf
	IsOrgasming = true
	LastOrgasmtime =  CurrentThread.GetTimeTotal()

EndEvent

Event OnUpdate()

	;Ends if actor is no longer in scene but magic stuck for some reason

	if !Sexlab.GetThreadByActor(actorref)
		RemoveExpressions()
	endif
	
	while MasterScript.isupdating() ;wait for director to finish updating
		Utility.wait(0.1)
		printdebug("Waiting for Director to finish Updating")
	endwhile
		
	HentairimUpdateStageData()
	
	if (IsBroken() && enableahegao == 1) || (IsCunnilingus() && cunusetongue == 1) 
		printdebug("Adding Tongue")
		AddTongue()
	endif
	
	;if still orgasming, maintain orgasm face
	if GetSecondsSinceLastOrgasm() > 4
		IsOrgasming = false
	endif
	
	;set Role
	if IsVictim && !isbroken()
		Role = "v"
	else
		Role = "c"
	endif
	
	;Check if should add tongue or ahegao

	if !IsBroken() && HasMFEE && EnabledMFEEAhegao == 1
		MFEEAddAhegao = false
	endif
		
	if IsSuckingoffOther() && removetongueonblowjob == 1
		RemoveTongue()
		printdebug("Removing Tongue during  blowjob")
	elseif IsBroken() && HasMFEE && EnabledMFEEAhegao == 1
		RemoveTongue()
		MFEEAddAhegao = true
		printdebug("Starting MFEE Ahegao")
	endif
	
	;------------------START RUNNING EXPRESSIONS--------------------
	;-----------------------------START Looking Up Expression Array------------------------------			
	if IsUnconcious()
			MfgConsoleFunc.SetModifier(actorref, 0, 100) ;left blink
			MfgConsoleFunc.SetModifier(actorref, 1, 100) ;right blink
			MfgConsoleFunc.SetPhoneme(actorref,0,60) ; aah
	else
	
			LabelGroup = Role + GetHentaiExpression() + ExpressionGroup
	 
			int ExpressionIndex = 0

			;printdebug(ActorName + " : " + OralTagGroup + " - " + PenetrationTagGroup + " - " + PenisActionTagGroup + " - " + StimulationTagGroup + " - " + EndingTagGroup
	
			Speed = ExpressionSpeed()

			PhaseLookup = LabelGroup + Phase
	
			printdebug("Expression Looking up : " + PhaseLookup)
			PhaseExpressionsArr = papyrusutil.stringsplit(JsonUtil.GetStringValue(ExpressionsFile,Phaselookup,"") ,",")
;-----------------------------START CYCLE RUNNING EXPRESSION PHASES------------------------------	

			PhaseExpressionsArr = papyrusutil.stringsplit(JsonUtil.GetStringValue(ExpressionsFile,Phaselookup,"") ,",")
			variance = PhaseExpressionsArr[32] as int
				
		if PhaseExpressionsArr.length < 32
			miscutil.printconsole(" Expressions :" + phaselookup +" only has " +phaseExpressionsArr.length+ "items . it is either incorrectly formatted or missing in the json file.")		
		endif
					
				;begin updating expressions
	;-----------------------------------------Set EXPRESSION-----------------------------------------
			;MFEE is applied differently from the array for MFG values, and overrides the MFG array if have Ahegao and tongue out phoneme for Erin
		if MFEEAddAhegao ;MFEE ahegao also includes broken condition. uses array's expression for variety of face movements
				
			if MuFacialExpressionExtended.GetExpressionValueByNumber(actorref,0,1) != 100
				MuFacialExpressionExtended.SetExpressionByNumber(actorref,0,0,100) ;ahegao 1
			endif
				
				;make sure tongue out and tongue down is not applied to as ahegao already has tongue out and down
			if MuFacialExpressionExtended.GetExpressionValueByNumber(actorref,8,0) != 0 || MuFacialExpressionExtended.GetExpressionValueByNumber(actorref,2,0) != 0
				MuFacialExpressionExtended.SetExpressionByNumber(actorref,8,0,0) ;tongueout
				MuFacialExpressionExtended.SetExpressionByNumber(actorref,8,2,0) ;tongue down
			endif
				
		elseif IsBroken()
			PhaseExpressionsArr[31] = BrokenOverride[31]

		endif	

	;------------------------------------------------Set PHONEME-------------------------------------------------
		while ExpressionIndex <= 15 && (!IsUnconcious() ||  EquippedTongue()) 
			int upperlimit = PhaseExpressionsArr[ExpressionIndex] as int*(100+variance)/100
			int lowerlimit = PhaseExpressionsArr[ExpressionIndex] as int*(100-variance)/100
			;avoid out of bounds
			if upperlimit > 100
					upperlimit = 100
			endif
			if lowerlimit < 0
					lowerlimit = 0
			endif
			if MFEEAddAhegao
				if ExpressionIndex != 1 ;&& MfgConsoleFunc.GetPhoneme(actorref, ExpressionIndex) != 0	
					PhaseExpressionsArr[ExpressionIndex] = 0  ;non big aah default to 0
				else
					PhaseExpressionsArr[ExpressionIndex] = ahegaophonemebigaah ; phoneme 1 big aah
				endif
			elseif IsSuckingoffOther() || HasDeviousGag(actorref)
				PhaseExpressionsArr[ExpressionIndex] = Blowjoboverride[ExpressionIndex]

			elseIf MFEEAddTongue
				if ExpressionIndex != 1 && ExpressionIndex != 11
					PhaseExpressionsArr[ExpressionIndex] = 0
				elseif ExpressionIndex == 1
					PhaseExpressionsArr[ExpressionIndex] = tonguephonemebigaah
				elseif ExpressionIndex == 11
					PhaseExpressionsArr[ExpressionIndex] = tonguephonemeoh
				endif
					; apply MFEE tongue out and down 
					if MuFacialExpressionExtended.GetExpressionValueByNumber(actorref,8,0) != 100 || MuFacialExpressionExtended.GetExpressionValueByNumber(actorref,2,0) != 100
						MuFacialExpressionExtended.SetExpressionByNumber(actorref,8,0,100) ;tongueout
						MuFacialExpressionExtended.SetExpressionByNumber(actorref,8,2,100) ;tongue down
					endif
			elseif EquippedTongue()
				PhaseExpressionsArr[ExpressionIndex] = TongueoutOverride[ExpressionIndex]
			elseif IsKissing()
				PhaseExpressionsArr[ExpressionIndex] = kisOverride[ExpressionIndex]

			elseif IsCunnilingus()
				PhaseExpressionsArr[ExpressionIndex] = cunOverride[ExpressionIndex]

			elseif !IsUnconcious()
				PhaseExpressionsArr[ExpressionIndex] = Utility.Randomint(lowerlimit, upperlimit)

			endif	

			ExpressionIndex = ExpressionIndex + 1
		endwhile
			ExpressionIndex = 0
	
	;----------------------------------------------Set MODIFIERS-----------------------------------------

		while ExpressionIndex <= 13 && !IsUnconcious() ;&& !MFEEAddAhegao
				;avoid out of bounds
			int modifier = PhaseExpressionsArr[ExpressionIndex + 16] as int 
			
			float modifierspeed 
			if expressionindex == 8  && expressionindex == 11
				modifierspeed = 0
			else
				modifierspeed = Speed
			endif
	
		;run modifiers
			if MFEEAddAhegao
				if ExpressionIndex != 11 ;&& MfgConsoleFunc.GetModifier(actorref, ExpressionIndex) != 0
					PhaseExpressionsArr[ExpressionIndex + 16] = 0 
				endif
				
				if MfgConsoleFunc.GetModifier(actorref, 11) != 50
					MfgConsoleFunc.SetModifier(actorref, 11, ahegaolookupmodifier) ;look up 50
				endif 
				
			elseif enableahegao == 1 && (IsBroken() || (ishugepp() && (IsGettingAnallyPenetrated() || IsGettingVaginallyPenetrated() )))
				PhaseExpressionsArr[ExpressionIndex + 16] = BrokenOverride[ExpressionIndex + 16] as int
				if MuFacialExpressionExtended.GetExpressionValueByNumber(actorref,0,0) != 100 && HasMFEEVanillaRace
				
					MuFacialExpressionExtended.SetExpressionByNumber(actorref,0,0,100) ;ahegao 1
					
				endif
				ExpressionIndex = ExpressionIndex + 1
			elseif IsCowgirl() && expressionindex == 8 ;look downwards if riding override
				PhaseExpressionsArr[24] = 100
				ExpressionIndex = 12	
				
			elseif (CurrentThread.HasSceneTag("Doggy") || CurrentThread.HasSceneTag("Doggystyle") || CurrentThread.HasSceneTag("Doggy Style")) && (IsGettingAnallyPenetrated() || IsGettingVaginallyPenetrated()) && expressionindex == 8
				PhaseExpressionsArr[lookdirection + 16] = 100
				ExpressionIndex = 12
			else
				ExpressionIndex = ExpressionIndex + 1
			endif
			
		endwhile
		MfgConsoleFuncExt.ApplyExpressionPresetSmooth(actorref, StringArrayToMFGNGArray(PhaseExpressionsArr), false)		
	endif
		
	if phase >= 5
		phase = 1
	else
		phase += 1
	endif	

	RegisterForSingleUpdate(GetExpressionUpdateSeconds())
	
EndEvent


;-------------------------------Hentairim Expressions Functions START---------------------------------
function RemoveExpressions()
	resetexpressions()
	RemoveTongue()
	Spell ExpressionsSpell = Game.GetFormFromFile(0x800, "HentairimExpressions.esp") as Spell	
	actorref.RemoveSpell(ExpressionsSpell)
EndFunction

string ExpressionGroup = "a"
String MasksFile  = "HentairimExpressions/Masks.json"
String ExpressionsFile = ""
string ConfigFile = "HentairimExpressions/Config.json"

String[] kisoverride
String[] cunoverride
String[] Blowjoboverride
String[] BrokenOverride
String[] TongueOutOverride
String[] Masks
String[] Maskslots
int lookdirection = 9

bool IsPlayer
bool Gender
actor playerref
int enabletongue
int fhutonguetype
int removetongueonblowjob
int cunusetongue
int enableahegao
int chancetostickouttongueduringintense
int chancetostickouttongueduringattacking
int enableprintdebug
Float pcnonintenseexpressionupdateinseconds
Float pcintenseexpressionupdateinseconds
Float npcnonintenseexpressionupdateinseconds
Float npcintenseexpressionupdateinseconds
	  
Function InitializeConfigandForms()
printdebug("------------------Initialize Hentai Expressions Configs and Forms Start-------------------------")
	playerref = game.getplayer()
	IsPlayer = actorref == playerref
	Gender = sexlab.GetGender(ActorRef)
	
	if IsPlayer
		ExpressionsFile = "HentairimExpressions/PCExpressions.json"
	elseif gender == 0	;Male
		ExpressionsFile = "HentairimExpressions/MaleExpressions.json"
	elseif gender == 1	;female
		ExpressionsFile ="HentairimExpressions/FemaleExpressions.json"	
	endif

	Blowjoboverride = papyrusutil.stringsplit(JsonUtil.GetStringValue(ExpressionsFile,"blowjobphonemeoverride","") ,",")
	BrokenOverride = papyrusutil.stringsplit(JsonUtil.GetStringValue(ExpressionsFile,"brokenmodifieroverride","") ,",")
	TongueOutOverride = papyrusutil.stringsplit(JsonUtil.GetStringValue(ExpressionsFile,"tongueoutphonemeoverride","") ,",")
	kisoverride = papyrusutil.stringsplit(JsonUtil.GetStringValue(ExpressionsFile,"kisphonemeoverride","") ,",")
	cunoverride = papyrusutil.stringsplit(JsonUtil.GetStringValue(ExpressionsFile,"cunphonemeoverride","") ,",")
	Masks = papyrusutil.stringsplit(JsonUtil.GetStringValue(MasksFile,"masks","") ,",")
	Maskslots = papyrusutil.stringsplit(JsonUtil.GetStringValue(MasksFile,"maskslots","") ,",")
	enabletongue =  JsonUtil.GetIntValue(ConfigFile, "enabletongue" ,0)
	fhutonguetype = JsonUtil.GetIntValue(ConfigFile, "fhutonguetype" ,0)
	removetongueonblowjob = JsonUtil.GetIntValue(ConfigFile, "removetongueonblowjob" ,0)
	cunusetongue = JsonUtil.GetIntValue(ConfigFile, "cunusetongue" ,0)
	enableahegao = JsonUtil.GetIntValue(ConfigFile, "enableahegao" ,0)
	chancetostickouttongueduringintense = JsonUtil.GetIntValue(ConfigFile, "chancetostickouttongueduringintense" ,0)
	chancetostickouttongueduringattacking = JsonUtil.GetIntValue(ConfigFile, "chancetostickouttongueduringattacking" ,0)
	enableprintdebug = JsonUtil.GetIntValue(ConfigFile, "printdebug" ,0)
	
	pcnonintenseexpressionupdateinseconds = JsonUtil.GetFloatValue(ConfigFile, "pcnonintenseexpressionupdateinseconds" ,3.0)
	pcintenseexpressionupdateinseconds = JsonUtil.GetFloatValue(ConfigFile, "pcintenseexpressionupdateinseconds" ,3.0)
	npcnonintenseexpressionupdateinseconds = JsonUtil.GetFloatValue(ConfigFile, "npcnonintenseexpressionupdateinseconds" ,3.0)
	npcintenseexpressionupdateinseconds = JsonUtil.GetFloatValue(ConfigFile, "npcintenseexpressionupdateinseconds" ,3.0)
	
	printdebug("enabletongue : " +enabletongue)
	printdebug("fhutonguetype : " +fhutonguetype)
	printdebug("removetongueonblowjob : " +removetongueonblowjob)
	printdebug("cunusetongue : " + cunusetongue)
	printdebug("enableahegao : "+enableahegao)
	printdebug("chancetostickouttongueduringintense : "+chancetostickouttongueduringintense)
	printdebug("chancetostickouttongueduringattacking : "+chancetostickouttongueduringattacking)
	printdebug("enableprintdebug : "+enableprintdebug)
	printdebug("pcnonintenseexpressionupdateinseconds : "+pcnonintenseexpressionupdateinseconds)
	printdebug("pcintenseexpressionupdateinseconds : "+pcintenseexpressionupdateinseconds)
	printdebug("npcnonintenseexpressionupdateinseconds : "+npcnonintenseexpressionupdateinseconds)
	printdebug("npcintenseexpressionupdateinseconds : "+npcintenseexpressionupdateinseconds)
	
	InitializeAddNPCTongue()
printdebug("------------------Initialize Hentai Expressions Configs and Forms END-------------------------")
endfunction

Function ResetHentaiExpressionGroup()
int type
	Type = Utility.Randomint(1,3)	
	if type == 1
		ExpressionGroup = "a"
	elseif type == 2
		ExpressionGroup = "b"
	elseif type == 3
		ExpressionGroup = "c"
	endif
	
	lookdirection = utility.Randomint(8,10)
endfunction

float function ExpressionSpeed()
	if Isintense()
		return 0.2
	else
		return 0.4
	endif
endfunction

string Function GetExpressionLabel()

if PenetrationLabel != "LDI"
	return PenetrationLabel
elseif PenisActionLabel != "LDI"
	return PenisActionLabel
elseif StimulationLabel != "LDI"
	return StimulationLabel
elseif EndingLabel != "LDI"
	return EndingLabel
else 
	return "LDI"
endif

endfunction

Bool Function EquippedTongue()

	return   actorref.IsEquipped(FHUTongueTypeArmor)
endfunction

Function AddTongue()

	printdebug("AddTongue: Starting. MFEEAddAhegao=" + MFEEAddAhegao + " WearingMask=" + (WearingMask(actorref) != none) + " IsSuckingoffOther=" + IsSuckingoffOther() + " EnableTongue=" + EnableTongue + " HasDeviousGag=" + HasDeviousGag(actorref) + " IsUnconcious=" + IsUnconcious() + " EquippedTongue=" + EquippedTongue())

	if MFEEAddAhegao || WearingMask(actorref) != none || IsSuckingoffOther() || EnableTongue != 1 || HasDeviousGag(actorref) || IsUnconcious() || EquippedTongue()
		printdebug("AddTongue: Conditions blocked tongue, exiting early.")
		return
	endif

	if HasMFEE && EnabledMFEETongue == 1
		printdebug("AddTongue: Using MFEE tongue expression.")
		MFEEAddTongue = true
	else
		if Game.GetModByName("sr_fillherup.esp") != 255
			printdebug("AddTongue: sr_fillherup.esp detected, equipping FHUTongueTypeArmor if available.")
			armor temptongue 
			
			if FHUTongueTypeArmor
				printdebug("AddTongue: Equipping FHUTongueTypeArmor=" + FHUTongueTypeArmor)
				actorref.AddItem(FHUTongueTypeArmor, abSilent = true)
				actorref.EquipItem(FHUTongueTypeArmor, abSilent = true)
			else
				printdebug("AddTongue: FHUTongueTypeArmor not defined, skipping equip.")
			endif
		else
			printdebug("AddTongue: sr_fillherup.esp not detected, skipping FHU tongue.")
		endif
	endif
EndFunction

Function RemoveTongue()

if !isplayer
return
endif
if HasMFEE && MFEEAddTongue 
	MFEEAddTongue = false
else
	if EquippedTongue()
	
		actorref.unEquipItem(FHUTongueTypeArmor, abSilent=true)
		actorref.removeItem(FHUTongueTypeArmor , abSilent=true)
	
	endif
endif
endfunction

Function unequipmask(actor char)
Armor Mask = wearingmask(char)
if Mask
	actorref.unEquipItem(Mask, abSilent=true)
endif

endfunction

Armor Function WearingMask(actor char)
if Maskslots.length == 0
	return none
endif

int slotlength = Maskslots.length
int slotindex = 0
int masklength = Masks.length
int maskindex = 0
Armor Mask
Armor WearingMask = none
string Maskname

	while slotindex < slotlength
		Mask = char.GetWornForm(Armor.GetMaskForSlot(Maskslots[slotindex] as int)) as armor
		Maskname = Mask.getname()
	
		while maskindex < masklength
			if stringutil.find(Maskname ,Masks[slotindex]) > -1
				WearingMask = Mask
				maskindex = 100
				slotindex = 100
			endif
			maskindex += 1
		endwhile

	slotindex += 1
	endwhile
	printdebug("Wearing Mask :" + WearingMask)
return WearingMask 
endfunction

Bool Function HasDeviousGag(Actor char)
	if has_MagicEffect(char, 0x2b077, "Devious Devices - Integration.esm")
	
			return true
		endif
endfunction

bool function has_MagicEffect(actor a, int id, string filename)
	MagicEffect ME = get_form(id, filename) as MagicEffect
	if !ME
		return false
	endif
	return a.HasMagicEffect(ME)
endfunction


Bool Function IsUnconcious()
	if (CurrentThread.HasSceneTag("faint") || CurrentThread.HasSceneTag("sleep") || CurrentThread.HasSceneTag("necro")) && position == 0
		Return true
	else
		return false
	endif
endfunction


String Function GetPrimaryLabel()
	IF OralLabel != "LDI"
		return OralLabel
	elseif Stimulationlabel == "BST"
		return Stimulationlabel
	elseif PenetrationLabel != "LDI"
		return PenetrationLabel
	elseif PenisActionLabel != "LDI"
		return PenisActionLabel
	else
		return Stimulationlabel
	endif
endfunction

int function  GetFullEnjoyment()
	CurrentThread.GetEnjoyment(actorref)
	printdebug("Enjoyment : " + CurrentThread.GetEnjoyment(actorref))
endfunction

bool IsOrgasming

String Function GetHentaiExpression()

string 	HentaiScenario = StorageUtil.GetStringValue(None, "HentaiScenario", "")
if !isplayer || (isplayer && HentaiScenario == "")
	if IsOrgasming
		HentaiScenario = "orgasm"
	elseif (IsGivingAnalPenetration() || IsGivingVaginalPenetration()  || IsGettingSuckedoff()) && !Isintense()
		HentaiScenario = "grunt"
	elseif (IsGivingAnalPenetration() || IsGivingVaginalPenetration() || IsGettingSuckedoff()) && Isintense()
		HentaiScenario = "intensegrunt"
	elseif GetFullEnjoyment() > 70 && !Isintense() && gender == 0
		HentaiScenario = "closetoorgasm"
	elseif GetFullEnjoyment() > 70 && Isintense() && gender == 0
		HentaiScenario = "closetoorgasmintense"
	elseif (IsCowgirl() || IsGivingAnalPenetration() || IsGivingVaginalPenetration() ) && !IsVictim
		HentaiScenario = "attacking"
	elseif IsGettingStimulated()
		if Isintense()
			HentaiScenario = "grunt"
		else
			HentaiScenario = "Leadin"
		endif
	elseif IsEnding()
		if IsVictim
			HentaiScenario = "unamusedending"
		else
			HentaiScenario = "Panting"
		endif
	else
		if Isintense()
			HentaiScenario = "intensegrunt"
		else
			HentaiScenario = "grunt"
		endif
	Endif
endif

return HentaiScenario

EndFunction

function resetexpressions()

MfgConsoleFuncExt.resetmfg(actorref) 
if hasmfee || HasMFEEVanillaRace
	MuFacialExpressionExtended.RevertExpression(actorref)
endif

endfunction


Bool HasMFEE = false
Bool HasMFEEVanillaRace = false
int  EnabledMFEETongue = 0
int EnabledMFEEAhegao = 0
bool MFEEAddTongue = false
bool MFEEAddAhegao = false
int ahegaophonemebigaah
int tonguephonemebigaah
int tonguephonemeoh
int ahegaolookupmodifier
String EnableErinMFEE  = "HentairimExpressions/ErinMFEEConfig.json"

Function CheckHasMFEE()
	;check if has MFEE
	if MuFacialExpressionExtended.GetVersion() > 0   &&  (actorref.GetRace().getname() =="Erin" || actorref.GetRace().getname() =="Elin" )
		HasMFEE = true
		EnabledMFEETongue = JsonUtil.GetIntValue(EnableErinMFEE,"enablemfeetongue",0)  
		EnabledMFEEAhegao = JsonUtil.GetIntValue(EnableErinMFEE,"enablemfeeahegao",0)
		ahegaophonemebigaah = JsonUtil.GetIntValue(EnableErinMFEE,"ahegaophonemebigaah",0)
		tonguephonemebigaah = JsonUtil.GetIntValue(EnableErinMFEE,"tonguephonemebigaah",0)
		tonguephonemeoh	 = JsonUtil.GetIntValue(EnableErinMFEE,"tonguephonemeoh",0)	
		ahegaolookupmodifier = JsonUtil.GetIntValue(EnableErinMFEE,"ahegaolookupmodifier",0)
    elseif MuFacialExpressionExtended.GetVersion() > 0
		HasMFEEVanillaRace = true
	endif
endfunction


Float function GetSecondsSinceLastOrgasm()

return CurrentThread.Gettimetotal() - LastOrgasmtime 

endfunction

float function GetExpressionUpdateSeconds()
if IsPlayer
	if Isintense()
		return pcintenseexpressionupdateinseconds
	else
		return pcnonintenseexpressionupdateinseconds
	endif
else
	if Isintense()
		return npcintenseexpressionupdateinseconds
	else
		return npcnonintenseexpressionupdateinseconds
	endif	
endif

EndFunction

Bool function isDependencyReady(String modname)
  int index = Game.GetModByName(modname)
  if index == 255 || index == -1
    return false
  else
    return true
  endif
endfunction

Float[] function StringArrayToMFGNGArray(String[] values)
  float[] result = new float[32]
  if values.length < 32
    printdebug("Expressions array only has " + values.length + "items. it is either incorrectly formatted or missing in the json file")
  endif
  Int i = 0
  while i < 32
    if i == 30 && values[i]
      result[i] = values[i] as float
    elseif values[i]
      result[i] = (values[i] as float) / 100
    else
      result[i] = 0
    endif
    i = i + 1
  endwhile
  return result
endfunction

string NPCTongueFile  = "HentairimExpressions/NPCTongue.json"
int enablenpctongue = 0

Function InitializeAddNPCTongue()
printdebug("enablenpctongue : " + enablenpctongue)
enablenpctongue = JsonUtil.GetIntValue(NPCTongueFile, "enablenpctongue", 0)

FHUTongueTypeArmor =  GetTongueType()
endfunction 

armor FHUTongueTypeArmor

Armor function GetTongueType()

	if FHUTongueType == 0
		FHUTongueType = Utility.RandomInt(1, 10)
	endif	
	string name = actorref.getdisplayname()
	int TongueType
	armor Tongue
	if isplayer
		TongueType = FHUTongueType
	elseif enablenpctongue == 1
		TongueType = JsonUtil.GetIntValue(NPCTongueFile, name, 99)
	endif
	
	if TongueType == 1
	Tongue = Game.GetFormFromFile(0x263B2, "sr_fillherup.esp") as Armor
elseif  TongueType == 2
	Tongue = Game.GetFormFromFile(0x263B3, "sr_fillherup.esp") as Armor
elseif  TongueType == 3
	Tongue = Game.GetFormFromFile(0x263B4, "sr_fillherup.esp") as Armor
elseif  TongueType == 4
	Tongue = Game.GetFormFromFile(0x263B5, "sr_fillherup.esp") as Armor
elseif  TongueType == 5
	Tongue = Game.GetFormFromFile(0x263B6, "sr_fillherup.esp") as Armor	
elseif  TongueType == 6
	Tongue = Game.GetFormFromFile(0x263B7, "sr_fillherup.esp") as Armor	
elseif  TongueType == 7
	Tongue = Game.GetFormFromFile(0x263B8, "sr_fillherup.esp") as Armor	
elseif  TongueType == 8
	Tongue = Game.GetFormFromFile(0x263B9, "sr_fillherup.esp") as Armor	
elseif  TongueType == 9
	Tongue = Game.GetFormFromFile(0x263BA, "sr_fillherup.esp") as Armor	
elseif  TongueType == 10
	Tongue = Game.GetFormFromFile(0x263BB, "sr_fillherup.esp") as Armor	
endif

FHUTongueTypeArmor = Tongue
return Tongue
endfunction


;-------------------------------Hentairim Expressions Functions END---------------------------------

;-----------------------BASE HENTAIRIM Update Functions-----------------------------

Bool IsHugePP
string CurrentSceneID = ""
string currentStageID = ""
Int currentStage = -1
Int ThreadID = -1
Faction HentairimBroken
bool IsVictim
float DirectorLastLabelTime

Function HentairimPrepare()
	printdebug("--------------------Hentairim Prepare Initial Data START-----------------")
	HentairimBroken = Game.GetFormFromFile(0x802, "HentairimResistance.esp") as Faction
	ThreadID = CurrentThread.GetThreadID()
	IsHugePP = IsHugePP()
	HentairimUpdateStageData()
	IsVictim = IsVictim(Actorref)
	
	printdebug("ThreadID : " + ThreadID)
	printdebug("Partner IsHugePP : " + IsHugePP)

	printdebug("--------------------Hentairim Prepare Initial Data END-----------------")
endfunction



Function HentairimUpdateStageData()
	printdebug("Updating Labels")

	printdebug("DirectorLastLabelTimeCheck: local=" + DirectorLastLabelTime + " master=" + MasterScript.GetDirectorLastLabelTime())
	if DirectorLastLabelTime != MasterScript.GetDirectorLastLabelTime()	
		printdebug("Animation or Stage is Different. Updating Stage Data")
		CurrentSceneID = CurrentThread.GetActiveScene()
		currentStageID = CurrentThread.GetActiveStage()
		currentstage = GetLegacyStageNum(CurrentSceneID, currentStageID)
		
		UpdateLabels(actorref)	

		printdebug("PC Thread Position : " + CurrentThread.GetPositionIdx(Actorref))
		printdebug("current Animation : " + CurrentSceneID)
		printdebug("current StageID : " + currentStageID)
		printdebug("current stage number: " + currentstage)
		

		int rand = Utility.RandomInt(1,100)
		printdebug("TongueCheck: rand=" + rand + " enableahegao=" + enableahegao + " cunusetongue=" + cunusetongue + " chancetostickouttongueduringintense=" + chancetostickouttongueduringintense + " chancetostickouttongueduringattacking=" + chancetostickouttongueduringattacking + " IsBroken=" + IsBroken() + " IsCunnilingus=" + IsCunnilingus() + " IsIntense=" + IsIntense() + " IsgettingPenetrated=" + IsgettingPenetrated() + " IsCowgirl=" + IsCowgirl() + " IsGivingAnalPenetration=" + IsGivingAnalPenetration() + " IsGivingVaginalPenetration=" + IsGivingVaginalPenetration() + " IsVictim=" + IsVictim)
		if !EquippedTongue() &&(IsBroken() && enableahegao == 1) || (IsCunnilingus() && cunusetongue == 1) || (IsIntense() && IsGettingPenetrated() && rand <= chancetostickouttongueduringintense) || ((IsCowgirl() || IsGivingAnalPenetration() || IsGivingVaginalPenetration()) && !IsVictim && rand <= chancetostickouttongueduringattacking)
			printdebug("Adding Tongue")
			AddTongue()
		endif

		;remove mask if giving BJ
		if IsSuckingoffOther()
			unequipmask(actorref)
		endif
		DirectorLastLabelTime = MasterScript.GetDirectorLastLabelTime()
	endif

endfunction

String Stimulationlabel
String PenisActionLabel
string OralLabel
string EndingLabel
string PenetrationLabel
string Labelsconcat
;sexLabThreadController.ActorAlias(actorInQuestion).GetFullEnjoyment()

Function UpdateLabels(actor char)
 	printdebug("--------------------Hentairim Updating Labels START-----------------")
	
 Stimulationlabel = MasterScript.GetStimulationlabel(char)
 PenisActionLabel  = MasterScript.GetPenisActionLabel(char)
 OralLabel  = MasterScript.GetOralLabel(char)
 EndingLabel  = MasterScript.GetEndingLabel(char)
 PenetrationLabel = MasterScript.GetPenetrationLabel(char)
 
 Labelsconcat = "1" +Stimulationlabel + "1" + PenisActionLabel + "1" + OralLabel + "1" + PenetrationLabel + "1" + EndingLabel
 PrintDebug("Stimulationlabel :" + Stimulationlabel + ", PenisActionLabel :" +  PenisActionLabel  + ", OralLabel :" +  OralLabel  + ", PenetrationLabel :" +  PenetrationLabel  + ", EndingLabel :" +  EndingLabel)

printdebug("--------------------Hentairim Updating Labels END-----------------")
endfunction
;-----------------------BASE HENTAIRIM Update Functions END-----------------------------


;-----------------------Hentairim Common Utilities START--------------------------------------

Bool Function Isintense()
	return stringutil.find(Labelsconcat ,"1F") > -1 || stringutil.find(Labelsconcat ,"BST") > -1
endfunction

Bool Function IsGettingStimulated()
	return Stimulationlabel == "SST" ||  Stimulationlabel == "FST"
endfunction

Bool Function IsSuckingoffOther()
	return OralLabel == "SBJ" ||  OralLabel == "FBJ" 
endfunction

Bool Function IsGettingDoublePenetrated()

return PenetrationLabel == "SDP" || PenetrationLabel == "FDP" 
endfunction

Bool Function IsgettingPenetrated()
	return IsGettingAnallyPenetrated() || IsGettingVaginallyPenetrated()
endfunction

Bool Function IsGettingVaginallyPenetrated()
	return PenetrationLabel == "SVP" || PenetrationLabel == "FVP" || PenetrationLabel == "SCG" || PenetrationLabel == "FCG" || PenetrationLabel == "SDP" || PenetrationLabel == "FDP"
endfunction

Bool Function IsGettingAnallyPenetrated() 
	return PenetrationLabel == "SAP" || PenetrationLabel == "FAP"  || PenetrationLabel == "SAC" || PenetrationLabel == "FAC" || PenetrationLabel == "SDP" || PenetrationLabel == "FDP"
endfunction

Bool Function IsKissing()
	return OralLabel == "KIS"
endfunction

Bool Function IsCunnilingus()
	return OralLabel == "CUN"
endfunction

Bool Function IsGivingAnalPenetration()
	return PenisActionLabel == "FDA" || PenisActionLabel == "SDA"
endfunction

Bool Function IsGivingVaginalPenetration()
	return PenisActionLabel =="FDV" || PenisActionLabel == "SDV"
endfunction

Bool Function IsLeadIN()
	return Stimulationlabel == "LDI" && PenisActionlabel == "LDI" && Penetrationlabel == "LDI" && OralLabel == "LDI" && EndingLabel == "LDI" 
endfunction 

Bool Function IsGettingSuckedoff()
	return PenisActionLabel == "SMF" ||  PenisActionLabel == "FMF"	 
endfunction

Bool Function IsCowgirl()
	return PenetrationLabel == "SCG" ||  PenetrationLabel == "FCG" ||  PenetrationLabel == "SAC" ||  PenetrationLabel == "FAC"			
endfunction

Bool Function IsEnding()
	return EndingLabel == "ENI" || EndingLabel == "ENO"
endfunction


Bool function IshugePP()
	if position != 0
		return false
	endif
	return masterscript.ishugepp(actorref)
;/
	;no Huge PP effects if not receiving in position 0
	if position != 0
		return false
	endif
	;SOS
	faction SchlongFaction = Game.GetFormFromFile(0xAFF8 , "Schlongs of Skyrim.esp") as Faction
	;TNG
	keyword TNG_XL
	keyword TNG_L
	keyword TNG_Gentlewoman
	String ControlConfigFile  = "HentairimDirector/Config.json"
	 int HugePPSchlongSize = JsonUtil.GetIntValue(ControlConfigFile, "soshugeppsize" ,6)
    if !TNG_Gentlewoman && isDependencyReady("TheNewGentleman.esp")
      TNG_XL = Game.GetFormFromFile(0xFE5, "TheNewGentleman.esp") as Keyword
      TNG_L = Game.GetFormFromFile(0xFE4, "TheNewGentleman.esp") as Keyword
      TNG_Gentlewoman = Game.GetFormFromFile(0xFF8, "TheNewGentleman.esp") as Keyword
    endif

  String MaleRaceName = actorList[1].GetRace().getName()
  if stringutil.find(MaleRaceName, "Brute") > -1 || stringutil.find(MaleRaceName, "Spider") > -1 || stringutil.find(MaleRaceName, "Lurker") > -1 || stringutil.find(MaleRaceName, "Daedroth") > -1 || stringutil.find(MaleRaceName, "Horse") > -1 || stringutil.find(MaleRaceName, "Bear") > -1 || stringutil.find(MaleRaceName, "Chaurus") > -1 || stringutil.find(MaleRaceName, "Dragon") > -1 || MaleRaceName == "Frost Atronach" || stringutil.find(MaleRaceName, "Giant") > -1 || MaleRaceName == "Mammoth" || MaleRaceName == "Sabre Cat" || stringutil.find(MaleRaceName, "Troll") > -1 || MaleRaceName == "Werewolf" || stringutil.find(MaleRaceName, "Gargoyle") > -1 || MaleRaceName == "Dwarven Centurion" || stringutil.find(MaleRaceName, "Ogre") > -1 || MaleRaceName == "Ogrim" || MaleRaceName == "Nest Ant Flier" || stringutil.find(MaleRaceName, "OGrim") > -1
    return True
  else
    ;if Schlong is big
    if (SchlongFaction)
      return actorList[1].GetFactionRank(SchlongFaction) >= HugePPSchlongSize
    elseif (TNG_XL)
      ;keywords can explicitly overwrite value
      int TNG_Size = TNG_PapyrusUtil.GetActorSize(actorList[1])
      bool tngxl = actorList[1].HasKeyword(TNG_XL)
      bool tngl = actorList[1].HasKeyword(TNG_L)
      bool isBig = tngxl || TNG_Size >= HugePPSchlongSize || tngl

      return isBig
    endif
    return false
  endif
  /;
EndFunction


int Function GetLegacyStageNum(String asScene, String asStage)
	string[] all_stages = SexlabRegistry.GetAllStages(asScene)
	if SexlabRegistry.StageExists(asScene, asStage)
		int stage_num = all_stages.find(asStage)+1
		return stage_num
	endif
	return 0
EndFunction

int Function GetLegacyStagesCount(String asScene)
	int stages_count = SexlabRegistry.GetAllStages(asScene).Length
	return stages_count
EndFunction

float Function GetAnimationSpeed()
return AnimSpeedHelper.GetAnimationSpeed(game.getplayer() , true)

endFunction

Function PlaySound(Sound theSound, Actor actorMakingSound, Bool waitForCompletion = True)

	If waitForCompletion
		theSound.PlayAndWait(actorMakingSound)
	Else
		theSound.Play(actorMakingSound)
	EndIf
EndFunction

Bool Function IsVictim(actor char)
  CurrentThread.GetSubmissive(char)
endFunction

Bool Function IsBroken()
	return actorref.GetFactionRank(HentairimBroken) > 0
endfunction

bool function has_spell(actor a, int id, string filename)
	spell sp = get_form(id, filename) as spell
	if !sp
		return false
	endif
	return a.HasSpell(sp)
endfunction

form function get_form(int id, string filename)
	if Game.GetModbyName(filename) == 255 
		return None
	endif
	return Game.GetFormFromFile(id, filename)
endfunction


Function PrintDebug(string Contents = "")
if enableprintdebug == 1
	miscutil.printconsole(actorref.getdisplayname() + " HentaiRim Expressions " + Contents)
endif
endfunction 


Int Function FindInt(Int[] arr, Int target)
    Int i = 0
    While i < arr.Length
        If arr[i] == target
            Return i ; Found, return index
        EndIf
        i += 1
    EndWhile
    Return -1 ; Not found
EndFunction
;-----------------------Hentairim Common Utilities END--------------------------------------
function WritetoErrorlogs(string Header = "Not Specified" ,String contents = "")
	JsonUtil.StringListAdd("ErrorLog.json", Header, " : " + contents, TRUE)
endfunction
