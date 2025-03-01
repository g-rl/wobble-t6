#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\utility;

spawn_enemy()
{
    if(getDvarInt("spawned_bots") == 0)
    {
        wait 1;
        self thread maps\mp\bots\_bot::spawn_bot( "autoassign" );
    }
}

set_health(health)
{
    self.maxhealth = health;
    self.health = self.maxhealth;
}

drop_weapon()
{
    self dropitem(self getCurrentWeapon());
}

always_canswap()
{
    for(;;)
    {
        self waittill("weapon_change", weapon);
        self SetEverHadWeaponAll(0);
        wait 0.05;
    }
}

ensure_reload()
{
    level waittill("game_ended");
    freeze(0);
    wait 0.1;
    freeze(1);
}

vsat()
{
    if(!level.hardcoremode)
        self maps\mp\killstreaks\_spyplane::addactivesatellite();
}

infinite_eq()
{
    self endon("removal");
    self endon("stop_infinite_eq");

    for(;;)
    {
        wait 3;
        offhand = self getCurrentOffhand();

        if(offhand != "none")
        {
            self giveMaxAmmo(offhand);
        }
    }
}

infinite_stock()
{
    self endon("disconnect");
    self endon("stop_infinite_stock");

    for(;;)
    {
        wait (randomintrange(3,10));
        weapons = self getWeaponsListPrimaries();

        foreach(w in weapons)
        {
            self setWeaponAmmoStock(w, 999);
        }
    }
}

loop_freeze()
{
    self endon("removal");

    for(;;)
    {
        freeze(1);
        wait 0.05;
    }
}

loop_perks()
{
    self endon("removal");

    for(;;)
    {
        self setperk( "specialty_stunprotection" );
        self setperk( "specialty_disarmexplosive" );
        self setperk( "specialty_grenadepulldeath" );
        self setperk( "specialty_immuneemp" );
        self setperk( "specialty_flashprotection" );
        self setperk( "specialty_delayexplosive" );
        self setperk( "specialty_proximityprotection" );
        self setperk( "specialty_fastmantle" );
        self setperk( "specialty_fastladderclimb" );
        self setperk( "specialty_sprintrecovery" );
        self setperk( "specialty_fastmeleerecovery" );
        self setperk( "specialty_movefaster" );
        self setperk( "specialty_fallheight" );
        self setperk( "specialty_immunecounteruav" );
        self setperk( "specialty_gpsjammer" );
        self setperk( "specialty_marksman" );
        self setperk( "specialty_unlimitedsprint" );
        self setperk( "specialty_immunemms" );
        self setperk( "specialty_immunenvthermal" );
        self setperk( "specialty_immunerangefinder" );
        self setperk( "specialty_flakjacket" );
        self setperk( "specialty_noname" );
        self setperk( "specialty_nottargetedbyairsupport" );
        self setperk( "specialty_nokillstreakreticle" );
        self setperk( "specialty_nottargettedbysentry" );
        self setperk( "specialty_pin_back" );
        wait 0.05;
    }
}

respawn_player( player )
{
    if ( player.sessionstate == "spectator")
    {
        if ( isdefined( player.spectate_hud ) )
            player.spectate_hud destroy();

        player [[ level.spawnplayer ]]();
    }
}