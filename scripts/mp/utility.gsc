#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud_message;
#include maps\mp\gametypes\_hud;

// custom script includes
#include scripts\mp\functions;
#include scripts\mp\menu\_overflow;

wobble_watermark()
{
    if (self get_pers("g_watermark") == 0) // watermark toggle
        return;
    
    self.watermark destroy(); // destroy then rebuild
    self.watermark = createfontstring( "default", 1 );
    self.watermark setpoint( "LEFT", "CENTER", -420, 230 );
    self.watermark set_safe_text( "sprint & [{+melee}] to open " + self get_pers("wm_color") + "wobble" );
    self.watermark.hidewheninkillcam = 1;
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
        printf("setting " + key + " to " + value);
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