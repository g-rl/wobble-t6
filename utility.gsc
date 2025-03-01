#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\functions;

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
    if(isDefined(y))
    {
        self playlocalsound(x);
        return;
    }

    self playsound(x);
}

printer(i,x)
{
    if(isDefined(x))
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

random(i)
{
    arr = strtok(i, ",");
    random = randomint(arr.size);
    final = arr[random];
    return final;
}

temp_freeze()
{
    freeze(1);
    frame();
    freeze(0);
}

clear_ents()
{
    if(isDefined(self.ent_clear))
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

damage_hook( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, boneIndex ) 
{
    death = random("mpl_flag_pickup_plr,mus_lau_rank_up,aml_dog_bark,cac_enter_cac,wpn_grenade_bounce_metal,mpl_wager_humiliate,wpn_claymore_alert,wpn_grenade_explode_glass,wpn_taser_mine_zap,wpn_hunter_ignite"); // Bot Weapons. Add above

    if ( damage_weapon( sWeapon ) && !shock_check(sWeapon) )
    {
        iDamage = 9999;
        eAttacker playsound( death );
    }

    [[level.callDamage]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, boneIndex );
}

damage_weapon( weapon ) 
{
    if ( !isDefined ( weapon ) )
        return false;
    
    weapon_class = getweaponclass( weapon );
    if ( weapon_class == "weapon_sniper" || isSubStr( weapon , "sa58_" ) ) 
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
    if ( weapon_class == "weapon_sniper" || isSubStr( weapon , "sa58_" ) ) 
        return true;
}

shock_check( weapon ) 
{
    weapon_class = getweaponclass( weapon );
    if ( isSubStr( weapon , "proximity_" ) ) 
        return true;
}

isInAir()
{
    if(!self isOnGround()) 
    {
        return true;
    } else {
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