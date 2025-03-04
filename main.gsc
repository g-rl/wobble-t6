/*
    wobble kit
*/

#include maps\mp\_utility;
#include common_scripts\utility;

// custom script includes
#include scripts\mp\functions;
#include scripts\mp\utility;
#include scripts\mp\binds;

init()
{
    level thread scripts\mp\menu\_overflow::overflow_fix_init();
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

        self.first_spawn = true;
        self.unstuck = self.origin;

        if (self is_bot())
        {
            self thread loop_freeze();
            dvar("spawned_bots", 1);
        } else {
            self thread set_variables();
        }

        if (self ishost())
        {
            self thread spawn_enemy();
        }
    }

    self thread respawn_memory();
    self thread set_health(200);
    self thread reset_pos();
    self thread loop_perks();
    // self thread vsat();
    freeze(0);

    if (isdefined(self.initial_spawn))
    {
        return;
    }

    self.initial_spawn = true;

    self thread scripts\mp\menu\_setupmenu::create_notify();
    self thread scripts\mp\menu\_setupmenu::setup_menu();

    self thread bind_memory();
    self thread pers_memory();
    self thread ensure_reload();

}

// initialize persistent
set_variables()
{
    self setpersifuni("lb_semtex", false);
    self setpersifuni("always_canswap", false);
    self setpersifuni("auto_prone", false);
    self setpersifuni("random_class_spawn", false);
    self setpersifuni("class_type", "smg");
    self set_pers("lives", 99);

    self.lives = self get_pers("lives");
    
    // change class vars
    self.curr_class = 0;
    self.curr_class_5 = 0;
}

// initialize binds
bind_memory()
{
    self setup_bind("random_class_bind", "^1off^7", ::random_class_bind);
    self setup_bind("change_class_bind", "^1off^7", ::change_class_bind);
    self setup_bind("change_class_5_bind", "^1off^7", ::change_class_5_bind);
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
    wobble["thanks"] = "\n^7thanks for playing!\n\nmade by ^6angora & mjkzy";

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
