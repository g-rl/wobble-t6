#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\utility;

pers_memory()
{
    if(self is_bot())
        return;

    if (self get_pers("random_class_spawn") == true) 
        self thread random_class();

    if (self get_pers("instashoots") == true) 
        self thread instashoots();

    if (self get_pers("always_canswap") == true)
        self thread always_canswap();

    if (self get_pers("auto_prone") == true)
        self thread auto_prone();

    if (self get_pers("elevators") == true)
        self thread elevators();

    if (self get_pers("eq_swaps") == true)
        self thread eq_swap_loop();

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

    for(;;)
    {
        self waittill("grenade_pullback", grenade);

        if (maps\mp\killstreaks\_killstreaks::iskillstreakweapon(grenade)) // so you can still pull out streaks lol
            continue;

        self switchto(self getprevweapon());
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
        // type = "radar_mp";
        // killstreak_id = self maps\mp\killstreaks\_killstreakrules::killstreakstart(type, self.team);
        // self maps\mp\killstreaks\_spyplane::callsatellite(type, 0, killstreak_id);
        self maps\mp\killstreaks\_spyplane::callsatellite(type);
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

/*
    class generator
*/
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