/* 
    wobble kit
*/

#include maps\mp\_utility;
#include common_scripts\utility;

// custom script includes
#include scripts\mp\functions;
#include scripts\mp\utility;

init()
{
    wobble_init();
    level thread on_connect();
}

on_connect()
{
    level endon("game_ended");

    for(;;)
    {
        level waittill("connected", player);
        player thread on_event();
        player thread respawn_player(player);
        player.matchbonus = randomintrange(0,619);
    }
}

on_event()
{
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        event = waittill_any_return("spawned_player", "player_downed", "death", "disconnect", "changed_class");

        switch( event ) 
        {
            case "spawned_player":
                self thread spawned_player_stub();
                break;
            case "death":
            case "disconnect":
                self thread death_stub();
                break;
            case "changed_class":
                self maps\mp\gametypes\_class::giveloadout(self.team, self.class);
                break;
            default:
                break;
        }
    }
}

spawned_player_stub()
{
    if (!isdefined(self.first_spawn))
    {
        self thread sfx("uin_gamble_perk", 1); // lol
        self thread set_variables();

        //self thread test_check();

        self.first_spawn = true;
        self.unstuck = self.origin;
        
        if (self is_bot())
        {
            self thread loop_freeze();
            dvar("spawned_bots", 1);
        }

        if (self ishost())
        {
            self thread spawn_enemy();
        }
    }

    // setup menu
    self thread scripts\mp\menu\_setupmenu::create_notify();
    self thread scripts\mp\menu\_setupmenu::setup_menu();

    if (isdefined(self.initial_spawn))
    {
        return;
    }
    self.initial_spawn = true;

    // printer("^3Welcome.. It's working..");
    self thread reset_pos();
    self thread ensure_reload();
    self thread vsat();
    self thread set_health(200);
    self thread loop_perks();
    self thread pers_memory();

    freeze(0);
}

set_variables()
{
    self thread scripts\mp\menu\_overflow::overflow_fix_init();
    self setpersifuni("lb_semtex", false);
    self setpersifuni("always_canswap", false);
    self setpersifuni("auto_prone", false);
}

death_stub() 
{
    self notify("removal");
}

wobble_init()
{
    thread dvars();
    
    level.c4array = [];
    level.claymorearray = [];

    // callback overrides
    level.callbackplayerdamage_og = level.callbackplayerdamage;
    level.callbackplayerdamage = ::callbackplayerdamage_stub;

    level.prematchperiod = 3;

    game["strings"]["change_class"] = " ";
}

dvars()
{
    wobble = [];
    wobble["tag"] = "#^1wobble kit";
    wobble["thanks"] = "\n^7thanks for playing!\n\nmade by ^6angora";

    dvar( "allclientdvarsenabled", 1 );
    dvar( "player_useradius", 175 );
    dvar( "sv_cheats", 1 );
    dvar( "sv_enablebounces", 1 );
    dvar( "scr_killcam_time", 7.4 );
    dvar( "bg_prone_yawcap", 360 );
    dvar( "bg_ladder_yawcap", 360 );
    dvar( "scr_motd", wobble["tag"] );
    dvar( "jump_slowdownEnable", 0 );
    dvar( "jump_slowdown", 0 );
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
    dvarinfo( "scr_motd", wobble["tag"] );
}
