Scriptname IVDTMCMConfigurationScript extends MCM_ConfigBase  
{This script has all the code to make the MCM menu work.}

IVDTControllerScript Property MasterScript Auto

;The below two properties control how many male and female voice slots there are. When changing these numbers, you also need to update them:
;1. In "/Data/MCM/Config/IntelligentVoicedDirtyTalk/settings.ini" (they need to have default values)
;2. In "/Data/MCM/Config/IntelligentVoicedDirtyTalk/config.json" (the default voice slot sliders need to have their max values changed)
;3. The two string arrays in the function RefreshAllOptionsForVoiceSlotEnum in this file need to have their sizes increased (see the comment on them for details)
;4. There needs to be a reference alias on the IVDTMainQuest that has the female/male voice script added to it with its properties set specifically for the new voice slot (see how previous voice slots did theirs)...
;...it will require creating your own sound descriptor and sound marker objects.
;5. !!!IMPORTANT!!!: The new voice slot will only work on a new save--or an existing save after you have disabled the mod, saved, and then re-enabled on that new save. This is needed to refresh the quest data...
Int Property FemaleVoiceSlots Auto
Int Property MaleVoiceSlots Auto

;Currently selected voice slot
Int Property pVoiceSlotUnderInspection = 0 Auto Hidden
Bool Property pValidVoiceSlotSelected = False Auto Hidden
Bool voiceSlotIsMale = False
Int voiceSlotNumber = 1
String voiceSlotVoiceType = "Empty"

;Voice type editing options
String Property pVoiceTypeFromList = "Click Here" Auto Hidden

;Actor options
Actor Property TargetActor Auto Hidden
sslSystemConfig Property sexLabConfig Auto


Event OnConfigOpen()
	pVoiceSlotUnderInspection = 0
	pValidVoiceSlotSelected = False
	
	UpdateTargetActor("")
EndEvent

Event OnPageSelect(string a_page)
	If a_page == "Assign Voice"
		RefreshAllOptionsForVoiceSlotEnum()
		UpdateTargetActorOptions(True)
	EndIf
EndEvent

Event OnSettingChange(string a_ID)
	If a_ID == "VoiceSlotEnum"
		RefreshVoicesPageBasedOnCurrentSlot()
		
	ElseIf a_ID == "sVoiceTypeManualEntry:DoNotTouch"
		UpdateCurrentSlotWithNewVoiceType(GetModSettingString("sVoiceTypeManualEntry:DoNotTouch"))
		SetModSettingString("sVoiceTypeManualEntry:DoNotTouch", "Type Here")
		
	ElseIf a_ID == "PresetVoiceTypesMenu"
		If pVoiceTypeFromList != "Click Here"
			UpdateCurrentSlotWithNewVoiceType(pVoiceTypeFromList)
			pVoiceTypeFromList = "Click Here"
			RefreshMenu()
		EndIf
		
	ElseIf a_ID == "sActorManualEntry:DoNotTouch"
		UpdateAssignedActorName(False, GetModSettingString("sActorManualEntry:DoNotTouch"))
	
	ElseIf a_ID == "iMasterVolume:VoiceSystemManagement"
		MasterScript.UpdateMasterVolume()
		
	EndIf
EndEvent

;This refreshes the options presented in the voice slot dropdown (aka enum)
Function RefreshAllOptionsForVoiceSlotEnum()
	string[] newVoiceSlots = new string[11] ;Size must be set at compile time. Increase this manually if needed. Should be = FemaleVoiceSlots + MaleVoiceSlots + 1
	string[] newShortNames = new string[11] ;Should be same size as above
	
	Int curVoiceSlotIndex = 0
	Int curVoiceSlotNumber = 1
	String slotName = ""
	String temp = ""
	Bool slotIsEmpty = True
	While curVoiceSlotIndex < newVoiceSlots.Length
	
		If curVoiceSlotIndex == 0 ;Default empty slot
			newShortNames[curVoiceSlotIndex] = "Select A Slot"
			newVoiceSlots[curVoiceSlotIndex] = "Select A Slot"
			
		ElseIf curVoiceSlotIndex <= FemaleVoiceSlots ;Female voice slot
			curVoiceSlotNumber = curVoiceSlotIndex
			
			slotName = "Female " + curVoiceSlotNumber
			newShortNames[curVoiceSlotIndex] = slotName
			
			temp = GetModSettingString("sFemale" + curVoiceSlotNumber + "VoiceType:FemaleVoices")
			If temp != "" && temp != "Empty"
				slotIsEmpty = False
				slotName += " - " + temp
			EndIf
			
			temp = GetModSettingString("sFemale" + curVoiceSlotNumber + "Actor:FemaleVoices")
			If temp != "" && temp != "Empty"
				slotIsEmpty = False
				slotName += " - " + temp
			EndIf
			
			If slotIsEmpty
				slotName += " - Empty"
			EndIf
			
			newVoiceSlots[curVoiceSlotIndex] = slotName
			
		ElseIf curVoiceSlotIndex <= FemaleVoiceSlots + MaleVoiceSlots ;Male voice slot
			curVoiceSlotNumber = curVoiceSlotIndex - FemaleVoiceSlots
			
			slotName = "Male " + curVoiceSlotNumber
			newShortNames[curVoiceSlotIndex] = slotName
			
			temp = GetModSettingString("sMale" + curVoiceSlotNumber + "VoiceType:MaleVoices")
			If temp != "" && temp != "Empty"
				slotIsEmpty = False
				slotName += " - " + temp
			EndIf
			
			temp = GetModSettingString("sMale" + curVoiceSlotNumber + "Actor:MaleVoices")
			If temp != "" && temp != "Empty"
				slotIsEmpty = False
				slotName += " - " + temp
			EndIf
			
			If slotIsEmpty
				slotName += " - Empty"
			EndIf
			
			newVoiceSlots[curVoiceSlotIndex] = slotName
			
		Else ;Invalid voice slot
			newShortNames[curVoiceSlotIndex] = "Invalid Slot"
			newVoiceSlots[curVoiceSlotIndex] = "Invalid Slot, Please Get Mechanic To Fix"
			
		EndIf
	
		curVoiceSlotIndex += 1
		slotIsEmpty = True
	EndWhile
	
	SetMenuOptions("VoiceSlotEnum", newVoiceSlots, newShortNames)
EndFunction

;This refreshes all the data and display below the voice slot dropdown based on what option is currently selected in that dropdown (represented in pVoiceSlotUnderInspection)
Function RefreshVoicesPageBasedOnCurrentSlot()
	pValidVoiceSlotSelected = (pVoiceSlotUnderInspection != 0)

	If pVoiceSlotUnderInspection == 0
		voiceSlotIsMale = False
		voiceSlotNumber = 1
		voiceSlotVoiceType = "Empty"
	Else
		voiceSlotIsMale = pVoiceSlotUnderInspection > FemaleVoiceSlots
		
		If voiceSlotIsMale
			voiceSlotNumber = pVoiceSlotUnderInspection - FemaleVoiceSlots
			voiceSlotVoiceType = GetModSettingString("sMale" + voiceSlotNumber + "VoiceType:MaleVoices")
		Else
			voiceSlotNumber = pVoiceSlotUnderInspection
			voiceSlotVoiceType = GetModSettingString("sFemale" + voiceSlotNumber + "VoiceType:FemaleVoices")
		EndIf
	EndIf
	
	SetModSettingString("sVoiceTypeUnderInspection:DoNotTouch", voiceSlotVoiceType)
	UpdateAssignedActorName(True, "")
	
	RefreshMenu()
	; Debug.MessageBox("Male: " + voiceSlotIsMale + "\nNumber: " + voiceSlotNumber + "\nVoiceType: '" + voiceSlotVoiceType + "'")
EndFunction

;This updates the actor name that is shown on the 'Currently Set To' field.
;If in fetch mode, it simply grabs that currently saved value. Else, it will save a new value for that field.
;The new value is either what is passed in, or if you pass in an empty string, it is the current target.
Function UpdateAssignedActorName(Bool fetchMode, string newActorName)
	string settingToSearch
	
	If voiceSlotIsMale
		settingToSearch = "sMale" + voiceSlotNumber + "Actor:MaleVoices"
	Else
		settingToSearch = "sFemale" + voiceSlotNumber + "Actor:FemaleVoices"
	EndIf
	
	If fetchMode
		newActorName = GetModSettingString(settingToSearch)
		SetModSettingString("sActorUnderInspection:DoNotTouch", newActorName)
		RefreshMenu()
	Else
		If newActorName == ""
			newActorName = GetModSettingString("sTargetActor:DoNotTouch")
		Else
			SetModSettingString("sActorManualEntry:DoNotTouch", "Type Here")
		EndIf
		
		SetModSettingString(settingToSearch, newActorName)
		FullVoicePageRefresh()
	EndIf
	
	
EndFunction

Function UpdateCurrentSlotWithNewVoiceType(string newVoiceType)
	If voiceSlotIsMale
		SetModSettingString("sMale" + voiceSlotNumber + "VoiceType:MaleVoices", newVoiceType)
	Else
		SetModSettingString("sFemale" + voiceSlotNumber + "VoiceType:FemaleVoices", newVoiceType)
	EndIf
	
	FullVoicePageRefresh()
EndFunction

Function FullVoicePageRefresh()
	RefreshAllOptionsForVoiceSlotEnum()
	RefreshVoicesPageBasedOnCurrentSlot()
EndFunction

Function UpdateTargetActor(String currentTargetActorName)
	;First of all, grab the target actor if applicable
	targetActor = sexLabConfig.TargetRef
	
	If !IsValidActor(targetActor)
		targetActor = Game.GetPlayer()
	EndIf
	
	string targetActorName = targetActor.GetLeveledActorBase().GetName()
	
	If targetActorName == "" || targetActorName == currentTargetActorName
		targetActor = Game.GetPlayer()
		targetActorName = targetActor.GetLeveledActorBase().GetName()
	EndIf
	
	SetModSettingString("sTargetActor:DoNotTouch", targetActorName)
	
	;If this is called from clicking the button to switch target actors, then we need to update the actor information
	If currentTargetActorName != ""
		UpdateTargetActorOptions(False)
	EndIf
	
	RefreshMenu()
EndFunction

Bool Function IsValidActor(Actor actorToValidate)
	If actorToValidate == None
		Return False
	ElseIf actorToValidate.IsChild() || actorToValidate.IsDead()
		Return False
	Else
		Return True
	EndIf
EndFunction

Function UpdateTargetActorOptions(Bool forcePageUpdate)
	
	UpdateUseActorVoiceTypeOption()
	
	If forcePageUpdate
		RefreshMenu()
	EndIf
EndFunction

Function UpdateUseActorVoiceTypeOption()
	String targetVoiceTypeName = "Empty"

	If TargetActor != None
		targetVoiceTypeName = MasterScript.GetNameOfVoiceType(TargetActor)
	EndIf
	
	SetModSettingString("sTargetVoiceType:DoNotTouch", targetVoiceTypeName)
EndFunction

Function PlaySampleFromVoiceSlot()
	If voiceSlotIsMale
		IVDTVoiceMaleScript maleVoiceToSample = MasterScript.GetMaleVoiceAtSlot(voiceSlotNumber)
		If maleVoiceToSample != None
			maleVoiceToSample.MCMSampleSounds.Play(Game.GetPlayer())
		EndIf
	Else
		IVDTVoiceFemaleScript femaleVoiceToSample = MasterScript.GetFemaleVoiceAtSlot(voiceSlotNumber)
		If femaleVoiceToSample != None
			femaleVoiceToSample.MCMSampleSounds.Play(Game.GetPlayer())
		EndIf
	EndIf
EndFunction

Function UnmuteSexLabVoicesFromMCM()
	MasterScript.UnmuteSexLabVoices()
	Debug.MessageBox("SexLab voices unmuted.")
EndFunction