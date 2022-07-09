
mobs:register_mob("tmw_slimes_piezo:uber_slime", {
	type = "npc",
	passive = false,
	attack_animals = false,
	attack_npcs = false,
	attack_monsters = true,
	attack_type = "dogfight",
	reach = 4,
	damage = 10,
	hp_min = 60,
	hp_max = 60,
	armor = 50,
	collisionbox = {-1.25, -0.01, -1.25, 1.25, 4.25, 1.25},
	visual_size = {x = 4, y = 4},
	stepheight = 1.5,
	visual = "mesh",
	mesh = "slime_uber.b3d",
	blood_texture = "tmw_slime_goo.png^[colorize:"..tmw_slimes_piezo.colors["uber"],
	textures = {
		{"tmw_slime_goo_block.png^[colorize:"..tmw_slimes_piezo.colors["uber"].."^[colorize:#FFF:96","tmw_slime_goo_block.png^[colorize:"..tmw_slimes_piezo.colors["uber"]},
	},
	makes_footstep_sound = false,
	walk_velocity = 0.5,
	run_velocity = 1.25,
	jump_height = 15,
	jump = true,
	view_range = 24,
	drops = {
		{name = "tmw_slimes_piezo:algae_goo", chance = 1, min = 0, max = 1},
		{name = "tmw_slimes_piezo:alien_goo", chance = 1, min = 0, max = 1},
		{name = "tmw_slimes_piezo:cloud_goo", chance = 1, min = 0, max = 1},
		{name = "tmw_slimes_piezo:dark_goo", chance = 1, min = 0, max = 1},
		{name = "tmw_slimes_piezo:icy_goo", chance = 1, min = 0, max = 1},
		{name = "tmw_slimes_piezo:jungle_goo", chance = 1, min = 0, max = 1},
		{name = "tmw_slimes_piezo:lava_goo", chance = 1, min = 0, max = 1},
		{name = "tmw_slimes_piezo:mineral_goo", chance = 1, min = 0, max = 1},
		{name = "tmw_slimes_piezo:ocean_goo", chance = 1, min = 0, max = 1},
		{name = "tmw_slimes_piezo:poisonous_goo", chance = 1, min = 0, max = 1},
		{name = "tmw_slimes_piezo:savannah_goo", chance = 1, min = 0, max = 1},
		{name = "tmw_slimes_piezo:live_nucleus", chance = 1, min = 0, max = 1},
		
	},
	fall_damage = 0,
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	animation = {
		idle_start = 0,
		idle_end = 20,
		move_start = 21,
		move_end = 41,
		fall_start = 63,
		fall_end = 83,
		jump_start = 42,
		jump_end = 62
	},
	do_custom = function(self, dtime)
		if not self.particle_spawner_dt or self.particle_spawner_dt > 4 then
			minetest.add_particlespawner({
				amount = 12,
				time = 4,
				minpos = {x=-1.5, y=0, z=-1.5},
				maxpos = {x=1.5,  y=5, z=1.5},
				minvel = {x=0, y=0, z=0},
				maxvel = {x=0, y=0.1, z=0},
				minacc = {x=0, y=0, z=0},
				maxacc = {x=0, y=0, z=0},
				minexptime = 2,
				maxexptime = 2,
				minsize = 1,
				maxsize = 1.5,
				collisiondetection = false,
				collisionremoval = false,
				attached = self.object,
				texture = "uber_slime_particle.png^[colorize:"..tmw_slimes_piezo.colors["uber"].."^[colorize:#FFF:96"
			})
			self.particle_spawner_dt = 0
			self.health = math.min(self.object:get_hp()+math.random(1,6),60) -- Regenerate health
		end
		self.particle_spawner_dt = self.particle_spawner_dt + dtime
		
		tmw_slimes_piezo.uber_slime_anim(self)
		
		
		if self.driver then
			local player = self.driver
			if player:is_player() and player:get_attach("parent") == self.object and 
				not (
					player:get_player_control().RMB and 
					(math.pi/4) < player:get_look_vertical()) 
			then
				self.blast_dt = self.blast_dt or 1.1
				if self.blast_dt > 1 and player:get_player_control().aux1 then
					tmw_slimes_piezo.uber_slime_blast(self)
					self.blast_dt = 0
				end
				self.blast_dt = self.blast_dt + dtime
				
				mobs.drive(self, "", "", false, dtime)
				return false
			else
				mobs.detach(player, {x = 1, y = 0, z = 1})
			end
		end

		return true
	end,
	on_die = function(self, pos)
		if self.driver then
			mobs.detach(self.driver, {x = 0, y = 0, z = 0})
		end
	end,
	after_activate = function(self)
		self.health = 60
		self.v = 0
		self.max_speed_forward = 7
		self.max_speed_reverse = 7
		self.accel = 3
		self.driver_attach_at = {x = 0, y = 11, z = -0.5}
		self.driver_eye_offset = {x = 0, y = 40, z = 0}
		self.driver_scale = {y=0.25,x=0.25}
	end,
	on_rightclick = function(self, clicker)
		
		if self.owner == clicker:get_player_name() then
			if self.driver and clicker == self.driver then

				mobs.detach(clicker, {x = 1, y = 0, z = 1})
				return
			elseif not (self.driver or clicker:get_player_control().sneak) then
				mobs.attach(self, clicker)
				return
			end
		end
		
		mobs:capture_mob(self, clicker, 100, 100, 100, false, nil)
	end
})

minetest.register_entity("tmw_slimes_piezo:blast", {
	textures = {"default_wood.png^[colorize:#0000:255"},
	hp_max = 1,
	collisionbox = {-0.33, -0.33, -0.33, 0.33, 0.33, 0.33},
	static_save = false,
	physical = true,
	on_activate = function(self)
		self.dt = 0
		self.hits = 8
	end,
	on_step = function(self, dtime)
		self.dt = self.dt + dtime
		if self.dt < 0.5 then
			return
		end
		self.hits = self.hits - 1
		self.dt = 0
		local player = minetest.get_player_by_name(self.player)
		if not player then return end
		local pos = self.object:get_pos()
		for _,ent in pairs(minetest.get_objects_inside_radius(pos, 4)) do
			if ent:is_player() and ent ~= player then
				ent:punch(player, nil, {damage_groups={fleshy=4}}, nil)
			else
				local luaent = ent:get_luaentity()
				if luaent and 
					luaent._cmi_is_mob and 
					luaent.name ~= "tmw_slimes_piezo:uber_slime"
				then
					ent:punch(player, nil, {damage_groups={fleshy=4}}, nil)
				end
			end 
		end
		if self.hits <= 0 then 
			self.object:remove()
		end
	end
})

tmw_slimes_piezo.uber_slime_blast = function(ent)
	local yaw = ent.object:get_yaw()
	local epos = ent.object:get_pos()
	local pos = {x=epos.x+2*math.sin(-yaw),y=epos.y+3,z=epos.z+2*math.cos(-yaw)}
	local ent_vel = ent.object:get_velocity()
	local vel = {x=ent_vel.x+9*math.sin(-yaw),y=ent_vel.y,z=ent_vel.z+9*math.cos(-yaw)}
	local blast = minetest.add_entity(pos, "tmw_slimes_piezo:blast")
	blast:set_velocity(vel)
	blast:get_luaentity().player = ent.driver and ent.driver:get_player_name() or ""
	minetest.sound_play("item_slurp", {pos = pos, max_hear_distance = 10, gain = 0.7})
	minetest.add_particlespawner({
		amount = 64,
		time = 4,
		minpos = {x=0,y=0,z=0},
		maxpos = {x=0,y=0,z=0},
		minvel = {x=-1.3, y=-1.3, z=-1.3},
		maxvel = {x=1.3, y=1.3, z=1.3},
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 2,
		maxexptime = 2,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		collisionremoval = false,
		texture = "tmw_slime_goo.png^[colorize:"..tmw_slimes_piezo.colors["uber"],
		attached = blast,
		glow = 5
	})
	
end

tmw_slimes_piezo.uber_slime_anim = function(ent)
	if not (ent and minetest.registered_entities[ent.name] and ent.object) then return end
	local pos = ent.object:get_pos()
	local velocity = ent.object:get_velocity()
	local is_liquid_below = ((minetest.registered_nodes[minetest.get_node({x=pos.x,y=pos.y-0.5,z=pos.z}).name] or {liquidtype = "none"}).liquidtype == "none")
	if velocity.y ~= 0 then
		if is_liquid_below and (math.abs(velocity.x) > math.abs(velocity.y) or math.abs(velocity.z) > math.abs(velocity.y)) then
			mobs:set_animation(ent, "move")
			return
		end
		if velocity.y > 0 then
			mobs:set_animation(ent, "jump")
			return
		else
			mobs:set_animation(ent, "fall")
			return
		end
	end
	if velocity.x ~= 0 or velocity.z ~= 0 then
		mobs:set_animation(ent, "move")
		return
	end
	mobs:set_animation(ent, "idle")
end


mobs:register_egg("tmw_slimes_piezo:uber_slime", "Über-Slime", "uber_slime.png^[colorize:"..tmw_slimes_piezo.colors["uber"], 0)

minetest.register_craft({
	output = "tmw_slimes_piezo:uber_slime",
	type = "shapeless",
	recipe = {
		"tmw_slimes_piezo:algae_goo_block",
		(minetest.get_modpath("other_worlds") and "tmw_slimes_piezo:alien_goo_block" or "default:mese_crystal"),
		"tmw_slimes_piezo:cloud_goo_block",
		"tmw_slimes_piezo:poisonous_goo_block",
		"tmw_slimes_piezo:live_nucleus",
		"tmw_slimes_piezo:icy_goo_block",
		"tmw_slimes_piezo:jungle_goo_block",
		"tmw_slimes_piezo:dark_goo_block",
		"tmw_slimes_piezo:savannah_goo_block",
	}
})