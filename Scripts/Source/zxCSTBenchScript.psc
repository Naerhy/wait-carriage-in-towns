Scriptname zxCSTBenchScript extends ObjectReference  

Message Property zxCSTMessageMain Auto
Message[] Property MessageMainButtons Auto

ObjectReference[] Property CitiesDestinations Auto
ObjectReference[] Property TownsDestinations Auto
ObjectReference[] Property VillagesDestinations Auto

Actor Property PlayerRef Auto
GlobalVariable Property CarriageCost Auto
GlobalVariable Property CarriageCostSmall Auto
GlobalVariable Property GameHour Auto
MiscObject Property Gold001  Auto  

ImageSpaceModifier Property FadeToBlackImod  Auto
ImageSpaceModifier Property FadeToBlackHoldImod  Auto
ImageSpaceModifier Property FadeToBlackBackImod  Auto

bool isInMenu

Function openMessage()
    isInMenu = true
    while isInMenu
        int mainButtonSelected = zxCSTMessageMain.show()
        if mainButtonSelected != 3
            int destinationSelected = MessageMainButtons[mainButtonSelected].show()
            if mainButtonSelected == 0 && destinationSelected != 5
                waitCarriage(CitiesDestinations[destinationSelected], "city")
            elseIf mainButtonSelected == 1 && destinationSelected != 4
                waitCarriage(TownsDestinations[destinationSelected], "town")
            elseIf mainButtonSelected == 2 && destinationSelected != 6
                waitCarriage(VillagesDestinations[destinationSelected], "village")
            endIf
        else
            isInMenu = false
        endIf
    endWhile
endFunction

Function waitCarriage(ObjectReference destination, string destType)
    isInMenu = false
    int journeyCost = getJourneyCost(destType)
    if PlayerRef.GetItemCount(Gold001) >= journeyCost
        ObjectReference sitMarker = GetLinkedRef()
        sitMarker.Enable()
        Game.DisablePlayerControls(true, true, true, true, true, true, true, true)
        sitMarker.Activate(PlayerRef)
        Utility.Wait(0.5)
        FadeToBlackImod.Apply()
        Utility.Wait(2.5)
        FadeToBlackImod.PopTo(FadeToBlackHoldImod)
        GameHour.Mod(Utility.RandomInt(1, 2))
        Utility.Wait(1.0)
        Game.FastTravel(destination)
        sitMarker.Disable()
        PlayerRef.RemoveItem(Gold001, journeyCost)
        Game.EnablePlayerControls()
        FadeToBlackHoldImod.PopTo(FadeToBlackBackImod)
        FadeToBlackHoldImod.Remove()     ; If ImageSpaceModifier doesn't get automatically removed
    else 
        Debug.MessageBox("You won't have enough septims to pay the driver for the travel!")
    endIf
endFunction

int Function getJourneyCost(string destType)
    if destType == "city"
        return CarriageCost.GetValue() as int
    else
        return CarriageCostSmall.GetValue() as int
    endIf
endFunction

Event OnActivate(ObjectReference akActionRef)
    if akActionRef == PlayerRef
        if !PlayerRef.IsOverEncumbered()
            openMessage()
        else
            Debug.Notification("You cannot wait for a carriage while overencumbered.")
        endIf
    endIf
endEvent