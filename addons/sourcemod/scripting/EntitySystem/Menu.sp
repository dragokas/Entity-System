stock void CreateEditMenu(int client)
{
	if(g_eEntity[client].edit == Edit_None || !g_eEntity[client].id || !IsValidEntity(g_eEntity[client].id)) return;

	Menu menu = new Menu(Edit_);
	menu.ExitBackButton = true;
	menu.ExitButton = false;

	menu.SetTitle("Редактируем: %d [%s]\n%s", g_eEntity[client].id, g_eEntity[client].sName, CreateTitleEditMenu(client));

	char sDisplay[64];

	menu.AddItem(NULL_STRING, "Обновить\n ");

	FormatEx(sDisplay, sizeof sDisplay, "Редактируем: %s", g_sRedact[g_eEntity[client].type]);
	menu.AddItem(NULL_STRING, sDisplay);

	FormatEx(sDisplay, sizeof sDisplay, "%s: %s\n ", 
	g_eEntity[client].type == Type_RGB ? "Цвет" : "Ось", GetClientItemEdit(client));

	/* ??77?7??
	[SM] Exception reported: Heap leak detected: hp:12220 should be 12216!
	g_eEntity[client].type == Type_RGB ? g_sChangeRGB[ g_eEntity[client].color ] : GetClientAxisEdit(client) );  => GetClientItemEdit(client)
	*/

	menu.AddItem(NULL_STRING, sDisplay);
	

	menu.AddItem(NULL_STRING, "Телепортироваться к энтити");
	menu.AddItem(NULL_STRING, "Телепортировать ко мне\n");

	menu.AddItem(NULL_STRING, "Сохранение/Удаление =>", ITEMDRAW_DISABLED);

	menu.AddItem(NULL_STRING, "Сохранить изменения");
	menu.AddItem(NULL_STRING, "Удалить изменения");
	menu.AddItem(NULL_STRING, "Удалить данную entity");
	

	menu.Display(client, MENU_TIME_FOREVER);
}
stock void CreateCustomEditMenu(int client)
{
	if(g_eEntity[client].edit != Edit_Custom || !g_eEntity[client].id || !IsValidEntity(g_eEntity[client].id)) return;

	Menu menu = new Menu(EditCustom_);
	menu.ExitBackButton = true;
	menu.ExitButton = false;

	menu.SetTitle("Редактируем: %d [%s]\nТип: %s\nСейчас: %d [ %d:%d ]", 
	g_eEntity[client].id,
	g_eEntity[client].sName, 
	g_eCustom[client].sInfo,
	g_eCustom[client].current,
	g_eCustom[client].diff[Settings_MIN],
	g_eCustom[client].diff[Settings_MAX]);

	menu.AddItem("1", 		"+ 1");
	menu.AddItem("10", 		"+ 10");
	menu.AddItem("100", 	"+ 100");
	menu.AddItem("-1", 		"- 1");
	menu.AddItem("-10", 	"- 10");
	menu.AddItem("-100", 	"- 100\nСохранение=>");

	menu.AddItem("s", "Сохранить");

	menu.Display(client, MENU_TIME_FOREVER);
	
}
public int EditCustom_(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_End:	menu.Close();
		case MenuAction_Select:
		{
			char sInfo[8];
			menu.GetItem(param2, sInfo, sizeof sInfo);

			if(sInfo[0] == 's')
			{
				g_eEntity[param1].edit = Edit_None;
				Forward_EndEditMenu(param1, true, true, g_eCustom[param1].current);

				return 0;
			}

			int iValue = StringToInt(sInfo);
			g_eCustom[param1].current += iValue;

			if(			g_eCustom[param1].current < g_eCustom[param1].diff[Settings_MIN]) 	g_eCustom[param1].current = g_eCustom[param1].diff[Settings_MIN];
			else if (	g_eCustom[param1].current > g_eCustom[param1].diff[Settings_MAX])	g_eCustom[param1].current = g_eCustom[param1].diff[Settings_MAX];

			CreateCustomEditMenu(param1);
		}
		case MenuAction_Cancel: if(param2 == MenuCancel_ExitBack) 	Forward_EndEditMenu(param1, true);
	}
	return 0;
}
public int Edit_(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_End:	menu.Close();
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 1:
				{
					g_eEntity[param1].type++;
					if(g_eEntity[param1].type >= ChangeType) g_eEntity[param1].type = Type_Pos;
				}
				case 2:
				{
					if(g_eEntity[param1].type == Type_RGB)
					{
						g_eEntity[param1].color++;
						if(g_eEntity[param1].color > Color_Blue) g_eEntity[param1].color = Color_Red;
					}
					else
					{
						switch(g_eEntity[param1].axis)
						{
							case Axis_X:	g_eEntity[param1].axis = Axis_Y;
							case Axis_Y :	g_eEntity[param1].axis = Axis_Z;
							default:		g_eEntity[param1].axis = Axis_X;
						}
					}
				}
				case 3:	TeleportToEditEntity(param1);
				case 4:	TelepotEntityToClient(param1, g_eEntity[param1].id);
				case 6:	KVEditSave(param1);
				case 7:	KVEditSave(param1, false);
				case 8:
				{
					Edit_(null, MenuAction_Cancel, param1, MenuCancel_ExitBack);
					DeleteEntity(param1,g_eEntity[param1].id);
				}
			}
			CreateEditMenu(param1);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				g_eEntity[param1].edit = Edit_None;
				Forward_EndEditMenu(param1);
			}
		}
	}
}