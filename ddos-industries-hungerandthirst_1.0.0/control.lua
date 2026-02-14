local survival = require("scripts.survival")

script.on_init(survival.on_init)
script.on_nth_tick(60, survival.update)
script.on_nth_tick(6000, survival.breed_fish)
script.on_event(defines.events.on_player_used_capsule, survival.on_player_used_capsule)
script.on_event(defines.events.on_player_created, function(event) survival.init_player(event.player_index) end)
script.on_event(defines.events.on_player_respawned, function(event) survival.reset_player(event.player_index) end)
script.on_configuration_changed(function() survival.update() end)

remote.add_interface("hunger", {
    seed_fish = function()
        local surface = game.surfaces[1]
        if not surface then return end
        local fishes = surface.find_entities_filtered{type="fish", name="fish"}
        for _, fish in pairs(fishes) do
            if math.random() < 0.3 then
                local pos = fish.position
                local new_name = (math.random() < 0.5) and "cod" or "salmon"
                fish.destroy()
                surface.create_entity{name=new_name, position=pos}
            end
        end
    end
})