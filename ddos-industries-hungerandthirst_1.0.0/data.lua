local util = require("util")

local function tint_animation(animation, tint)
    if not animation then return end
    if animation.layers then
        for _, layer in pairs(animation.layers) do
            tint_animation(layer, tint)
        end
    else
        animation.tint = tint
        if animation.hr_version then
            tint_animation(animation.hr_version, tint)
        end
    end
end

if not data.raw["recipe-category"]["water-purification"] then
    data:extend({{
        type = "recipe-category",
        name = "water-purification"
    }})
end

if not data.raw["item-subgroup"]["ddos-machines"] then
    data:extend({{
        type = "item-subgroup",
        name = "ddos-machines",
        group = "production",
        order = "z"
    }})
end

if not data.raw["recipe-category"]["cup-filling"] then
    data:extend({{
        type = "recipe-category",
        name = "cup-filling"
    }})
end

local water_purifier_entity = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
water_purifier_entity.name = "water-purifier"
water_purifier_entity.minable = {mining_time = 0.5, result = "water-purifier"}
water_purifier_entity.max_health = 150
water_purifier_entity.crafting_categories = {"water-purification"}
water_purifier_entity.crafting_speed = 1
water_purifier_entity.energy_usage = "50kW"
water_purifier_entity.energy_source = {
    type = "burner",
    fuel_categories = {"chemical"},
    effectivity = 1,
    fuel_inventory_size = 1,
    emissions_per_minute = { pollution = 4 },
    smoke = {{
        name = "smoke",
        frequency = 5,
        position = {0.0, -0.8},
        starting_vertical_speed = 0.08
    }}
}
water_purifier_entity.fluid_boxes = {
    {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        volume = 1000,
        base_level = -1,
        pipe_connections = {{flow_direction = "input", position = {-1, -1.2}, direction = defines.direction.north}}
    },
    {
        production_type = "output",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        volume = 1000,
        base_level = 1,
        pipe_connections = {{flow_direction = "output", position = {1, -1.2}, direction = defines.direction.north}}
    }
}
local purifier_tint = {r=0.6, g=0.7, b=0.9}
if water_purifier_entity.graphics_set and water_purifier_entity.graphics_set.animation then
    tint_animation(water_purifier_entity.graphics_set.animation, purifier_tint)
else
    tint_animation(water_purifier_entity.animation, purifier_tint)
end

local water_purifier_item = {
    type = "item", name = "water-purifier",
    icons = {{
        icon = data.raw["assembling-machine"]["assembling-machine-1"].icon,
        icon_size = data.raw["assembling-machine"]["assembling-machine-1"].icon_size,
        tint = purifier_tint
    }},
    subgroup = "ddos-machines", order = "c-d-a",
    place_result = "water-purifier", stack_size = 50
}

local water_purifier_recipe = {
    type = "recipe", name = "water-purifier", enabled = true,
    ingredients = {
        {type = "item", name = "stone", amount = 20},
        {type = "item", name = "stone-pipe", amount = 5},
        {type = "item", name = "wood", amount = 10}
    },
    results = {{type = "item", name = "water-purifier", amount = 1}}
}

local pure_water_fluid = table.deepcopy(data.raw.fluid.water)
pure_water_fluid.name = "pure-water"
pure_water_fluid.base_color = {r=0.3, g=0.6, b=0.9}
pure_water_fluid.flow_color = {r=0.5, g=0.8, b=1.0}
pure_water_fluid.icon = "__base__/graphics/icons/fluid/water.png"
pure_water_fluid.icons = {{ icon = "__base__/graphics/icons/fluid/water.png", tint = {r=0.7, g=0.8, b=1.0} }}

local stone_cup_item = {
    type = "item", name = "stone-cup",
    icons = {{ icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png", icon_size = 64, tint = {r=0.7, g=0.7, b=0.7} }},
    subgroup = "intermediate-product", order = "z-a", stack_size = 50
}

local stone_cup_recipe = {
    type = "recipe", name = "stone-cup", enabled = true, category = "crafting",
    ingredients = {{type = "item", name = "stone", amount = 2}},
    results = {{type = "item", name = "stone-cup", amount = 1}}
}

local filled_stone_cup_item = table.deepcopy(data.raw.capsule["raw-fish"])
filled_stone_cup_item.name = "filled-stone-cup"
filled_stone_cup_item.icon = nil
filled_stone_cup_item.icon_size = nil
filled_stone_cup_item.icons = {{ icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png", icon_size = 64, tint = {r=0.6, g=0.8, b=1.0} }}
filled_stone_cup_item.subgroup = "intermediate-product"
filled_stone_cup_item.order = "z-b"
filled_stone_cup_item.stack_size = 50
filled_stone_cup_item.capsule_action.attack_parameters.ammo_type.action.action_delivery.target_effects = nil

local purify_water_recipe = {
    type = "recipe", name = "purify-water", category = "water-purification",
    enabled = true, energy_required = 2,
    ingredients = {{type = "fluid", name = "water", amount = 50}},
    results = {{type = "fluid", name = "pure-water", amount = 50}}
}

local cup_filling_plant_entity = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
cup_filling_plant_entity.name = "cup-filling-plant"
cup_filling_plant_entity.minable = {mining_time = 0.5, result = "cup-filling-plant"}
cup_filling_plant_entity.crafting_categories = {"cup-filling"}
cup_filling_plant_entity.max_health = 150
cup_filling_plant_entity.crafting_speed = 1
cup_filling_plant_entity.energy_usage = "50kW"
cup_filling_plant_entity.energy_source = table.deepcopy(water_purifier_entity.energy_source)
cup_filling_plant_entity.fluid_boxes = {
    {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        volume = 1000,
        base_level = -1,
        pipe_connections = {{flow_direction = "input", position = {0, -1.2}, direction = defines.direction.north}}
    }
}
local filling_tint = {r=0.6, g=0.9, b=0.6}
if cup_filling_plant_entity.graphics_set and cup_filling_plant_entity.graphics_set.animation then
    tint_animation(cup_filling_plant_entity.graphics_set.animation, filling_tint)
else
    tint_animation(cup_filling_plant_entity.animation, filling_tint)
end

local cup_filling_plant_item = {
    type = "item", name = "cup-filling-plant",
    icons = {{
        icon = data.raw["assembling-machine"]["assembling-machine-1"].icon,
        icon_size = data.raw["assembling-machine"]["assembling-machine-1"].icon_size,
        tint = filling_tint
    }},
    subgroup = "ddos-machines", order = "c-d-b",
    place_result = "cup-filling-plant", stack_size = 50
}

local cup_filling_plant_recipe = {
    type = "recipe", name = "cup-filling-plant", enabled = true,
    ingredients = {
        {type = "item", name = "stone", amount = 20},
        {type = "item", name = "wood", amount = 10},
        {type = "item", name = "iron-plate", amount = 5}
    },
    results = {{type = "item", name = "cup-filling-plant", amount = 1}}
}

local fill_cup_recipe = {
    type = "recipe", name = "fill-stone-cup", category = "cup-filling",
    enabled = true, energy_required = 0.5,
    ingredients = {
        {type = "item", name = "stone-cup", amount = 1},
        {type = "fluid", name = "pure-water", amount = 25}
    },
    results = {{type = "item", name = "filled-stone-cup", amount = 1}},
    main_product = "filled-stone-cup"
}

local cod_entity = table.deepcopy(data.raw["fish"]["fish"])
cod_entity.name = "cod"
cod_entity.minable.result = "cod"
if cod_entity.pictures then
    for _, pic in pairs(cod_entity.pictures) do pic.tint = {r=0.6, g=0.7, b=0.5} end
end

local cod_item = table.deepcopy(data.raw.capsule["raw-fish"])
cod_item.name = "cod"
cod_item.icons = {{icon = data.raw.capsule["raw-fish"].icon, icon_size = 64, tint = {r=0.6, g=0.7, b=0.5}}}
cod_item.place_result = "cod"

local salmon_entity = table.deepcopy(data.raw["fish"]["fish"])
salmon_entity.name = "salmon"
salmon_entity.minable.result = "salmon"
if salmon_entity.pictures then
    for _, pic in pairs(salmon_entity.pictures) do pic.tint = {r=1.0, g=0.6, b=0.6} end
end

local salmon_item = table.deepcopy(data.raw.capsule["raw-fish"])
salmon_item.name = "salmon"
salmon_item.icons = {{icon = data.raw.capsule["raw-fish"].icon, icon_size = 64, tint = {r=1.0, g=0.6, b=0.6}}}
salmon_item.place_result = "salmon"

local cooked_cod = table.deepcopy(cod_item)
cooked_cod.name = "cooked-cod"
cooked_cod.place_result = nil
cooked_cod.icons = {{icon = data.raw.capsule["raw-fish"].icon, icon_size = 64, tint = {r=0.5, g=0.4, b=0.2}}}

local cooked_salmon = table.deepcopy(salmon_item)
cooked_salmon.name = "cooked-salmon"
cooked_salmon.place_result = nil
cooked_salmon.icons = {{icon = data.raw.capsule["raw-fish"].icon, icon_size = 64, tint = {r=0.8, g=0.4, b=0.3}}}

local recipe_cod = {
    type = "recipe", name = "cooked-cod", category = "smelting",
    energy_required = 3,
    ingredients = {{type="item", name="cod", amount=1}},
    results = {{type="item", name="cooked-cod", amount=1}}
}

local recipe_salmon = {
    type = "recipe", name = "cooked-salmon", category = "smelting",
    energy_required = 3,
    ingredients = {{type="item", name="salmon", amount=1}},
    results = {{type="item", name="cooked-salmon", amount=1}}
}

data:extend({
    water_purifier_entity,
    water_purifier_item,
    water_purifier_recipe,
    pure_water_fluid,
    stone_cup_item,
    stone_cup_recipe,
    filled_stone_cup_item,
    purify_water_recipe,
    fill_cup_recipe,
    cup_filling_plant_entity,
    cup_filling_plant_item,
    cup_filling_plant_recipe,
    cod_entity, cod_item,
    salmon_entity, salmon_item,
    cooked_cod, cooked_salmon,
    recipe_cod, recipe_salmon
})