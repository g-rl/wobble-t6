#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\mp\menu\_menuutils;
#include scripts\mp\utility;
#include scripts\mp\functions;

structure() 
{
    // add_slider(menu, text, func, pers, min, max, amount)
    // add_dvar_slider(menu, text, func, dvar, min, max, amount)

    self create_menu("wobble", "exit");
    self add_option("wobble", "settings", ::LoadMenu, undefined, "settings");
    self add_option("wobble", "position", ::LoadMenu, undefined, "position");
    // self add_option("wobble", "binds", ::LoadMenu, undefined, "binds");

    self create_menu("settings", "wobble");
    self add_array_slider("settings", "drop canswap", ::drop_canswap, list("smg,ar,lmg,shotgun,sniper,pistol,misc"), "canswap_slider");
    self add_slider("settings", "always canswap", ::toggle_canswap, "always_canswap");
    self add_slider("settings", "lb semtex", ::toggle_semtex, "lb_semtex");
    self add_slider("settings", "auto prone", ::toggle_auto_prone, "auto_prone");
    self add_option("settings", "mw3 grenades", ::special_nades);
    self add_option("settings", "drop weapon", ::drop_weapon);
    self add_option("settings", "give streaks", ::give_streaks);
    self add_option("settings", "reset rounds", ::reset_rounds);

    self create_menu("position", "wobble");
    self add_option("position", "set spawnpoint", ::set_spawnpoint);
    self add_option("position", "teleport enemies", ::teleport_enemy);

    // self create_menu("binds", "wobble");
    // self add_option("binds", "void", ::void);
}
