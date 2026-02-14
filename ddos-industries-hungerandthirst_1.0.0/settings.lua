data:extend({
    {
        type = "double-setting",
        name = "ddos-hunger-decay",
        setting_type = "runtime-global",
        default_value = 0.15,
        minimum_value = 0.0,
        maximum_value = 5.0,
        order = "a"
    },
    {
        type = "double-setting",
        name = "ddos-thirst-decay",
        setting_type = "runtime-global",
        default_value = 0.25,
        minimum_value = 0.0,
        maximum_value = 5.0,
        order = "b"
    },
    {
        type = "double-setting",
        name = "ddos-fish-breeding-chance",
        setting_type = "runtime-global",
        default_value = 0.10,
        minimum_value = 0.0,
        maximum_value = 1.0,
        order = "c"
    },
    {
        type = "double-setting",
        name = "ddos-fish-mutation-chance",
        setting_type = "runtime-global",
        default_value = 0.15,
        minimum_value = 0.0,
        maximum_value = 0.5,
        order = "d"
    }
})