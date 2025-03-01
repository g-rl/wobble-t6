/* apathy kit
*/


#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\functions;
#include scripts\mp\utility;

init()
{
    start();
    level thread on_connect();
}

on_connect()
{
    level endon("game_ended");

    for(;;)
    {
        level waittill("connected", player);
        player thread on_event();
        player thread on_class_change();
        player thread respawn_player(player);
    }
}

on_event()
{
    level endon("game_ended");
    self endon("disconnect");
    for(;;)
    {
        event = waittill_any_return( "spawned_player", "player_downed", "death", "disconnect" );

        switch( event ) 
        {
            case "spawned_player":
                spawned_player_stub();
                break;
            case "death":
                death_stub();
                break;
            case "disconnect":
                death_stub();
                break;
            default:
                break;
        }
    }
}

spawned_player_stub()
{
    if(!isDefined(self.first_spawn))
    {
        sfx("uin_gamble_perk", 1); // lol
        thread test_check();

        self.first_spawn = true;
        self.unstuck = self.origin;
        
        if(self is_bot())
        {
            thread loop_freeze();
            dvar("spawned_bots", 1);
        }

        if(self ishost())
        {
            thread spawn_enemy();
        }
    }

    // printer("^3Welcome.. It's working..");
    self thread ensure_reload();
    self thread vsat();
    self thread set_health(200);
    self thread loop_perks();

    freeze(0);
}

death_stub() 
{
    self notify("removal");
}

on_class_change()
{
    self endon("disconnect");

    for(;;)
    {
        self waittill("changed_class");
        self maps\mp\gametypes\_class::giveloadout( self.team, self.class );
        printer(undefined, " ");
    }
}

start()
{
    level.apathy = [];
    level.apathy["tag"] = "#^1apathy kit";
    level.apathy["thanks"] = "\n^7thanks for playing!\n\nmade by ^6angora";
    
    level.c4array = [];
    level.claymorearray = [];
    level.callDamage = level.callbackplayerdamage;
    level.callbackplayerdamage = ::damage_hook;
    level.prematchperiod = 3;
    level.result = 0;
    
    game["strings"]["change_class"] = undefined;

    dvars();
}

dvars()
{
    dvar( "allclientdvarsenabled", 1 );
    dvar( "player_useradius", 175 );
    dvar( "sv_cheats", 1 );
    dvar( "sv_enablebounces", 1 );
    dvar( "scr_killcam_time", 7.4 );
    dvar( "bg_prone_yawcap", 360 );
    dvar( "bg_ladder_yawcap", 360 );
    dvar( "scr_motd", level.apathy["tag"] );
    dvar( "perk_bulletPenetrationMultiplier", 999 );
    dvar( "player_breath_gasp_lerp", 0 );
    dvar( "grenadeFrictionLow", 1 );
    dvar( "grenadeBumpMax", 1 );
    dvar( "grenadeBumpFreq", 1 );
    dvar( "grenadeRestThreshold", 1000 );
    dvar( "grenadeWobbleFreq", 1 );
    dvar( "grenadeRollingEnabled", 0 );
    dvar( "grenadeCurveMax", 0 );
    dvar( "player_throwbackOuterRadius", 2000 );
    dvar( "player_throwbackInnerRadius", 1000 );
    dvar( "spawned_bots", 0 );

    dvarinfo( "perk_bulletPenetrationMultiplier", 999 );
    dvarinfo( "scr_motd", level.apathy["tag"] );
}