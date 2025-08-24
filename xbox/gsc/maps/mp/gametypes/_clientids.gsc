/*
    wobble kit - t6 setup / unsetup mod
    made by @nyli2b @mjkzys
    menu base by mirele @girlmachinery
*/

#include maps\mp\_utility;
#include common_scripts\utility;

#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud_message;
#include maps\mp\gametypes\_weapons;
#include maps\mp\gametypes\_rank;
#include maps\mp\gametypes\_hud;

init()
{
    level thread overflow_fix_init();

    wobble_init();
    level thread on_connect();
    level thread remove_sky();
    level thread remove_barriers();
}

onplayerconnect()
{
    level endon("game_ended");

    for (;;)
    {
        level waittill( "connecting", player );
        player.clientid = level.clientid;
        level.clientid++;
    }
}

on_connect()
{
    level endon("game_ended");

    for(;;)
    {
        level waittill("connected", player);
        player thread on_event();
        player.matchbonus = randomintrange(0, 619);
    }
}

on_event()
{
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        self waittill("spawned_player");

        self thread spawned_player_stub();
    }
}

spawned_player_stub()
{
    self iprintln("spawned_player_stub");

    if (!isdefined(self.first_spawn))
    {
        self thread sfx("uin_gamble_perk", 1);

        self.first_spawn = true;

        if (self is_bot())
        {
            self thread loop_freeze();
            self thread random_rank();
            dvar("spawned_bots", 1);
        }

        if (self ishost())
        {
            self thread spawn_enemy();
        }

        self thread set_variables(); 
    }

    self thread pers_memory();
    self thread refill_ammo();
    self thread set_health(200);
    self thread reset_pos();
    self thread loop_perks();
    self thread monitor_sprint();
    // self thread vsat();

    freeze(0);

    if (isdefined(self.initial_spawn))
        return;

    self.initial_spawn = true;

    if(self is_bot())
        return;

    self thread create_notify();
    self thread setup_menu();

    self thread bind_memory();
    self thread ensure_reload();
}

// initialize persistent
set_variables()
{
    self setpersifuni("lb_semtex", false);
    self setpersifuni("always_canswap", false);
    self setpersifuni("auto_prone", false);
    self setpersifuni("random_class_spawn", false);
    self setpersifuni("instashoots", false);
    self setpersifuni("elevators", false);
    self setpersifuni("unlimited_lives", false);
    self setpersifuni("eq_swaps", false);
    self setpersifuni("g_watermark", true);
    self setpersifuni("unstuck", self.origin);
    self setpersifuni("wm_color", "^1");
    self setpersifuni("class_type", "smg");

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
    self setup_bind("refill_ammo_bind", "^1off^7", ::refill_ammo_bind);
    self setup_bind("refill_eq_bind", "^1off^7", ::refill_eq_bind);
    self setup_bind("flash_bind", "^1off^7", ::flash_bind);
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
    wobble["thanks"] = "\n^7thanks for playing!\n\nmade by ^6nyli & mjkzy";

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

pers_memory()
{
    if(self is_bot())
        return;

    if (self get_pers("random_class_spawn") == true) 
        self thread random_class();

    if (self get_pers("eq_swaps") == true)
        self thread eq_swap_loop();

    if (self get_pers("instashoots") == true) 
        self thread instashoots();

    if (self get_pers("always_canswap") == true)
        self thread always_canswap();

    if (self get_pers("auto_prone") == true)
        self thread auto_prone();

    if (self get_pers("elevators") == true)
        self thread elevators();

    if (self get_pers("lb_semtex") == true)
    {
        self.lb_semtex = true;
        self thread lb_semtex();
        self thread semtex();
    }
}

toggle_eq_swaps(value)
{
    if (value == true)
    {
        self set_pers(value, true);
        self thread eq_swap_loop();
    }
    else
    {
        self set_pers(value, false);
        self notify("stop_eq_swap");
    }
}

eq_swap_loop()
{
    self endon("stop_eq_swap");
    self endon("disconnect");
    level endon("game_ended");

    self iprintln("broken atm, sorry");

    for(;;)
    {
        self waittill("grenade_pullback", grenade);

        if (maps\mp\killstreaks\_killstreaks::iskillstreakweapon(grenade)) // so you can still pull out streaks lol
            continue;
    }
}

switchto(weapon)
{
    current = self getcurrentweapon();

    self takeweapongood(current);
    self giveweapon(weapon);
    self switchtoweapon(weapon);
    wait 0.05;
    self giveweapongood(current);
}

takeweapongood(gun)
{
    self.getgun[gun] = gun;
    self.getclip[gun] =  self getweaponammoclip(gun);
    self.getstock[gun] = self getweaponammostock(gun);
    self takeweapon(gun);
}

giveweapongood(gun)
{
    self giveweapon(self.getgun[gun]);
    self setweaponammoclip(self.getgun[gun], self.getclip[gun]);
    self setweaponammostock(self.getgun[gun], self.getstock[gun]);
}

toggle_auto_prone(value)
{
    if (value == true)
    {
        self set_pers(value, true);
        self thread auto_prone();
    }
    else
    {
        self set_pers(value, false);
        self notify("stop_auto_prone");
    }
}

auto_prone()
{
    self endon("removal");
    self endon("stop_auto_prone");

    for(;;)
    {
        self waittill("weapon_fired", weapon);

        if (self isOnGround() || self isOnLadder() || self isMantling() || isDefined(self.elevating))
            continue;

        if (damage_weapon(weapon))
        {
            self thread loop_auto_prone();
            wait 0.5;
            self notify("temp_end");
        }
        wait 0.05;
    }
}

loop_auto_prone()
{
    self endon("temp_end");
    for(;;)
    {
        self setStance("prone");
        wait .01;
    }
}

spawn_enemy()
{
    if (getDvarInt("spawned_bots") == 0)
    {
        wait 1.5;
        self thread maps\mp\bots\_bot::spawn_bot( "autoassign" );
    }
}

set_spawnpoint()
{
    self.pers["spawn_origin"] = self.origin;
    self.pers["spawn_angles"] = self.angles;
    self iprintln("spawnpoint ^2set");
}

teleport_enemy( player )
{
    foreach (bot in level.players)
    {
        if (self.pers["team"] != bot.pers["team"])
        {
            if (isDefined(bot.pers["isBot"]) && bot.pers["isBot"])
            {
                bot setorigin(bullettrace(self gettagorigin( "j_head" ), self gettagorigin( "j_head" ) + anglestoforward( self getplayerangles() ) * 1000000, 0, self )[ "position"] );
                wait 0.05;
                bot.pers["saveorigin"] = bot.origin;
                bot.pers["saveangle"] = bot.angles;
            }
        }
    }
}

reset_pos()
{
    if (isDefined(self.pers["saveorigin"]))
    {
        self setorigin(self.pers["saveorigin"]);
        self setplayerangles(self.pers["saveangle"]);
    }

    if (isDefined(self.pers["spawn_origin"]))
    {
        self setorigin(self.pers["spawn_origin"]);
        self setplayerangles(self.pers["spawn_angles"]);
    }
}

set_health(health)
{
    if(self is_bot())
        return;

    self.maxhealth = health;
    self.health = self.maxhealth;
}

drop_weapon()
{
    self dropitem(self getCurrentWeapon());
}

toggle_canswap(value)
{
    if (value == true)
    {
        self thread always_canswap();
        self set_pers(value, true);
    }
    else
    {
        self set_pers(value, false);
        self notify("stop_canswap");
    }
}

always_canswap()
{
    self endon("stop_canswap");
    self endon("removal");
    
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
    if (isdefined(level.hardcoremode) && !level.hardcoremode)
    {
        type = "radar_mp";
        killstreak_id = self maps\mp\killstreaks\_killstreakrules::killstreakstart(type, self.team);
        self maps\mp\killstreaks\_spyplane::callsatellite(type, 0, killstreak_id);
    }
}

infinite_eq()
{
    self endon("removal");
    self endon("stop_infinite_eq");

    for(;;)
    {
        wait 3;
        offhand = self getCurrentOffhand();

        if (offhand != "none")
        {
            self giveMaxAmmo(offhand);
        }
    }
}

infinite_stock()
{
    self endon("removal");
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

respawn_player()
{
    if ( self.sessionstate == "spectator")
    {
        if ( isdefined( self.spectate_hud ) )
            self.spectate_hud destroy();

        self [[ level.spawnplayer ]]();
    }
}

toggle_semtex(value)
{
    if (value == true)
    {
        self thread lb_semtex();
        self thread semtex();
        self set_pers("lb_semtex", true);
    }
    else
    {
        self set_pers("lb_semtex", false);
        self notify("stop_semtex");
    }
}

lb_semtex()
{
    self endon( "stop_semtex" );
    self endon( "removal" );

    for (;;)
    {
        self waittill_any( "changed_class", "custom_class" );
        wait 0.05;
        self thread semtex();
        wait 0.05;
    }
}

semtex()
{
    if ( !self hasweapon( "sticky_grenade_mp" ) )
    {
        self takeweapon( "concussion_grenade_mp" );
        self takeweapon( "willy_pete_mp" );
        self takeweapon( "sensor_grenade_mp" );
        self takeweapon( "emp_grenade_mp" );
        self takeweapon( "proximity_grenade_aoe_mp" );
        self takeweapon( "proximity_grenade_mp" );
        self takeweapon( "pda_hack_mp" );
        self takeweapon( "flash_grenade_mp" );
        self takeweapon( "trophy_system_mp" );
        self takeweapon( "tactical_insertion_mp" );
        self giveweapon( "sticky_grenade_mp" );
        self setweaponammoclip( "sticky_grenade_mp", 2 );
    }
}

special_nades()
{
    if ( self hasweapon( "concussion_grenade_mp" ) || self hasweapon( "willy_pete_mp" ) || ( self hasweapon( "sensor_grenade_mp" ) || self hasweapon( "emp_grenade_mp" ) ) || ( self hasweapon( "proximity_grenade_aoe_mp" ) || self hasweapon( "proximity_grenade_mp" ) ) || ( self hasweapon( "pda_hack_mp" ) || self hasweapon( "flash_grenade_mp" ) ) || ( self hasweapon( "trophy_system_mp" ) || self hasweapon( "tactical_insertion_mp" ) ) )
    {
        self takeweapon( "frag_grenade_mp" );
        self takeweapon( "sticky_grenade_mp" );
        self takeweapon( "hatchet_mp" );
        self takeweapon( "bouncingbetty_mp" );
        self takeweapon( "satchel_charge_mp" );
        self takeweapon( "claymore_mp" );
        self giveweapon( "explodable_barrel_mp" );
        self setweaponammoclip( "explodable_barrel_mp", 2 );
    }
    else
        self takeweapon( "frag_grenade_mp" );

    self takeweapon( "hatchet_mp" );
    self takeweapon( "bouncingbetty_mp" );
    self takeweapon( "satchel_charge_mp" );
    self takeweapon( "claymore_mp" );
    self giveweapon( "explodable_barrel_mp" );
    self setweaponammoclip( "explodable_barrel_mp", 2 );
}

drop_canswap(value)
{
    smg = random_weapon("mp7,pdw57,vector,insas,qcw05,evoskorpion,peacekeeper");
    ar = random_weapon("tar21,type95,sig556,sa58,hk416,scar,saritch,xm8,an94");
    shotgun = random_weapon("870mcs,saiga12,ksg,srm1216");
    lmg = random_weapon("mk48,qbb95,lsat,hamr");
    sniper = random_weapon("svu,dsr50,ballista,as50");
    pistol = random_weapon("kard_dw,fnp45_dw,fiveseven_dw,judge_dw,baretta93r_dw,fiveseven,fnp45,baretta93r,judge,kard");
    misc = random_weapon("smaw,fhj18,usrpg,riotshield,crossbow,knife_ballistic_mp");

    smg_attachment = randomize("+sf,+reflex,+silencer,+fmj,+fastads,+dualclip");
    ar_attachment = randomize("+mms,+gl,+fastads,+dualclip,+reflex");
    shotgun_attachment = randomize("+extbarrel,+silencer,+fastads,+reflex");
    lmg_attachment = randomize("+ir,+stalker");
    sniper_attachment = randomize("+ir,+dualclip,+silencer,+acog,+vzoom,+steadyaim,+swayreduc,+ir+dualclip");

    switch( value )
    {
    case "smg":
        self drop_item(smg + smg_attachment);
        break;
    case "ar":
        self drop_item(ar + ar_attachment);
        break;
    case "lmg":
        self drop_item(lmg + lmg_attachment);
        break;
    case "shotgun":
        self drop_item(shotgun + shotgun_attachment);
        break;
    case "sniper":
        self drop_item(sniper + sniper_attachment);
        break;
    case "pistol":
        self drop_item(pistol);
        break;
    case "misc":
        self drop_item(misc);
        break;
    default:
        break;
    }
}

drop_item(weapon)
{
    // self giveweapon(weapon, self.camo, 1, 0, 0, 0);
    self giveweapon(weapon);
    self givemaxammo(weapon);
    self dropitem(weapon);
}

reset_rounds()
{
    self iprintlnbold("^2reset scores");
    level waittill("game_ended");
    game["roundsWon"]["axis"] = 0;
    game["roundsWon"]["allies"] = 0;
    game["roundsplayed"] = 0;
    game["teamScores"]["allies"] = 0;
    game["teamScores"]["axis"] = 0;
}

give_streaks()
{
    self maps\mp\gametypes\_globallogic_score::_setplayermomentum(self, 1600);
}

// class generator
get_class_types()
{
    return list("smg,ar,lmg,shotgun,sniper,pistol,misc");
}

get_weapon_for_type(type)
{
    //streak = randomize("counteruav_mp,inventory_supplydrop_mp,rcbomb_mp,remote_missile_mp,turret_drop_mp,killstreak_qrdrone_mp,inventory_minigun_mp,inventory_m32_mp");

    switch(type)
    {
        case "smg": 
            return randomize("mp7_mp+sf,mp7_mp+sf+rangefinder,pdw57_mp,pdw57_mp+sf,pdw57_mp+sf+dualclip,vector_mp+sf,vector_mp+sf+rangefinder,insas_mp+sf,insas_mp+sf+silencer,qcw05_mp+sf,evoskorpion_mp+sf,evoskorpion_mp+sf+dualclip,peacekeeper_mp+sf,peacekeeper_mp+sf+dualclip");
        case "ar":  
            return randomize("tar21_mp+sf,tar21_mp+sf+dualclip,tar21_mp+gl,tar21_mp+gl+dualclip,type95_mp+sf,type95_mp+sf+dualclip,sig556_mp+sf,sig556_mp+sf+dualclip,sa58_mp+sf,sa58_mp+sf+dualclip,hk416_mp+dualoptic,hk416_mp+sf,hk416_mp+rangefinder+sf,hk416_mp+sf+dualclip,scar_mp+sf,scar_mp+sf+extclip,saritch_mp+sf,saritch_mp+dualoptic,an94_mp+sf,an94_mp+dualoptic");
        case "lmg": 
            return randomize("mk48_mp+rf,qbb95_mp+rf,lsat_mp+rf,hamr_mp+rf");
        case "shotgun": 
            return randomize("870mcs_mp,870mcs_mp+reflex,870mcs_mp+mms,870mcs_mp+silencer,saiga12_mp,saiga12_mp+mms,ksg_mp,ksg_mp+mms,ksg_mp+reflex,srm1216_mp,srm1216_mp+extclip");
        case "pistol":
            return randomize("fiveseven_mp,fiveseven_dw_mp,fiveseven_mp+tacknife,fiveseven_mp+dualclip,fnp45_mp,fnp45_mp+tacknife,fnp45_mp+dualclip,fnp45_dw_mp,beretta93r_mp,beretta93r_dw_mp,beretta93r_mp+tacknife,beretta93r_mp+dualclip,judge_mp,judge_dw_mp,judge_mp+tacknife,kard_mp,kard_dw_mp,kard_mp+tacknife");
        case "misc":
            return randomize("crossbow_mp+stackfire,crossbow_mp+stackfire+ir,riotshield_mp,knife_ballistic_mp,smaw_mp,fhj18_mp,usrpg_mp");

        case "primary": // primary snipers
            return randomize("dsr50_mp+steadyaim,dsr50_mp+steadyaim+ir,dsr50_mp+steadyaim+extclip,ballista_mp+steadyaim,ballista_mp+steadyaim+ir,ballista_mp+steadyaim+dualclip,ballista_mp+steadyaim+acog,svu_mp+ir,as50_mp+ir");
        case "sniper":  // secondary snipers
            return randomize("svu_mp,svu_mp+acog,dsr50_mp,dsr50_mp+dualclip,ballista_mp,ballista_mp+dualclip,as50_mp");

        case "tactical":    
            return randomize("emp_grenade_mp,concussion_grenade_mp,proximity_grenade_mp,sensor_grenade_mp");
        case "frag":        
            return randomize("hatchet_mp,pda_hack_mp,sticky_grenade_mp,frag_grenade_mp,satchel_charge_mp,tactical_insertion_mp,bouncingbetty_mp,claymore_mp");

        default: // random weapon
            return randomize("mp7_mp+sf,mp7_mp+sf+rangefinder,pdw57_mp,pdw57_mp+sf,pdw57_mp+sf+dualclip,vector_mp+sf,vector_mp+sf+rangefinder,insas_mp+sf,insas_mp+sf+silencer,qcw05_mp+sf,evoskorpion_mp+sf,evoskorpion_mp+sf+dualclip,peacekeeper_mp+sf,peacekeeper_mp+sf+dualclip,tar21_mp+sf,tar21_mp+sf+dualclip,tar21_mp+gl,tar21_mp+gl+dualclip,type95_mp+sf,type95_mp+sf+dualclip,sig556_mp+sf,sig556_mp+sf+dualclip,sa58_mp+sf,sa58_mp+sf+dualclip,hk416_mp+dualoptic,hk416_mp+sf,hk416_mp+rangefinder+sf,hk416_mp+sf+dualclip,scar_mp+sf,scar_mp+sf+extclip,saritch_mp+sf,saritch_mp+dualoptic,an94_mp+sf,an94_mp+dualoptic,870mcs_mp,870mcs_mp+reflex,870mcs_mp+mms,saiga12_mp,saiga12_mp+mms,ksg_mp,ksg_mp+mms,ksg_mp+reflex,srm1216_mp,srm1216_mp+extclip,mk48_mp,qbb95_mp,lsat_mp,hamr_mp,svu_mp,svu_mp+acog,dsr50_mp,dsr50_mp+dualclip,ballista_mp,ballista_mp+dualclip,as50_mp,fiveseven_mp,fiveseven_dw_mp,fiveseven_mp+tacknife,fnp45_mp,fnp45_mp+tacknife,fnp45_dw_mp,beretta93r_mp,beretta93r_dw_mp,beretta93r_mp+tacknife,judge_mp,judge_dw_mp,judge_mp+tacknife,kard_mp,kard_dw_mp,kard_mp+tacknife,usrpg_mp,smaw_mp,crossbow_mp+stackfire,crossbow_mp+stackfire+ir,riotshield_mp,knife_ballistic_mp");
    }
}

give_custom_class(weap1, weap2, equip1, equip2)
{

    self notify("custom_class");

    self takeallweapons();

    camo = self calcweaponoptions(self.class_num, 0);

    // make sure giveweapon isn't having too many parameters, ill check this later -mikey
    self giveweapon("knife_mp", 0, camo, 1, 0, 0, 0);
    self giveweapon(weap1, 0, camo, 1, 0, 0, 0);
    self givemaxammo(weap1);
    self giveweapon(weap2, 0, camo, 1, 0, 0, 0 );
    self givemaxammo(weap2);

    self giveweapon(equip1);
    self setweaponammostock(equip1, 1);
    self giveweapon(equip2);
    self setweaponammostock(equip2, 1);

    self switchtoweapon(weap1);
    self thread give_streaks();
    // TODO: give perks, and set eb weapon automatically?
}

random_class()
{
    class_type = self get_pers("class_type");

    primary = get_weapon_for_type("primary");
    secondary = get_weapon_for_type(class_type);
    tactical = get_weapon_for_type("tactical");
    lethal = get_weapon_for_type("frag");

    self thread give_custom_class(primary, secondary, lethal, tactical);
}

set_class_type(value)
{
    self set_pers("class_type", value);
    self iprintln("class type set to ^2" + value);
}

toggle_random_class_spawn(value)
{
    self set_pers(value, value == false ? true : false);
}

refill_ammo()
{
    weapons = self getweaponslist( 1 );

    foreach(weap in weapons)
    {
        self givemaxammo(weap);
        self setweaponammoclip(weap, weaponclipsize(weap));
    }
}

refill_equipment()
{
    equipment = self getcurrentoffhand();

    if (equipment != "none")
    {
        self setweaponammoclip(equipment, 999);
        self givemaxammo(equipment);
    }
}

change_class_5() 
{
    self thread change_class_5_logic();
    waittillframeend;
    self thread refill_ammo();    
    
    current_weapon = self getCurrentweapon();
    self.camo = self calcweaponoptions( self.class_num, 0 );

    stock = self getWeaponAmmoStock( current_weapon );
    clip = self getWeaponAmmoClip( current_weapon );

    self setweaponammostock( current_weapon, stock );
    self setweaponammoclip( current_weapon, clip);
}

change_class() 
{
    self thread change_class_logic();
    waittillframeend;
    self thread refill_ammo();    

    current_weapon = self getCurrentweapon();
    self.camo = self calcweaponoptions( self.class_num, 0 );
    	
    stock = self getWeaponAmmoStock( current_weapon );
    clip = self getWeaponAmmoClip( current_weapon );

    self setweaponammostock( current_weapon, stock );
    self setweaponammoclip( current_weapon, clip);
}

change_class_logic()
{
    switch( self.curr_class )
    {
        case 0:
            self.curr_class = 1;
            self notify( "menuresponse", "changeclass", "custom1" );
            break;
        case 1:
            self.curr_class = 2;
            self notify( "menuresponse", "changeclass", "custom2" );
            break;
        case 2:
            self.curr_class = 0;
            self notify( "menuresponse", "changeclass", "custom0" );
            break;
        default:
            self.curr_class = 0;
            self notify( "menuresponse", "changeclass", "custom0" );
            break;
    }
}

change_class_5_logic()
{
    switch( self.curr_class_5 )
    {
        case 0:
            self.curr_class_5 = 1;
            self notify( "menuresponse", "changeclass", "custom1" );
            break;
        case 1:
            self.curr_class_5 = 2;
            self notify( "menuresponse", "changeclass", "custom2" );
            break;
        case 2:
            self.curr_class_5 = 3;
            self notify( "menuresponse", "changeclass", "custom3" );
            break;
        case 3:
            self.curr_class_5 = 3;
            self notify( "menuresponse", "changeclass", "custom4" );
            break;
        case 4:
            self.curr_class_5 = 3;
            self notify( "menuresponse", "changeclass", "custom0" );
            break;
        default:
            self.curr_class_5 = 0;
            self notify( "menuresponse", "changeclass", "custom0" );
            break;
    }
}

toggle_lives(value)
{
    if (value == true)
    {
        self set_pers(value, true);
        self thread unlimited_lives();
    }
    else
    {
        self set_pers(value, false);
        self.lives = 1;
        self set_pers("lives", 1);
    }
}

unlimited_lives()
{
    self set_pers("lives", 99);
    self.lives = 99;
}

toggle_instashoots(value)
{
    if (value == true)
    {
        self set_pers(value, true);
        self thread instashoots();
    }
    else
    {
        self set_pers(value, false);
        self notify("stop_instashoots");
    }
}

instashoots()
{
    self endon( "removal" );
    self endon( "stop_instashoots" );

    for (;;)
    {
        self waittill( "weapon_change", weapon );
        self setspawnweapon( weapon );
        self thread instashoot_logic();
        wait 0.05;
    }
}

instashoot_logic()
{
    self endon( "disconnect" );
    self endon( "reload_rechamber" );
    self endon( "stop_instashoots" );
    self endon( "death" );
    self endon( "end_logic" );
    self endon( "next_weapon" );
    self endon( "weapon_armed" );
    self endon( "weapon_fired" );
    self endon( "sprinting" );

    for (;;)
    {
        weapon = self getcurrentweapon();
        
        if (damage_weapon(weapon))
        {
            if ( self attackbuttonpressed() && !self isreloading() && ( !self isswitchingweapons() && !self isfiring() ) && ( !self issprinting() && !self isusingoffhand() && !self isOnLadder() && !self isMantling() ) )
            {
                self disableweapons();
                self setweaponammoclip( weapon, weaponclipsize( weapon ) );
                wait .0000000001; // so fucking stupid but it works i guess ; idk
                self enableweapons();
                self notify( "end_logic" );
            }
        }
        else
            self notify( "end_logic" );

        wait 0.01;
    }
}

monitor_sprint()
{
    self endon("removal");

    if(self is_bot())
        return;

    for (;;)
    {
        if ( self issprinting() )
            self notify( "sprinting" );

        wait 0.01;
    }
}

toggle_elevators(value)
{
    if (value == true)
    {
        self set_pers(value, true);
        self thread elevators();
    }
    else
    {
        self set_pers(value, false);
        self notify("stop_elevator");
    }
}

elevators() 
{
    self endon("removal");
    self endon("stop_elevator");

    for(;;)
    {
        if (self adsButtonPressed() && self StanceButtonPressed() && self isOnGround() && !self isOnLadder() && !self isMantling()) 
        {
            self thread elevator_logic();
            wait 0.25;
        }
        else if (self JumpButtonPressed()) 
        {
            self thread stop_elevator();
        }
        wait 0.01;
    }
    wait 0.01;
}
 
elevator_logic() 
{ 
    self endon( "end_elevator" ); 

    self.elevator = spawn( "script_origin", self.origin, 1 ); 
    self playerLinkTo( self.elevator, undefined ); 
 
    for(;;) 
    {
        self.elevating = true;
        self.o = self.elevator.origin; 
        wait 0.03;
        time = randomintrange(8,20);
        self.elevator.origin = self.o + (0, 0, time); 
        wait 0.03; 
    } 
} 
 
stop_elevator() 
{ 
    wait 0.01; 
    self unlink(); 
    self.elevator delete(); 
    self.elevating = undefined;
    self notify( "end_elevator" ); 
}

unstuck()
{
    self setorigin(self get_pers("unstuck"));
}

random_rank() 
{
    new_value = int(randomint(16));
    self SetRank(54, new_value);
    self maps\mp\gametypes\_rank::syncxpstat();
}

remove_sky()
{
    entArray = getEntArray();
    for (index = 0; index < entArray.size; index++)
    {
        if( isSubStr(entArray[index].classname, "trigger_hurt") && entArray[index].origin[2] > 180 )
            entArray[index].origin = (0, 0, 9999999);
    }
}

remove_barriers() 
{
    level waittill("prematch_over");
    if (getDvar("mapname") == "mp_bridge") 
    { // lower barrier for detour
        entArray = getEntArray();
        for (index = 0; index < entArray.size; index++) {
            if (isSubStr(entArray[index].classname, "trigger_hurt") && entArray[index].origin[2] < level.mapCenter[2]) {
                entArray[index].origin += (0, 0, -1300); //1 unit is 0.0254 meters so 1000 will be 25 meters
            }
        }
    }
    if (getDvar("mapname") == "mp_hydro") { // lower barrier for hydro
        entArray = getEntArray();
        for (index = 0; index < entArray.size; index++) {
            if (isSubStr(entArray[index].classname, "trigger_hurt") && entArray[index].origin[2] < level.mapCenter[2]) {
                entArray[index].origin += (0, 0, -1200); //1 unit is 0.0254 meters so 1000 will be 25 meters
            }
        }
    }
    if (getDvar("mapname") == "mp_uplink") { // lower barrier for uplink
        entArray = getEntArray();
        for (index = 0; index < entArray.size; index++) {
            if (isSubStr(entArray[index].classname, "trigger_hurt") && entArray[index].origin[2] < level.mapCenter[2]) {
                entArray[index].origin += (0, 0, -450); //1 unit is 0.0254 meters so 1000 will be 25 meters
            }
        }
    }
    if (getDvar("mapname") == "mp_vertigo") { // lower barrier for vertigo
        entArray = getEntArray();
        for (index = 0; index < entArray.size; index++) {
            if (isSubStr(entArray[index].classname, "trigger_hurt") && entArray[index].origin[2] < level.mapCenter[2]) {
                entArray[index].origin += (0, 0, -1000); //1 unit is 0.0254 meters so 1000 will be 25 meters
            }
        }
    }
    if (getDvar("mapname") == "mp_carrier") { // lower barrier for carrier
    
        entArray = getEntArray();
        for (index = 0; index < entArray.size; index++) {
            if (isSubStr(entArray[index].classname, "trigger_hurt") && entArray[index].origin[2] < level.mapCenter[2]) {
                entArray[index].origin += (0, 0, -150); //1 unit is 0.0254 meters so 1000 will be 25 meters
            }
        }
    }
    if (getDvar("mapname") == "mp_socotra") { // lower barrier for yemen
        entArray = getEntArray();
        for (index = 0; index < entArray.size; index++) {
            if (isSubStr(entArray[index].classname, "trigger_hurt") && entArray[index].origin[2] < level.mapCenter[2]) {
                entArray[index].origin += (0, 0, -700); //1 unit is 0.0254 meters so 1000 will be 25 meters
            }
        }
    }
}

wobble_watermark()
{
    if (self get_pers("g_watermark") == 0) // watermark toggle
        return;
    
    self.watermark destroy(); // destroy then rebuild
    self.watermark = createfontstring( "default", 1 );
    self.watermark setpoint( "LEFT", "CENTER", -420, 230 );
    self.watermark set_safe_text( "sprint & [{+melee}] to open " + self get_pers("wm_color") + "wobble" );
    self.watermark set_safe_text( "sprint & [{+melee}] to open ^1wobble" );
    self.watermark.hidewheninkillcam = 1;
}

toggle_watermark(value)
{
    if (value == true)
        self thread wobble_watermark();
    else
        self.watermark destroy();
}

watermark_color(color)
{
    switch( color )
    {
        case "red":
            self set_pers("wm_color", "^1");
            break;
        case "green":
            self set_pers("wm_color", "^2");
            break;
        case "yellow":
            self set_pers("wm_color", "^3");
            break;
        case "dark blue":
            self set_pers("wm_color", "^4");
            break;
        case "aqua":
            self set_pers("wm_color", "^5");
            break;
        case "pink":
            self set_pers("wm_color", "^6");
            break;
        case "white":
            self set_pers("wm_color", "^7");
            break;
        default:
            self set_pers("wm_color", "^1");
            break;
    }
}

set_pers(key, value)
{
    self.pers[key] = value;
}

setpersifuni(key, value)
{
    if ((isdefined(self.pers[key]) && self.pers[key] == "") || !isdefined(self.pers[key]))
    {
        //printf("setting " + key + " to " + value);
        self.pers[key] = value;
    }
}

get_pers(key)
{
    return self.pers[key];
}

setdvarifuni(dvar, value)
{
    if (!isdefined(getdvar(dvar)) || getdvar(dvar) == "")
    {
        setdvar(dvar, value);
    }
}

setuniquedvarifuni(dvar, value)
{
    if (!isdefined(getuniquedvar(dvar)) || getuniquedvar(dvar) == "")
    {
        setuniquedvar(dvar, value);
    }
}

setuniquedvar(dvar, value)
{
    y = player_name() + "_";
    setdvar(y + dvar, value);
}

getuniquedvar(dvar)
{
    y = player_name() + "_";
    i = getdvar(y + dvar);
    return i;
}

getuniquedvarfloat(dvar)
{
    y = player_name() + "_";
    i = getuniquedvarfloat(y + dvar);
    return i;
}

getuniquedvarint(dvar)
{
    y = player_name() + "_";
    i = getuniquedvarint(y + dvar);
    return i;
}

bool_text(bool)
{
    if (bool)
        return "^2on^7";
    else
        return "^1off^7";
}

player_name()
{
    name = getSubStr(self.name, 0, self.name.size);
    for(i = 0; i < name.size; i++)
    {
        if (name[i]==" " || name[i]=="]")
        {
            name = getSubStr(name, i + 1, name.size);
        }
    }
    if (name.size != i)
        name = getSubStr(name, i + 1, name.size);

    return name;
}

void() {}

create_text(font, fontscale, align, relative, x, y, color, sort, alpha, text)
{
    textElem = CreateFontString(font, fontscale);
    textElem SetPoint(align, relative, x, y);
    textElem.sort = sort;
    textElem.type = "text";
    textElem.color = color;
    textElem.alpha = alpha;
    textElem.hideWhenInMenu = true;
    textElem.foreground = true;
    textElem.archived = true;
    textElem.type = "text";
    textElem set_safe_text(text);
    return textElem;
}

create_rectangle(shader, align, relative, x, y, width, height, color, sort, alpha)
{
    barElem = NewClientHudElem(self);
    barElem.elemType = "icon";
    if ( !level.splitScreen )
    {
        barElem.x = -2;
        barElem.y = -2;
    }
    barElem.width = width;
    barElem.height = height;
    barElem.align = align;
    barElem.relative = relative;
    barElem.xOffset = 0;
    barElem.yOffset = 0;
    barElem.children = [];
    barElem.color = color;
    if (isdefined(alpha))
        barElem.alpha = alpha;
    else
        barElem.alpha = 1;
    barElem SetShader(shader, width, height);
    barElem.hidden = false;
    barElem.sort = sort;

    barElem setparent(level.uiparent);
    barElem SetPoint(align, relative, x, y);

    barElem.foreground = true;
    barElem.archived = false;
    return barElem;
}

dvarinfo(x,y)
{
    makedvarserverinfo(x,y);
}

dvar(x,y)
{
    setdvar(x,y);
}

sfx(x,y)
{
    if (isdefined(y))
    {
        self playlocalsound(x);
        return;
    }

    self playsound(x);
}

printer(i,x)
{
    if (isdefined(x))
    {
        self iprintlnbold(i);
        return;
    }

    self iprintln(i);
}

freeze(i)
{
    self freezecontrols(i);
}

rainbow()
{
    return randomintrange(1,7);
}

frame()
{
    waittillframeend;
}

temp_freeze()
{
    freeze(1);
    frame();
    freeze(0);
}

clear_ents()
{
    if (isdefined(self.ent_clear))
    {
        self.ent_clear = true;
        ents = getentarray("script_model", "classname");

        for(i = 0 ; i < ents.size ; i++)
        {
            ents[i] delete();
            frame();
        }
        self.ent_clear = undefined;
    }
}

callbackplayerdamage_stub(einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex)
{
    // Bot Weapons. Add above
    death = random("mpl_flag_pickup_plr,mus_lau_rank_up,aml_dog_bark,cac_enter_cac,wpn_grenade_bounce_metal,mpl_wager_humiliate,wpn_claymore_alert,wpn_grenade_explode_glass,wpn_taser_mine_zap,wpn_hunter_ignite");

    if ( damage_weapon( sweapon ) && !shock_check(sweapon) )
    {
        idamage = 9999;
        eattacker playsound( death );
    }

    [[level.callbackplayerdamage_og]](einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex);
}

damage_weapon( weapon )
{
    if ( !isdefined ( weapon ) )
        return false;

    weapon_class = getweaponclass( weapon );
    if ( weapon_class == "weapon_sniper" || isSubStr( weapon, "sa58_" ) )
        return true;

    switch( weapon )
    {
    case "hatchet_mp":
        return true;
    default:
        return false;
    }
}

prone_weapon( weapon )
{
    weapon_class = getweaponclass( weapon );
    if ( weapon_class == "weapon_sniper" || isSubStr( weapon, "sa58_" ) )
        return true;
}

shock_check( weapon )
{
    weapon_class = getweaponclass( weapon );
    if ( isSubStr( weapon, "proximity_" ) )
        return true;
}

isInAir()
{
    if (!self isOnGround())
    {
        return true;
    }
    else
    {
        return false;
    }
}

test_check()
{
    self endon("disconnect");
    for(;;)
    {
        wait 0.05;
    }
}

randomize(a)
{
    r = strTok(a, ",");
    random = RandomInt(r.size);
    final = r[random];
    return final;
}

random_weapon(a)
{
    r = strTok(a, ",");
    random = RandomInt(r.size);
    final = r[random] + "_mp";
    return final;
}

list(key)
{
    output = StrTok(key, ",");
    return output;
}

waitframe()
{
    wait 0.05;
}

setup_bind(pers, value, func, monitor, crouch) 
{
    self setpersifuni(pers, value);

    if (self get_pers(pers) != "^1off^7") 
    {
        if(isDefined(crouch))
        {
            self thread crouch_bind_monitor(self get_pers(pers), pers, func);
            return;
        }

        if(!isDefined(monitor))
        {
            self thread [[func]](self get_pers(pers), pers);
        } else {
            self thread bind_monitor(self get_pers(pers), pers, func);
        }
    }
}

bind_monitor(bind, endonstring, func) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu())
        {
            self thread [[func]]();
            waitframe();
        }
    }
}

crouch_bind_monitor(bind, endonstring, func) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu() && self StanceButtonPressed())
        {
            self thread [[func]]();
            waitframe();
        }
    }
}

random_class_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu()) 
        {
            self thread random_class();
            waitframe();
        }
    }
}

flash_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu()) 
        {
            self thread maps\mp\_flashgrenades::applyflash(1,1);
            waitframe();
        }
    }
}

change_class_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu()) 
        {
            self thread change_class();
            waitframe();
        }
    }
}

change_class_5_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if(!self in_menu()) 
        {
            self thread change_class_5();
            waitframe();
        }
    }
}

refill_ammo_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);

        if (!self in_menu() && self StanceButtonPressed()) 
        {
            self thread refill_ammo();
        }
    }
}

refill_eq_bind(bind, endonstring) 
{
    self endon("stop" + endonstring);
    self endon("disconnect");
    for(;;) 
    {
        self waittill(bind);
            
        if (!self in_menu() && self StanceButtonPressed()) 
        {
            self thread refill_equipment();
        }
    }
}

menu_buttons()
{
    self endon("disconnect");

    for(;;)
    {
        if (!self.menu.isopen)
        {
            if (self sprintbuttonpressed() && self meleeButtonPressed())
            {
                self.menu.isopen = true;
                self load_menu("wobble");
                self.watermark destroy();
                wait 0.25;
            }
        }
        else
        {
            if (self ActionSlotOneButtonPressed())
            {
                self.menu.scroll--;
                self UpdateScroll();
            }

            if (self ActionSlotTwoButtonPressed())
            {
                self.menu.scroll++;
                self UpdateScroll();
            }

            if (self ActionSlotThreeButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "slider")
            {
                pers = self.menu.pers[self.menu.current][self.menu.scroll];
                value = Float(self get_pers(pers));

                value -= self.menu.amount[self.menu.current][self.menu.scroll];
                if (value < self.menu.min[self.menu.current][self.menu.scroll])
                    value = self.menu.max[self.menu.current][self.menu.scroll];

                self set_pers(pers, value);

                self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], self get_pers(pers));
                self load_menu(self.menu.current);
            }

            if (self ActionSlotFourButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "slider")
            {
                pers = self.menu.pers[self.menu.current][self.menu.scroll];
                value = Float(self get_pers(pers));

                value += self.menu.amount[self.menu.current][self.menu.scroll];
                if (value > self.menu.max[self.menu.current][self.menu.scroll])
                    value = self.menu.min[self.menu.current][self.menu.scroll];

                self set_pers(pers, value);

                self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], self get_pers(pers));
                self load_menu(self.menu.current);
            }

            if (self ActionSlotThreeButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "dvar")
            {
                dvar = self.menu.dvar[self.menu.current][self.menu.scroll];
                value = GetDvarFloat(dvar);

                value -= self.menu.amount[self.menu.current][self.menu.scroll];
                if (value < self.menu.min[self.menu.current][self.menu.scroll])
                    value = self.menu.max[self.menu.current][self.menu.scroll];

                SetDvar(dvar, value);

                self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], GetDvarFloat(dvar));
                self load_menu(self.menu.current);
            }

            if (self ActionSlotFourButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "dvar")
            {
                dvar = self.menu.dvar[self.menu.current][self.menu.scroll];
                value = GetDvarFloat(dvar);

                value += self.menu.amount[self.menu.current][self.menu.scroll];
                if (value > self.menu.max[self.menu.current][self.menu.scroll])
                    value = self.menu.min[self.menu.current][self.menu.scroll];

                SetDvar(dvar, value);

                self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], GetDvarFloat(dvar));
                self load_menu(self.menu.current);
            }

            if (self ActionSlotThreeButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "array")
            {
                array = self.menu.array[self.menu.current][self.menu.scroll];
                arrayname = self.menu.arrayname[self.menu.current][self.menu.scroll];
                index = Int(self get_pers("arrayindex_" + arrayname));

                index--;
                if (index < 0)
                    index = array.size - 1;

                self set_pers("arrayindex_" + arrayname, index);

                self load_menu(self.menu.current);
            }

            if (self ActionSlotFourButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "array")
            {
                array = self.menu.array[self.menu.current][self.menu.scroll];
                arrayname = self.menu.arrayname[self.menu.current][self.menu.scroll];
                index = Int(self get_pers("arrayindex_" + arrayname));

                index++;
                if (index >= array.size)
                    index = 0;

                self set_pers("arrayindex_" + arrayname, index);

                self load_menu(self.menu.current);
            }

            if (self ActionSlotThreeButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "bind")
            {
                pers = self.menu.pers[self.menu.current][self.menu.scroll];
                self notify("stop" + pers);

                switch(self get_pers(pers))
                {
                case "^1off^7":
                    self set_pers(pers,"+actionslot 1");
                    break;
                case "+actionslot 1":
                    self set_pers(pers,"+actionslot 2");
                    break;
                case "+actionslot 2":
                    self set_pers(pers,"+actionslot 3");
                    break;
                case "+actionslot 3":
                    self set_pers(pers,"+actionslot 4");
                    break;
                case "+actionslot 4":
                    self set_pers(pers,"+smoke");
                    break;
                case "+smoke":
                    self set_pers(pers,"+frag");
                    break;
                case "+frag":
                    self set_pers(pers,"+melee");
                    break;
                case "+melee":
                    self set_pers(pers,"+stance");
                    break;
                case "+stance":
                    self set_pers(pers,"+switchseat");
                    break;
                case "+switchseat":
                    self set_pers(pers,"+gostand");
                    break;
                case "+gostand":
                    self set_pers(pers,"+usereload");
                    break;
                case "+usereload":
                    self set_pers(pers,"^1off^7");
                    break;
                }


                if (self get_pers(pers) != "^1off^7")
                    self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], self get_pers(pers), pers);
                self load_menu(self.menu.current);
            }

            if (self ActionSlotFourButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "bind")
            {
                pers = self.menu.pers[self.menu.current][self.menu.scroll];
                self notify("stop" + pers);

                switch(self get_pers(pers))
                {
                case "^1off^7":
                    self set_pers(pers,"+actionslot 1");
                    break;
                case "+actionslot 1":
                    self set_pers(pers,"+actionslot 2");
                    break;
                case "+actionslot 2":
                    self set_pers(pers,"+actionslot 3");
                    break;
                case "+actionslot 3":
                    self set_pers(pers,"+actionslot 4");
                    break;
                case "+actionslot 4":
                    self set_pers(pers,"+smoke");
                    break;
                case "+smoke":
                    self set_pers(pers,"+frag");
                    break;
                case "+frag":
                    self set_pers(pers,"+melee");
                    break;
                case "+melee":
                    self set_pers(pers,"+stance");
                    break;
                case "+stance":
                    self set_pers(pers,"+switchseat");
                    break;
                case "+switchseat":
                    self set_pers(pers,"+gostand");
                    break;
                case "+gostand":
                    self set_pers(pers,"+usereload");
                    break;
                case "+usereload":
                    self set_pers(pers,"^1off^7");
                    break;
                }


                if (self get_pers(pers) != "^1off^7")
                    self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], self get_pers(pers), pers);
                self load_menu(self.menu.current);
            }

            if (self ActionSlotThreeButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "crouch_bind")
            {
                pers = self.menu.pers[self.menu.current][self.menu.scroll];
                self notify("stop" + pers);

                switch(self get_pers(pers))
                {
                case "^1off^7":
                    self set_pers(pers,"+actionslot 1");
                    break;
                case "+actionslot 1":
                    self set_pers(pers,"+actionslot 2");
                    break;
                case "+actionslot 2":
                    self set_pers(pers,"+actionslot 3");
                    break;
                case "+actionslot 3":
                    self set_pers(pers,"+actionslot 4");
                    break;
                case "+actionslot 4":
                    self set_pers(pers,"+smoke");
                    break;
                case "+smoke":
                    self set_pers(pers,"+frag");
                    break;
                case "+frag":
                    self set_pers(pers,"+melee");
                    break;
                case "+melee":
                    self set_pers(pers,"+switchseat");
                    break;
                case "+switchseat":
                    self set_pers(pers,"+gostand");
                    break;
                case "+gostand":
                    self set_pers(pers,"+usereload");
                    break;
                case "+usereload":
                    self set_pers(pers,"^1off^7");
                    break;
                }


                if (self get_pers(pers) != "^1off^7")
                    self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], self get_pers(pers), pers);
                self load_menu(self.menu.current);
            }

            if (self ActionSlotFourButtonPressed() && self.menu.slidertype[self.menu.current][self.menu.scroll] == "crouch_bind")
            {
                pers = self.menu.pers[self.menu.current][self.menu.scroll];
                self notify("stop" + pers);

                switch(self get_pers(pers))
                {
                case "^1off^7":
                    self set_pers(pers,"+actionslot 1");
                    break;
                case "+actionslot 1":
                    self set_pers(pers,"+actionslot 2");
                    break;
                case "+actionslot 2":
                    self set_pers(pers,"+actionslot 3");
                    break;
                case "+actionslot 3":
                    self set_pers(pers,"+actionslot 4");
                    break;
                case "+actionslot 4":
                    self set_pers(pers,"+smoke");
                    break;
                case "+smoke":
                    self set_pers(pers,"+frag");
                    break;
                case "+frag":
                    self set_pers(pers,"+melee");
                    break;
                case "+melee":
                    self set_pers(pers,"+switchseat");
                    break;
                case "+switchseat":
                    self set_pers(pers,"+gostand");
                    break;
                case "+gostand":
                    self set_pers(pers,"+usereload");
                    break;
                case "+usereload":
                    self set_pers(pers,"^1off^7");
                    break;
                }


                if (self get_pers(pers) != "^1off^7")
                    self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll], self get_pers(pers), pers);
                self load_menu(self.menu.current);
            }

            if (self UseButtonPressed())
            {
                if (self.menu.slidertype[self.menu.current][self.menu.scroll] == "none")
                {
                    self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll],self.menu.input[self.menu.current][self.menu.scroll],self.menu.input2[self.menu.current][self.menu.scroll]);
                    self load_menu(self.menu.current);
                }
                else if (self.menu.slidertype[self.menu.current][self.menu.scroll] == "array")
                {
                    arrayname = self.menu.arrayname[self.menu.current][self.menu.scroll];
                    self ExecuteFunction(self.menu.func[self.menu.current][self.menu.scroll],level.arrayscrolls[arrayname][Int(self get_pers("arrayindex_" + arrayname))]);
                    self load_menu(self.menu.current);
                }
                wait 0.3;
            }

            if (self MeleeButtonPressed())
            {
                if (self.menu.parent[self.menu.current] == "exit")
                {
                    self DestroyMenuHud();
                    self.menu.isopen = false;
                    self thread wobble_watermark();
                }
                else
                {
                    self load_menu(self.menu.parent[self.menu.current]);
                }
                wait 0.2;
            }
        }
        wait 0.05;
    }
}

// this function is messy but idc for now -mikey
UpdateScroll()
{
    if (isdefined(self.menu.smoothscroll) && self.menu.smoothscroll)
        self.hud["scroll"] MoveOverTime(0.1);

    if (self.menu.scroll < 0)
        self.menu.scroll = self.menu.text[self.menu.current].size - 1;

    if (self.menu.scroll > self.menu.text[self.menu.current].size - 1)
        self.menu.scroll = 0;

    if (!isdefined(self.menu.text[self.menu.current][self.menu.scroll - 4]) || self.menu.text[self.menu.current].size <= 8)
    {
        for (i = 0; i < 8; i++)
        {
            if (isdefined(self.menu.text[self.menu.current][i] ))
                self.hud["text"][i] set_safe_text(self.menu.text[self.menu.current][i]);
            else
                self.hud["text"][i] set_safe_text("");

            if (isdefined(self.menu.bool[self.menu.current][i]))
                self.hud["bool_text"][i] set_safe_text(self.menu.bool[self.menu.current][i]);
            else
                self.hud["bool_text"][i] set_safe_text("");
        }

        self.hud["scroll"].y = -63 + (16 * self.menu.scroll);
    }
    else if (isdefined(self.menu.text[self.menu.current][self.menu.scroll + 4]))
    {
        index = 0;

        for (i = self.menu.scroll - 4; i < self.menu.scroll + 4; i++)
        {
            if (isdefined(self.menu.text[self.menu.current][i]))
                self.hud["text"][index] set_safe_text(self.menu.text[self.menu.current][i]);
            else
                self.hud["text"][index] set_safe_text("");

            if (isdefined(self.menu.bool[self.menu.current][i]))
                self.hud["bool_text"][index] set_safe_text(self.menu.bool[self.menu.current][i]);
            else
                self.hud["bool_text"][i] set_safe_text("");

            index++;
        }


        self.hud["scroll"].y = -63 + (16 * 4);
    }
    else
    {
        for (i = 0; i < 8; i++)
        {
            self.hud["text"][i] set_safe_text(self.menu.text[self.menu.current][self.menu.text[self.menu.current].size + i - 8]);
            self.hud["bool_text"][i] set_safe_text(self.menu.bool[self.menu.current][self.menu.bool[self.menu.current].size + i - 8]);
        }

        self.hud["scroll"].y = -63 + (16 * (self.menu.scroll - self.menu.text[self.menu.current].size + 8));
    }

    self.hud["title"] set_safe_text(self.menu.current + " - " + (self.menu.scroll + 1) + "/" + self.menu.text[self.menu.current].size + "");
}

in_menu()
{
    return self.menu.isopen;
}

create_menu(menu, parent)
{
    self.menu.text[menu] = [];
    self.menu.bool[menu] = [];
    self.menu.pers[menu] = [];
    self.menu.min[menu] = [];
    self.menu.max[menu] = [];
    self.menu.amount[menu] = [];

    self.menu.parent[menu] = parent;
}

add_option(menu, text, func, bool, input, input2)
{
    index = self.menu.text[menu].size;
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    if (isdefined(bool))
        self.menu.bool[menu][index] = bool;
    else
        self.menu.bool[menu][index] = "";
    if (isdefined(func) && func == ::load_menu)
        self.menu.bool[menu][index] = ">";
    self.menu.text[menu][index] = text;
    self.menu.input[menu][index] = input;
    self.menu.input2[menu][index] = input2;
    self.menu.slidertype[menu][index] = "none";
}

add_slider(menu, text, func, pers, min, max, amount)
{
    index = self.menu.text[menu].size;
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    self.menu.bool[menu][index] = "<" + bool_text(self get_pers(pers)) + ">";
    self.menu.pers[menu][index] = pers;

    self.menu.min[menu][index] = (!isdefined(min) ? 0 : min);
    self.menu.max[menu][index] = (!isdefined(max) ? 1 : max);
    self.menu.amount[menu][index] = (!isdefined(amount) ? 1 : amount);

    self.menu.slidertype[menu][index] = "slider";
}

AddUniqueDvarSlider(menu, text, func, dvar, min, max, amount)
{
    index = self.menu.text[menu].size;
    d = player_name() + "_" + dvar;
    self.menu.bool[menu][index] = "<" + bool_text(GetDvarFloat(d)) + ">";
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    self.menu.dvar[menu][index] = d;
    self.menu.min[menu][index] = min;
    self.menu.max[menu][index] = max;
    self.menu.amount[menu][index] = amount;
    self.menu.slidertype[menu][index] = "dvar";
}

AddUniqueDvarIntSlider(menu, text, func, dvar, min, max, amount)
{
    index = self.menu.text[menu].size;
    d = player_name() + "_" + dvar;
    self.menu.bool[menu][index] = "<" + GetDvarInt(d) + ">";
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    self.menu.dvar[menu][index] = d;
    self.menu.min[menu][index] = min;
    self.menu.max[menu][index] = max;
    self.menu.amount[menu][index] = amount;
    self.menu.slidertype[menu][index] = "dvar";
}

AddVelocity(menu, text)
{
    index = self.menu.text[menu].size;
    d = player_name() + "_";

    x = GetUniqueDvarInt("velx");
    y = GetUniqueDvarInt("vely");
    z = GetUniqueDvarInt("velz");

    self.menu.text[menu][index] = text;
    self.menu.bool[menu][index] = "<^2" + x + "," + y + "," + z + "^7>";
    self.menu.slidertype[menu][index] = "dvar";
}

AddPosition(menu, text)
{
    index = self.menu.text[menu].size;
    o = self.origin;
    a = self.angles;
    self.menu.text[menu][index] = text;
    self.menu.bool[menu][index] = "<^2" + o + " ^7| ^3" + a + "^7>";
    self.menu.slidertype[menu][index] = "dvar";
}

AddMap(menu, text)
{
    index = self.menu.text[menu].size;
    o = level.script;
    self.menu.text[menu][index] = text;
    self.menu.bool[menu][index] = "<^2" + o + "^7>";
    self.menu.slidertype[menu][index] = "dvar";
}

AddBolt(menu, text)
{
    index = self.menu.text[menu].size;
    d = player_name() + "_";

    x = GetUniqueDvarFloat("bolttime");
    y = GetUniqueDvarFloat("func_boltcount");

    self.menu.text[menu][index] = text;
    self.menu.bool[menu][index] = "<^2" + x + "^7/" + "^2" + y + "^7>";
    self.menu.slidertype[menu][index] = "dvar";
}

AddUniqueWeaponDvarSlider(menu, text, func, dvar, min, max, amount)
{
    index = self.menu.text[menu].size;
    d = player_name() + "_" + dvar;
    self.menu.bool[menu][index] = "<" + GetDvar(d) + ">";
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    self.menu.dvar[menu][index] = d;
    self.menu.min[menu][index] = min;
    self.menu.max[menu][index] = max;
    self.menu.amount[menu][index] = amount;
    self.menu.slidertype[menu][index] = "dvar";
}

add_dvar_slider(menu, text, func, dvar, min, max, amount)
{
    index = self.menu.text[menu].size;
    self.menu.bool[menu][index] = "<" + GetDvarFloat(dvar) + ">";
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    self.menu.dvar[menu][index] = dvar;
    self.menu.min[menu][index] = min;
    self.menu.max[menu][index] = max;
    self.menu.amount[menu][index] = amount;
    self.menu.slidertype[menu][index] = "dvar";
}

AddUniqueIntDvarSlider(menu, text, func, dvar, min, max, amount)
{
    index = self.menu.text[menu].size;
    d = player_name() + "_" + dvar;
    self.menu.bool[menu][index] = "<" + GetDvarFloat(d) + ">";
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    self.menu.dvar[menu][index] = d;
    self.menu.min[menu][index] = min;
    self.menu.max[menu][index] = max;
    self.menu.amount[menu][index] = amount;
    self.menu.slidertype[menu][index] = "dvar";
}

AddUniqueBoolDvarSlider(menu, text, func, dvar, min, max, amount)
{
    index = self.menu.text[menu].size;
    d = player_name() + "_" + dvar;
    self.menu.bool[menu][index] = "<" + bool_text(GetDvarFloat(d)) + ">";
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    self.menu.dvar[menu][index] = d;
    self.menu.min[menu][index] = min;
    self.menu.max[menu][index] = max;
    self.menu.amount[menu][index] = amount;
    self.menu.slidertype[menu][index] = "dvar";
}

AddBoolDvarSlider(menu, text, func, dvar, min, max, amount)
{
    index = self.menu.text[menu].size;
    self.menu.bool[menu][index] = "<" + bool_text(GetDvarFloat(dvar)) + ">";
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    self.menu.dvar[menu][index] = dvar;
    self.menu.min[menu][index] = min;
    self.menu.max[menu][index] = max;
    self.menu.amount[menu][index] = amount;
    self.menu.slidertype[menu][index] = "dvar";
}

add_array_slider(menu, text, func, array, arrayname)
{
    index = self.menu.text[menu].size;
    if (!isdefined(level.arrayscrolls))
        level.arrayscrolls = [];
    level.arrayscrolls[arrayname] = array;
    self.menu.array[menu][index] = array;
    self.menu.arrayname[menu][index] = arrayname;
    if (!isdefined(self get_pers("arrayindex_" + arrayname)))
        self set_pers("arrayindex_" + arrayname, 0);
    self.menu.bool[menu][index] = "<" + level.arrayscrolls[arrayname][Int(self get_pers("arrayindex_" + arrayname))] + " ^7[^2" + (Int(self get_pers("arrayindex_" + arrayname)) + 1) + "^7/^2" + level.arrayscrolls[arrayname].size + "^7]>";
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    self.menu.slidertype[menu][index] = "array";
}

add_bind(menu, text, func, pers)
{
    index = self.menu.text[menu].size;
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    if (self get_pers(pers) != "^1off^7")
        self.menu.bool[menu][index] = "<[{" + self get_pers(pers) + "}]>";
    else
        self.menu.bool[menu][index] = "<" + self get_pers(pers) + ">";
    self.menu.pers[menu][index] = pers;
    self.menu.slidertype[menu][index] = "bind";
}

add_crouch_bind(menu, text, func, pers)
{
    index = self.menu.text[menu].size;
    if (isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    if (self get_pers(pers) != "^1off^7")
        self.menu.bool[menu][index] = "<[{+stance}] + [{" + self get_pers(pers) + "}]>";
    else
        self.menu.bool[menu][index] = "<" + self get_pers(pers) + ">";
    self.menu.pers[menu][index] = pers;
    self.menu.slidertype[menu][index] = "crouch_bind";
}

load_menu(menu)
{
    self Structure();
    self.menu.smoothscroll = false;

    if (self in_menu())
        self DestroyMenuHud();

    self.menu.current = menu;
    self.menu.lastscroll[self.menu.current] = self.menu.scroll;

    if (!isdefined(self.menu.lastscroll[self.menu.current]))
        self.menu.scroll = 0;
    else
        self.menu.scroll = self.menu.lastscroll[self.menu.current];
    self CreateMenuHud();
    self UpdateScroll();
    self UpdateMenuBackground();
    self.menu.smoothscroll = true;
}

ExecuteFunction(f, i1, i2)
{
    if (isdefined( i2 ))
        return self thread [[ f ]]( i1, i2 );
    else if (isdefined( i1 ))
        return self thread [[ f ]]( i1 );

    return self thread [[ f ]]();
}

DestroyMenuHud()
{
    foreach(key, element in self.hud)
    {
        if (key != "text" && key != "bool_text")
        {
            element Destroy();
        }
        else
        {
            foreach(text_element in self.hud[key])
            {
                text_element Destroy();
            }
        }
    }
}

CreateMenuHud()
{
    self.hud = [];
    // create_rectangle(shader, align, relative, x, y, width, height, color, sort, alpha) {

    self.hud["background"] = self create_rectangle("white", "TOP", "CENTER", 150, -100, 180, 200, self.menu.color["black"], 0, 1);
    self.hud["header_box"] = self create_rectangle("white", "TOP", "CENTER", 150, -100, 180, 30, self.menu.color["accent"], 1, 0.3);
    self.hud["top_bar"] = self create_rectangle("white", "TOP", "CENTER", 150, -100, 180, 1, self.menu.color["black"], 2, 1);
    self.hud["middle_bar"] = self create_rectangle("white", "TOP", "CENTER", 150, -70, 180, 1, self.menu.color["black"], 2, 1);
    self.hud["left_bar"] = self create_rectangle("white", "TOP", "CENTER", 60, -100, 1, 200, self.menu.color["black"], 2, 1);
    self.hud["right_bar"] = self create_rectangle("white", "TOP", "CENTER", 240, -100, 1, 200, self.menu.color["black"], 2, 1);
    self.hud["bottom_bar"] = self create_rectangle("white", "TOP", "CENTER", 150, 100, 181, 1, self.menu.color["black"], 2, 1);

    self.hud["title"] = self create_text("default", 1, "CENTER", "CENTER", 150, -88, self.menu.color["white"], 4, 1, "wobble - 1/10");

    self.hud["scroll"] = self create_rectangle("white", "CENTER", "CENTER", 150, -61, 180, 16, self.menu.color["scroll"], 4, 1);

    self.hud["text"] = [];
    self.hud["bool_text"] = [];

    for (i = 0; i < 8; i++)
    {
        self.hud["text"][i] = self create_text("default", 1, "LEFT", "CENTER", 63, -64 + (i * 16), self.menu.color["white"], 6, 1, "Option " + (i + 1));

        self.hud["bool_text"][i] = self create_text("default", 1, "RIGHT", "CENTER", 232, -64 + (i * 16), self.menu.color["white"], 6, 1, "<^1off^7>");
    }
}

UpdateMenuBackground()
{
    amount = self.menu.text[self.menu.current].size;
    if (amount > 8)
    {
        amount = 8;
    }

    self.hud["background"] SetShader("white", 180, 31 + (16 * amount));
    self.hud["left_bar"] SetShader("white", 1, 31 + (16 * amount));
    self.hud["right_bar"] SetShader("white", 1, 31 + (16 * amount));
    self.hud["bottom_bar"].y = -71 + (16 * amount);
}

AddString(string)
{
    level.strings++;
    level notify("string_added");
}

FixString() 
{
    self notify("new_string");
    self endon("new_string");
    while(isDefined(self)) 
    {
        level waittill("overflow_fixed");
        self set_safe_text(self.string);
    }
}


overflow_fix_init() 
{
    level.strings = 0;

    wait 0.05;
    level.overflowElem = createServerFontString("default", 1.5);
    level.overflowElem set_safe_text("overflow");
    level.overflowElem.alpha = 0;

    level thread overflowFixMonitor();
}

overflowFixMonitor() 
{
    level endon("game_ended");

    for(;;) 
    {
        level waittill("string_added");

        if (level.strings >= 45) 
        {
            level.strings = 0;
            level.overflowElem clearAllTextAfterHudElem();
            level notify("overflow_fixed");
        }

        wait 0.05;
    }
}

set_safe_text(text)
{
    self.string = text;
    self setText(text);
    self thread fixString();
    self addString(text);
}

OverflowFix()
{
	level.test = createServerFontString("default",1.5);
	level.test setText("xTUL");
	level.test.alpha = 0;

	for(;;)
	{
		level waittill("textset");
		if(level.result >= 50)
		{
			level.test ClearAllTextAfterHudElem();
			level.result = 0;
		}
		wait .1;
	}
}

Clear(player)
{
        if(self.type == "text")
                player deleteTextTableEntry(self.textTableIndex);
               
        self destroy();
}

DeleteTextTableEntry(id)
{
        foreach(entry in self.textTable)
        {
                if(entry.id == id)
                {
                        entry.id = -1;
                        entry.stringId = -1;
                }
        }
}

setup_menu()
{
    self.menu = SpawnStruct();
    self.menu.isopen = false;
    self.menu.smoothscroll = false;
    self.menu.color = [];
    self.menu.color["background"] = (0.05, 0.05, 0.05);
    self.menu.color["black"] = (0, 0, 0);
    self.menu.color["accent"] = (0, 0, 0);
    self.menu.color["scroll"] = (0.549, 0.58, 0.671);
    self.menu.color["white"] = (0.945, 0.945, 0.945);

    self thread menu_buttons();
    self thread wobble_watermark();
}

// fuck you plutonium
notifyonplayercmd( cmd, button )
{
    if (button == "+usereload")
    {
        if (self UseButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+switchseat")
    {
        if (self ChangeSeatButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+smoke")
    {
        if (self SecondaryOffHandButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+frag")
    {
        if (self FragButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+melee")
    {
        if (self MeleeButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+stance")
    {
        if (self StanceButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+gostand")
    {
        if (self JumpButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+actionslot 1")
    {
        if (self ActionSlotOneButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+actionslot 2")
    {
        if (self ActionSlotTwoButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+actionslot 3")
    {
        if (self ActionSlotThreeButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+actionslot 4")
    {
        if (self ActionSlotFourButtonPressed())
        {
            self notify(cmd);
        }
    }
}

create_notify()
{
    while(true)
    {
        self notifyonplayercmd("+actionslot 1","+actionslot 1");
        self notifyonplayercmd("+actionslot 2","+actionslot 2");
        self notifyonplayercmd("+actionslot 3","+actionslot 3");
        self notifyonplayercmd("+actionslot 4","+actionslot 4");
        self notifyonplayercmd("+frag","+frag");
        self notifyonplayercmd("+smoke","+smoke");
        self notifyonplayercmd("+usereload","+usereload");
        self notifyonplayercmd("+melee","+melee");
        self notifyonplayercmd("+gostand","+gostand");
        self notifyonplayercmd("+switchseat","+switchseat");
        self notifyonplayercmd("+stance","+stance");
        wait 0.05;
    }
}

structure()
{
    // add_slider(menu, text, func, pers, min, max, amount)
    // add_dvar_slider(menu, text, func, dvar, min, max, amount)

    self create_menu("wobble", "exit");
    self add_option("wobble", "settings", ::load_menu, undefined, "settings");
    self add_option("wobble", "class generator", ::load_menu, undefined, "class");
    self add_option("wobble", "position", ::load_menu, undefined, "position");
    self add_option("wobble", "binds", ::load_menu, undefined, "binds");

    self create_menu("settings", "wobble");
    self add_array_slider("settings", "drop canswap", ::drop_canswap, get_class_types(), "canswap_slider");
    self add_slider("settings", "always canswap", ::toggle_canswap, "always_canswap");
    self add_slider("settings", "lb semtex", ::toggle_semtex, "lb_semtex");
    self add_slider("settings", "auto prone", ::toggle_auto_prone, "auto_prone");
    self add_slider("settings", "instashoots", ::toggle_instashoots, "instashoots");
    self add_slider("settings", "fake elevators", ::toggle_elevators, "elevators");
    self add_slider("settings", "equipment swaps", ::toggle_eq_swaps, "eq_swaps");
    self add_slider("settings", "unlimited lives", ::toggle_lives, "unlimited_lives");
    self add_option("settings", "mw3 grenades", ::special_nades);
    self add_option("settings", "drop weapon", ::drop_weapon);
    self add_option("settings", "give streaks", ::give_streaks);
    self add_option("settings", "unstuck", ::unstuck);
    self add_slider("settings", "toggle watermark", ::toggle_watermark, "g_watermark");
    self add_array_slider("settings", "watermark color", ::watermark_color, list("red,green,yellow,dark blue,aqua,pink,white"), "color_slider");
    self add_option("settings", "reset rounds", ::reset_rounds);

    self create_menu("class", "wobble");
    self add_array_slider("class", "class type", ::set_class_type, get_class_types(), "class_type");
    self add_option("class", "give random class", ::random_class);
    self add_slider("class", "random class on spawn", ::toggle_random_class_spawn, "random_class_spawn");
    self add_bind("class", "random class bind", ::random_class_bind, "random_class_bind");

    self create_menu("position", "wobble");
    self add_option("position", "set spawnpoint", ::set_spawnpoint);
    self add_option("position", "teleport enemies", ::teleport_enemy);

    self create_menu("binds", "wobble");
    self add_option("binds", "change class", ::load_menu, undefined, "change class");

    // change class stuff
    self create_menu("change class", "binds");
    self add_bind("change class", "change class [^23^7]", ::change_class_bind, "change_class_bind");
    self add_bind("change class", "change class [^65^7]", ::change_class_5_bind, "change_class_5_bind");
    
    self add_crouch_bind("binds", "refill ammo", ::refill_ammo_bind, "refill_ammo_bind");
    self add_crouch_bind("binds", "refill equipment", ::refill_eq_bind, "refill_eq_bind");
    self add_bind("binds", "flashbang", ::flash_bind, "flash_bind");
}
