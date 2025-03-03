#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\mp\utility;
#include scripts\mp\menu\_overflow;

IsInMenu() {
    return self.menu.isopen;
}

create_menu(menu, parent) {
    self.menu.text[menu] = [];
    self.menu.bool[menu] = [];
    self.menu.parent[menu] = parent;
}

add_option(menu, text, func, bool, input, input2) {
    index = self.menu.text[menu].size;
    if(isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    if(isdefined(bool))
        self.menu.bool[menu][index] = bool;
    else
        self.menu.bool[menu][index] = "";
    if(isdefined(func) && func == ::LoadMenu)
        self.menu.bool[menu][index] = ">";
    self.menu.text[menu][index] = text;
    self.menu.input[menu][index] = input;
    self.menu.input2[menu][index] = input2;
    self.menu.slidertype[menu][index] = "none";
}

add_slider(menu, text, func, pers, min, max, amount) {
    index = self.menu.text[menu].size;
    if(isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    self.menu.bool[menu][index] = "<" + bool_text(self get_pers(pers)) + ">";
    self.menu.pers[menu][index] = pers;
    self.menu.min[menu][index] = min;
    self.menu.max[menu][index] = max;
    self.menu.amount[menu][index] = amount;
    self.menu.slidertype[menu][index] = "slider";
}

AddUniqueDvarSlider(menu, text, func, dvar, min, max, amount) {
    index = self.menu.text[menu].size;
    d = player_name() + "_" + dvar;
    self.menu.bool[menu][index] = "<" + bool_text(GetDvarFloat(d)) + ">";
    if(isdefined(func))
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

AddUniqueDvarIntSlider(menu, text, func, dvar, min, max, amount) {
    index = self.menu.text[menu].size;
    d = player_name() + "_" + dvar;
    self.menu.bool[menu][index] = "<" + GetDvarInt(d) + ">";
    if(isdefined(func))
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

AddVelocity(menu, text) {
    index = self.menu.text[menu].size;
    d = player_name() + "_";

    x = GetUniqueDvarInt("velx");
    y = GetUniqueDvarInt("vely");
    z = GetUniqueDvarInt("velz");
    
    self.menu.text[menu][index] = text;
    self.menu.bool[menu][index] = "<^2" + x + "," + y + "," + z + "^7>";
    self.menu.slidertype[menu][index] = "dvar";
}

AddPosition(menu, text) {
    index = self.menu.text[menu].size;
    o = self.origin;
    a = self.angles;
    self.menu.text[menu][index] = text;
    self.menu.bool[menu][index] = "<^2" + o + " ^7| ^3" + a + "^7>";
    self.menu.slidertype[menu][index] = "dvar";
}

AddMap(menu, text) {
    index = self.menu.text[menu].size;
    o = level.script;
    self.menu.text[menu][index] = text;
    self.menu.bool[menu][index] = "<^2" + o + "^7>";
    self.menu.slidertype[menu][index] = "dvar";
}

AddBolt(menu, text) {
    index = self.menu.text[menu].size;
    d = player_name() + "_";

    x = GetUniqueDvarFloat("bolttime");
    y = GetUniqueDvarFloat("func_boltcount");
    
    self.menu.text[menu][index] = text;
    self.menu.bool[menu][index] = "<^2" + x + "^7/" + "^2" + y + "^7>";
    self.menu.slidertype[menu][index] = "dvar";
}

AddUniqueWeaponDvarSlider(menu, text, func, dvar, min, max, amount) {
    index = self.menu.text[menu].size;
    d = player_name() + "_" + dvar;
    self.menu.bool[menu][index] = "<" + GetDvar(d) + ">";
    if(isdefined(func))
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

add_dvar_slider(menu, text, func, dvar, min, max, amount) {
    index = self.menu.text[menu].size;
    self.menu.bool[menu][index] = "<" + GetDvarFloat(dvar) + ">";
    if(isdefined(func))
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

AddUniqueIntDvarSlider(menu, text, func, dvar, min, max, amount) {
    index = self.menu.text[menu].size;
    d = player_name() + "_" + dvar;
    self.menu.bool[menu][index] = "<" + GetDvarFloat(d) + ">";
    if(isdefined(func))
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

AddUniqueBoolDvarSlider(menu, text, func, dvar, min, max, amount) {
    index = self.menu.text[menu].size;
    d = player_name() + "_" + dvar;
    self.menu.bool[menu][index] = "<" + bool_text(GetDvarFloat(d)) + ">";
    if(isdefined(func))
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

AddBoolDvarSlider(menu, text, func, dvar, min, max, amount) {
    index = self.menu.text[menu].size;
    self.menu.bool[menu][index] = "<" + bool_text(GetDvarFloat(dvar)) + ">";
    if(isdefined(func))
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

add_array_slider(menu, text, func, array, arrayname) {
    index = self.menu.text[menu].size;
    if(!isdefined(level.arrayscrolls))
        level.arrayscrolls = [];
    level.arrayscrolls[arrayname] = array;
    self.menu.array[menu][index] = array;
    self.menu.arrayname[menu][index] = arrayname;
    if(!isdefined(self get_pers("arrayindex_" + arrayname)))
        self set_pers("arrayindex_" + arrayname, 0);
    self.menu.bool[menu][index] = "<" + level.arrayscrolls[arrayname][Int(self get_pers("arrayindex_" + arrayname))] + " ^7[^2" + (Int(self get_pers("arrayindex_" + arrayname)) + 1) + "^7/^2" + level.arrayscrolls[arrayname].size + "^7]>";
    if(isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    self.menu.slidertype[menu][index] = "array";
}

AddBindSliders(menu, text, func, pers) {
    index = self.menu.text[menu].size;
    if(isdefined(func))
        self.menu.func[menu][index] = func;
    else
        self.menu.func[menu][index] = ::void;
    self.menu.text[menu][index] = text;
    if(self get_pers(pers) != "^1OFF^7")
        self.menu.bool[menu][index] = "<[{" + self get_pers(pers) + "}]>";
    else
        self.menu.bool[menu][index] = "<" + self get_pers(pers) + ">";
    self.menu.pers[menu][index] = pers;
    self.menu.slidertype[menu][index] = "bind";
}

LoadMenu(menu) {
    self scripts\mp\menu\_structure::Structure();
    self.menu.smoothscroll = false;
    self.menu.lastscroll[self.menu.current] = self.menu.scroll;
    if(self IsInMenu())
        self DestroyMenuHud();
    self.menu.current = menu;
    if(!isdefined(self.menu.lastscroll[self.menu.current]))
        self.menu.scroll = 0;
    else
        self.menu.scroll = self.menu.lastscroll[self.menu.current];
    self CreateMenuHud();
    self scripts\mp\menu\_menulogic::UpdateScroll();
    self UpdateMenuBackground();
    self.menu.smoothscroll = true;
}

ExecuteFunction(f, i1, i2) { 
    if(isdefined( i2 ))
        return self thread [[ f ]]( i1, i2 );
    else if(isdefined( i1 ))
        return self thread [[ f ]]( i1 );

    return self thread [[ f ]]();
}

DestroyMenuHud() {
    foreach(key, element in self.hud) {
        if(key != "text" && key != "bool_text") {
            element Destroy();
        }
        else {
            foreach(text_element in self.hud[key]) {
                text_element Destroy();
            }
        }
    }
}

CreateMenuHud() {
    self.hud = [];
    // create_rectangle(shader, align, relative, x, y, width, height, color, sort, alpha) {

    self.hud["background"] = self create_rectangle("white", "TOP", "CENTER", 150, -100, 180, 200, self.menu.color["black"], 0, 1);
    self.hud["header_box"] = self create_rectangle("white", "TOP", "CENTER", 150, -100, 180, 30, self.menu.color["accent"], 1, 0.3);
    self.hud["top_bar"] = self create_rectangle("white", "TOP", "CENTER", 150, -100, 180, 1, self.menu.color["black"], 2, 1);
    self.hud["middle_bar"] = self create_rectangle("white", "TOP", "CENTER", 150, -70, 180, 1, self.menu.color["black"], 2, 1);
    self.hud["left_bar"] = self create_rectangle("white", "TOP", "CENTER", 60, -100, 1, 200, self.menu.color["black"], 2, 1);
    self.hud["right_bar"] = self create_rectangle("white", "TOP", "CENTER", 240, -100, 1, 200, self.menu.color["black"], 2, 1);
    self.hud["bottom_bar"] = self create_rectangle("white", "TOP", "CENTER", 150, 100, 181, 1, self.menu.color["black"], 2, 1);

    self.hud["title"] = self create_text("hudbig", 1, "CENTER", "CENTER", 150, -88, self.menu.color["white"], 4, 1, "wobble - 1/10");

    self.hud["scroll"] = self create_rectangle("white", "CENTER", "CENTER", 150, -61, 180, 16, self.menu.color["scroll"], 4, 1);

    self.hud["text"] = [];
    self.hud["bool_text"] = [];

    for (i = 0; i < 8; i++) {
        self.hud["text"][i] = self create_text("hudbig", 1, "LEFT", "CENTER", 63, -64 + (i * 16), self.menu.color["white"], 6, 1, "Option " + (i + 1));

        self.hud["bool_text"][i] = self create_text("hudbig", 1, "RIGHT", "CENTER", 232, -64 + (i * 16), self.menu.color["white"], 6, 1, "<^1OFF^7>");
    }
}

UpdateMenuBackground() {
    amount = self.menu.text[self.menu.current].size;
    if(amount > 8) {
        amount = 8;
    }
    
    self.hud["background"] SetShader("white", 180, 31 + (16 * amount));
    self.hud["left_bar"] SetShader("white", 1, 31 + (16 * amount));
    self.hud["right_bar"] SetShader("white", 1, 31 + (16 * amount));
    self.hud["bottom_bar"].y = -71 + (16 * amount);
}