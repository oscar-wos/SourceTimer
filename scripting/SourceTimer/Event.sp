Action Event_RoundStart(Event eEvent, char[] cName, bool bDontBroadcast) {
	Zone_Reload();
}

Action Event_PlayerSpawn(Event eEvent, char[] cName, bool bDontBroadcast) {
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidEntity(iClient)) return;
	
	SetEntProp(iClient, Prop_Data, "m_CollisionGroup", 2);
	Zone_TeleportToStart(iClient);
}