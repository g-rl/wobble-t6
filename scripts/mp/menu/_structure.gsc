#include scripts\mp\menu\_menuutils;
#include scripts\mp\utility;
#include scripts\mp\functions;
#include scripts\mp\binds;

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
    self add_slider("settings", "unlimited lives", ::toggle_lives, "unlimited_lives");
    self add_option("settings", "mw3 grenades", ::special_nades);
    self add_option("settings", "drop weapon", ::drop_weapon);
    self add_option("settings", "give streaks", ::give_streaks);
    self add_option("settings", "unstuck", ::unstuck);
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
