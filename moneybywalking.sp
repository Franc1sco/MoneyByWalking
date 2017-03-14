/*  SM Money By Walking
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdktools>


#define VERSION "2.1"


new g_Movements[MAXPLAYERS+1];
new Float:lastPosition[MAXPLAYERS + 1][3];
new g_iAccount = -1;


new Handle:cvar_amount;
new Handle:cvar_ratio;
new Handle:cvar_interval;
new Handle:cvar_timer;
new Handle:cvar_distance;

new g_amount;
new g_ratio;
new Float:f_distance;

new Float:newPosition[3], Float:distance;


public Plugin:myinfo = 
{
	name = "SM Money By Walking",
	author = "Franc1sco Steam: franug",
	description = "You receive money by walking",
	version = VERSION,
	url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{
	
	CreateConVar("sm_moneybywalking_version", VERSION, "version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
	
	cvar_amount = CreateConVar("sm_moneybywalking_amount", "5", "Determine how much money is received.");
	cvar_ratio = CreateConVar("sm_moneybywalking_ratio", "10", "Movements required for add money (1 movement can be produced depending of sm_monyebywalking_interval.)");
	cvar_interval = CreateConVar("sm_moneybywalking_interval", "0.2", "how often count the movement (defaul: 0.2 seconds. every 1 seconds is equal to 1.0)");
	cvar_distance = CreateConVar("sm_moneybywalking_distance", "20.0", "distance required from the last count for add a movement  (defaul: 20.0)");
	
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
	
	cvar_timer = CreateTimer(GetConVarFloat(cvar_interval), Checker, _, TIMER_REPEAT);
	
	HookConVarChange(cvar_interval, Cvar_Interval_Change);
	HookConVarChange(cvar_amount, OnCVarChange);
	HookConVarChange(cvar_ratio, OnCVarChange);
	HookConVarChange(cvar_distance, OnCVarChange);
}

public Cvar_Interval_Change(Handle:convar, const String:oldValue[], const String:newValue[]) 
{
	KillTimer(cvar_timer);
	cvar_timer = CreateTimer(GetConVarFloat(cvar_interval), Checker, _, TIMER_REPEAT);
}

public OnCVarChange(Handle:convar_hndl, const String:oldValue[], const String:newValue[])
{
	GetCVars();
}

public OnClientPostAdminCheck(client)
{
	g_Movements[client] = 0;
}

public OnConfigsExecuted()
{
	GetCVars();
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	GetClientAbsOrigin (client, newPosition);
	lastPosition[client] = newPosition;
}

public Action:Checker(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++) 
		if(IsClientInGame(i) && IsPlayerAlive(i)) 
		{
			GetClientAbsOrigin (i, newPosition);
			distance = GetVectorDistance (lastPosition[i], newPosition);
			lastPosition[i] = newPosition;
			if (distance >= f_distance)
			{
				++g_Movements[i];
				if(g_Movements[i] >= g_ratio)
				{
					SetEntData(i, g_iAccount, GetEntData(i, g_iAccount) + g_amount);
					g_Movements[i] = 0;
				}
			}
			
		}
}

// Get new values of cvars if they has being changed
public GetCVars()
{
	g_amount = GetConVarInt(cvar_amount);
	g_ratio = GetConVarInt(cvar_ratio);
	f_distance = GetConVarFloat(cvar_distance);
}