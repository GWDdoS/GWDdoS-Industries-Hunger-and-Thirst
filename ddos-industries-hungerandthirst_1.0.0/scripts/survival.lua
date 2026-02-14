local survival = {}

function survival.on_init()
    storage.survival = {}
end

function survival.init_player(player_index)
    storage.survival = storage.survival or {}
    if not storage.survival[player_index] then
        storage.survival[player_index] = {hunger = 100, thirst = 100}
    end
end

function survival.reset_player(player_index)
    if storage.survival then
        storage.survival[player_index] = {hunger = 100, thirst = 100}
    end
end

function survival.restore_thirst(player, amount, position)
    if storage.survival and storage.survival[player.index] then
        storage.survival[player.index].thirst = math.min(100, storage.survival[player.index].thirst + amount)
        local pos = position or player.position
        player.create_local_flying_text{text="+"..amount.." Thirst", position=pos, color={r=0.2,g=0.5,b=1}}
    end
end

function survival.on_player_used_capsule(event)
    local item = event.item
    local player = game.players[event.player_index]
    
    local hunger_val = 0
    local thirst_val = 0

    if item.name == "raw-fish" or item.name == "cod" then hunger_val = 10
    elseif item.name == "salmon" then hunger_val = 15
    elseif item.name == "cooked-cod" then hunger_val = 25
    elseif item.name == "cooked-salmon" then hunger_val = 35
    elseif item.name == "filled-stone-cup" then thirst_val = 25
    end

    if hunger_val > 0 or thirst_val > 0 then
        survival.init_player(player.index)
        if storage.survival and storage.survival[player.index] then
            if hunger_val > 0 then
                storage.survival[player.index].hunger = math.min(100, storage.survival[player.index].hunger + hunger_val)
                player.create_local_flying_text{text="+"..hunger_val.." Hunger", position=player.position, color={r=0.5,g=1,b=0.5}}
            end
            if thirst_val > 0 then
                survival.restore_thirst(player, thirst_val, player.position)
            end
        end
    end
end

-- main loop to decay hunger/thirst and apply penalties
function survival.update()
    storage.survival = storage.survival or {}
    
    local hunger_decay = settings.global["ddos-hunger-decay"].value
    local thirst_decay = settings.global["ddos-thirst-decay"].value

    for _, player in pairs(game.connected_players) do
        local stats = storage.survival[player.index]
        if not stats then
            stats = {hunger = 100, thirst = 100}
            storage.survival[player.index] = stats
        end
        
        stats.hunger = math.max(0, stats.hunger - hunger_decay)
        stats.thirst = math.max(0, stats.thirst - thirst_decay)
        
        -- i want to add some more penalties or smt idk
        if player.character then
            local speed_mod = 0
            if stats.thirst < 20 then speed_mod = -0.3 end
            if stats.thirst == 0 then speed_mod = -0.6 end
            player.character_running_speed_modifier = speed_mod
            
            local mining_mod = 0
            if stats.hunger < 20 then mining_mod = -0.3 end
            if stats.hunger == 0 then mining_mod = -0.6 end
            player.character_mining_speed_modifier = mining_mod
            
            if stats.hunger == 0 or stats.thirst == 0 then
                player.character.damage(1, "neutral")
            end

            -- regen helth but use hunger 
            if stats.hunger > 80 and stats.thirst > 80 and player.character.health < player.character.max_health then
                player.character.health = player.character.health + 2
                stats.hunger = math.max(0, stats.hunger - 1.0)
                stats.thirst = math.max(0, stats.thirst - 1.0)
            end
        end
        
        -- THEN update the gui
        local gui = player.gui.top.survival_frame
        if not gui then
            gui = player.gui.top.add{type="frame", name="survival_frame", direction="vertical", caption="Survival"}
            gui.add{type="progressbar", name="hunger_bar", size=100, value=1}
            gui.add{type="progressbar", name="thirst_bar", size=100, value=1}
            gui.hunger_bar.style.color = {r=0.8, g=0.5, b=0.2}
            gui.thirst_bar.style.color = {r=0.2, g=0.5, b=0.9}
        end
        gui.hunger_bar.value = stats.hunger / 100
        gui.hunger_bar.tooltip = "Hunger: " .. math.floor(stats.hunger) .. "%"
        gui.thirst_bar.value = stats.thirst / 100
        gui.thirst_bar.tooltip = "Thirst: " .. math.floor(stats.thirst) .. "%"
    end
end

-- fish breeding but it only works on navius (i hope)
function survival.breed_fish()
    local surface = game.surfaces[1]
    if not surface then return end
    
    local breed_chance = settings.global["ddos-fish-breeding-chance"].value
    local mutation_chance = settings.global["ddos-fish-mutation-chance"].value

    local fishes = surface.find_entities_filtered{type="fish"}
    for _, fish in pairs(fishes) do
        if fish.valid and math.random() < breed_chance then
            local count = surface.count_entities_filtered{type="fish", position=fish.position, radius=4}
            if count >= 2 and count < 8 then
                local pos = {x = fish.position.x + math.random(-3,3), y = fish.position.y + math.random(-3,3)}
                
                local spawn_name = fish.name
                -- chances to mutate
                if spawn_name == "fish" then
                    local r = math.random()
                    if r < mutation_chance then spawn_name = "cod"
                    elseif r < (mutation_chance * 2) then spawn_name = "salmon"
                    end
                end

                if surface.can_place_entity{name=spawn_name, position=pos} then
                    surface.create_entity{name=spawn_name, position=pos}
                end
            end
        end
    end
end

return survival
