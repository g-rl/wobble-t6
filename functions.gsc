#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\utility;

spawn_enemy()
{
    if (getDvarInt("spawned_bots") == 0)
    {
        wait 1.5;
        self thread maps\mp\bots\_bot::spawn_bot( "autoassign" );
    }
}

teleport_enemy( player )
{
    foreach (bot in level.players)
    {
        if(self.pers["team"] != bot.pers["team"])
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

toggle_canswap()
{
    if (!isDefined(self.always_canswap))
    {
        self thread always_canswap();
        self.always_canswap = true;
        self set_pers("always_canswap", true);
    } else {
        self.always_canswap = undefined;
        self set_pers("always_canswap", false);
        self notify("stop_canswap");
    }
}

always_canswap()
{
    self endon("stop_canswap");

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
    if (!level.hardcoremode)
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

        if (offhand != "none")
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

toggle_semtex()
{
    if (!isDefined(self.lb_semtex))
    {
        self thread lb_semtex();
        self thread semtex();
        self.lb_semtex = true;
        self set_pers("lb_semtex", true);
    } else {
        self.lb_semtex = undefined;
        self set_pers("lb_semtex", false);
        self notify("stop_semtex");
    }
}

lb_semtex()
{
    self endon( "stop_semtex" );

    for (;;)
    {
        self waittill( "changed_class" );
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

    smgat = randomize("+sf,+reflex,+silencer,+fmj,+fastads,+dualclip");
    arat = randomize("+mms,+gl,+fastads,+dualclip,+reflex");
    shotgunat = randomize("+extbarrel,+silencer,+fastads,+reflex");
    lmgat = randomize("+ir,+stalker");
    sniperat = randomize("+ir,+dualclip,+silencer,+acog,+vzoom,+steadyaim,+swayreduc,+ir+dualclip");

    switch( value )
    {
       case "smg":
             self drop_item(smg+smgat);
             break;
       case "ar":
             self drop_item(ar+arat);
             break;
       case "lmg":
             self drop_item(lmg+lmgat);
             break;
       case "shotgun":
             self drop_item(shotgun+shotgunat);
             break;
       case "sniper":
             self drop_item(sniper+sniperat);
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
    self GiveWeapon(weapon);
    self GiveMaxAmmo(weapon);
    self DropItem(weapon);
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

reset_rounds() 
{
    self iPrintLnBold("^2reset scores");
    level waittill("game_ended");
    game["roundsWon"]["axis"] = 0;
    game["roundsWon"]["allies"] = 0;
    game["roundsplayed"] = 0;
    game["teamScores"]["allies"] = 0;
    game["teamScores"]["axis"] = 0;
}