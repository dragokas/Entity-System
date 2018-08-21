#if defined _entity_system_included
  #endinput
#endif
#define _entity_system_included

stock const char g_sAdminMenuCategory[] = "entity_system";
stock const char g_sPosKeyKV[] = "pos";
stock const char g_sAnglesKeyKV[] = "angles";

stock void TelepotEntityToClient(int client, int entity)
{
	float fPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", fPos); 

	TeleportEntity(entity, fPos, NULL_VECTOR, NULL_VECTOR);
}

// Natives

native bool 	Entity_IsWorking();

native void 	Entity_RegisterType(const char[] name);
native void 	Entity_UnRegisterType(const char[] name);

native int 	Entity_GetClientEditEntity(int client);
native void 	Entity_SetClientEditEntity(int client, int entity);

native void 	Entity_GetClientEditClassName(int client, char[] class);

native bool 	Entity_EditMenuAccess(int client, bool acces);
native void 	Entity_TeleportToEditEntity(int client);
native int 	Entity_GetAdminMenuHandle();

//Forwards