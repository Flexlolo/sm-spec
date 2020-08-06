/*
COMPILE OPTIONS
*/

#pragma semicolon 1
#pragma newdecls required

/*
INCLUDES
*/

#include <sourcemod>
#include <sdktools>

#include <lololib>
#include <printqueue>

/*
PLUGIN INFO
*/

public Plugin myinfo = 
{
	name			= "Spectate",
	author			= "Flexlolo",
	description		= "Spectate command with modes",
	version			= "1.0.0",
	url				= "github.com/Flexlolo/"
}

/*
GLOBAL VARIABLES
*/

#define CHAT_SPEC 			"\x072f4f4f[\x07ff6347Spec\x072f4f4f]:"
#define CHAT_VALUE 			"\x07ff6347"
#define CHAT_SUCCESS 		"\x07FFC0CB"
#define CHAT_ERROR 			"\x07DC143C"

// Mode
enum
{
	Spec_Mode_Normal,
	Spec_Mode_Deathrun,

	Spec_Modes
}

int g_iSpec_Mode = Spec_Mode_Normal;


/*
NATIVES AND FORWARDS
*/

public void OnPluginStart()
{
	RegConsoleCmd("sm_spectate",	Command_Spec, "Spectate");
	RegConsoleCmd("sm_spec", 		Command_Spec, "Spectate");
	RegConsoleCmd("sm_sp", 			Command_Spec, "Spectate");
	RegConsoleCmd("sm_afk", 		Command_Spec, "Spectate");
}

/*
COMMANDS
*/

public Action Command_Spec(int client, int args)
{
	if (lolo_IsClientValid(client))
	{
		if (!Spec_Mode_Check(client))
		{
			QPrintToChat(client, "%s %sYou can't go to spectators.", CHAT_SPEC, CHAT_ERROR);
			return Plugin_Handled;
		}

		char sArgs[192];
		GetCmdArgString(sArgs, sizeof(sArgs));

		int spec_target;

		if (strlen(sArgs))
		{
			ArrayList hTargets = lolo_Target_Process(client, sArgs);

			if (hTargets != null)
			{
				int size = hTargets.Length;

				if (size == 1)
				{
					int target = hTargets.Get(0);

					bool target_valid;

					if (client != target)
					{
						if (IsPlayerAlive(target))
						{
							target_valid = true;
						}
					}

					if (target_valid)
					{
						spec_target = target;
					}
					else
					{
						QPrintToChat(client, "%s %sInvalid target to spectate.", CHAT_SPEC, CHAT_ERROR);
					}
				}
				else if (size)
				{
					QPrintToChat(client, "%s %sMore than one target.", CHAT_SPEC, CHAT_ERROR);
				}
				else
				{
					QPrintToChat(client, "%s %sInvalid target.", CHAT_SPEC, CHAT_ERROR);
				}
			}
			else
			{
				QPrintToChat(client, "%s %sInvalid target.", CHAT_SPEC, CHAT_ERROR);
			}
		}
		
		MovePlayerToSpec(client);

		if (spec_target)
		{
			lolo_SetClientSpecTarget(client, spec_target);
		}
	}

	return Plugin_Handled;
}

stock bool Spec_Mode_Check(int client)
{
	switch (g_iSpec_Mode)
	{
		case Spec_Mode_Normal:
		{
			return true;
		}
		case Spec_Mode_Deathrun:
		{
			if (!IsPlayerAlive(client))
			{
				return true;
			}

			if (GetClientTeam(client) == 2)
			{
				if (GetTeamClientCount(3) > 0)
				{
					return false;
				}
			}

			return true;
		}
	}

	return true;
}


stock void MovePlayerToSpec(int client)
{
	ForcePlayerSuicide(client);
	ChangeClientTeam(client, 1);
}