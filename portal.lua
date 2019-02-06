local function posin(t, e)
   for k, v in pairs(t) do
      if v.x == e.x and v.y == e.y and v.z == e.z then return true end
   end
   return false
end

local function check(pos)
   local n = minetest.get_node(pos).name
   if n == "nether:obsidian_enchanted" then
      return true
   end
end

local function allequal(a, b, c, d)
   return a == b and a == c and a == d
end

local function search(pos)
   local ptable = {}
   local inX = false
   local inY = false
   local inZ = false
   for x=-1,1 do
      if x ~= 0 then
         local pos = {x = pos.x + x, y = pos.y, z = pos.z}
         if check(pos) then
            table.insert(ptable, pos)
            inX = true
         end
      end
   end
   for y=-1,1 do
      if y ~= 0 then
         local pos = {x = pos.x, y = pos.y + y, z = pos.z}
         if check(pos) then
            table.insert(ptable, pos)
            inY = true
         end
      end
   end
   for z=-1,1 do
      if z ~= 0 then
         local pos = {x = pos.x, y = pos.y, z = pos.z + z}
         if check(pos) then
            table.insert(ptable, pos)
            inZ = true
         end
      end
   end
   local corner = (inX and inY) or (inX and inZ) or (inY and inZ)
   return ptable, corner
end

local function portalat(pos)
   -- Get surrounding obsidian
   local fullpos = {}
   local corners = {}
   local tosearch = {pos}
   local portal_pos = {}
   local index = 1
   while index <= #tosearch do
      local sPos = tosearch[index]
      local iscorner
      local valid, iscorner = search(sPos)
      -- Add neighboring blocks to the search table
      for k, v in pairs(valid) do
         if not posin(tosearch, v) then
            table.insert(tosearch, v)
         end
      end
      table.insert(fullpos, sPos)
      -- Check if sPos is a corner
      if iscorner then
         table.insert(corners, sPos)
      end
      index = index + 1
   end
   tosearch = nil
   -- Make sure there are 4 corners
   if #corners ~= 4 then return false end
   -- Make sure all the corners lay on a plane and all the pieces are in place if so
   local c1 = corners[1]
   local c2 = corners[2]
   local c3 = corners[3]
   local c4 = corners[4]
   if allequal(c1.x, c2.x, c3.x, c4.x) then
      local minZ = math.min(c1.z, c2.z, c3.z, c4.z)
      local minY = math.min(c1.y, c2.y, c3.y, c4.y)
      local maxZ = math.max(c1.z, c2.z, c3.z, c4.z)
      local maxY = math.max(c1.y, c2.y, c3.y, c4.y)
      for z = minZ, maxZ do
         local p1 = {x = c1.x, y = maxY, z = z}
         local p2 = {x = c1.x, y = minY, z = z}
         if not posin(fullpos, p1) or not posin(fullpos, p2) then
            return
         end
         table.insert(portal_pos, p1)
         table.insert(portal_pos, p2)
      end
      for y = minY, maxY do
         local p1 = {x = c1.x, y = y, z = maxZ}
         local p2 = {x = c1.x, y = y, z = minZ}
         if not posin(fullpos, p1) or not posin(fullpos, p2) then
            return
         end
         table.insert(portal_pos, p1)
         table.insert(portal_pos, p2)
      end
      local minC = {x = c1.x, y = minY + 1, z = minZ + 1}
      local maxC = {x = c1.x, y = maxY - 1, z = maxZ - 1}
      -- Make sure the rectangle has an interior
      if minC.y > maxC.y or minC.z > maxC.z then
         return
      end
      return minC, maxC, portal_pos, 1
   elseif allequal(c1.y, c2.y, c3.y, c4.y) then
      local minX = math.min(c1.x, c2.x, c3.x, c4.x)
      local minZ = math.min(c1.z, c2.z, c3.z, c4.z)
      local maxX = math.max(c1.x, c2.x, c3.x, c4.x)
      local maxZ = math.max(c1.z, c2.z, c3.z, c4.z)
      for x = minX, maxX do
         local p1 = {x = x, y = c1.y, z = maxZ}
         local p2 = {x = x, y = c1.y, z = minZ}
         if not posin(fullpos, p1) or not posin(fullpos, p2) then
            return
         end
         table.insert(portal_pos, p1)
         table.insert(portal_pos, p2)
      end
      for z = minZ, maxZ do
         local p1 = {x = maxX, y = c1.y, z = z}
         local p2 = {x = minX, y = c1.y, z = z}
         if not posin(fullpos, p1) or not posin(fullpos, p2) then
            return
         end
         table.insert(portal_pos, p1)
         table.insert(portal_pos, p2)
      end
      local minC = {x = minX + 1, y = c1.y, z = minZ + 1}
      local maxC = {x = maxX - 1, y = c1.y, z = maxZ - 1}
      -- Make sure the rectangle has an interior
      if minC.x > maxC.x or minC.z > maxC.z then
         return
      end
      return minC, maxC, portal_pos, 4
   elseif allequal(c1.z, c2.z, c3.z, c4.z) then
      local minX = math.min(c1.x, c2.x, c3.x, c4.x)
      local minY = math.min(c1.y, c2.y, c3.y, c4.y)
      local maxX = math.max(c1.x, c2.x, c3.x, c4.x)
      local maxY = math.max(c1.y, c2.y, c3.y, c4.y)
      for x = minX, maxX do
         local p1 = {x = x, y = maxY, z = c1.z}
         local p2 = {x = x, y = minY, z = c1.z}
         if not posin(fullpos, p1) or not posin(fullpos, p2) then
            return
         end
         table.insert(portal_pos, p1)
         table.insert(portal_pos, p2)
      end
      for y = minY, maxY do
         local p1 = {x = maxX, y = y, z = c1.z}
         local p2 = {x = minX, y = y, z = c1.z}
         if not posin(fullpos, p1) or not posin(fullpos, p2) then
            return
         end
         table.insert(portal_pos, p1)
         table.insert(portal_pos, p2)
      end
      local minC = {x = minX + 1, y = minY + 1, z = c1.z}
      local maxC = {x = maxX - 1, y = maxY - 1, z = c1.z}
      -- Make sure the rectangle has an interior
      if minC.x > maxC.x or minC.y > maxC.y then
         return
      end
      return minC, maxC, portal_pos, 0
   end
end

local function makeportal(minC, maxC, portal_pos, param2)
   -- Create the portal
   for x = minC.x, maxC.x do
      for y = minC.y, maxC.y do
         for z = minC.z, maxC.z do
            local pos = {x = x, y = y, z = z}
            minetest.set_node(pos, {name = "nether:portal", param2 = param2})
         end
      end
   end
   -- Update metadata for the enchanted obsidian
   local portal_str = minetest.serialize({minC, maxC, portal_pos})
   for _, pos in pairs(portal_pos) do
      local meta = minetest.get_meta(pos)
      meta:set_string("portal", portal_str)
   end
end

minetest.register_craft({
   type = "shapeless",
   output = "nether:obsidian_enchanted",
   recipe = {"default:obsidian", "default:diamond"}
})

minetest.register_node("nether:portal", {
   description = "Nether Portal (you hacker you)",
   tiles = {
		"nether_transparent.png",
		"nether_transparent.png",
		"nether_transparent.png",
		"nether_transparent.png",
		{
			name = "nether_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
		{
			name = "nether_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = true,
	walkable = false,
	diggable = false,
	pointable = false,
	buildable_to = false,
	is_ground_content = false,
	drop = "",
	light_source = 5,
	post_effect_color = {a = 180, r = 128, g = 0, b = 128},
	alpha = 192,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
   groups = {not_in_creative_inventory = 1}
})

local obsidian_def = {
   description = "Enchanted Obsidian",
   tiles = {"nether_obsidian_enchanted.png"},
   groups = {cracky = 2}
}

fuel = "default:mese"

obsidian_def.on_punch = function(pos, node, puncher, pointed_thing)
   -- Verify puncher
   if puncher == nil or not puncher:is_player() then return end
   local w = puncher:get_wielded_item()
   -- Verify wielded item
   if w:get_name() == fuel then
      w:take_item()
      puncher:set_wielded_item(w)
   else
      return
   end
   -- Check if there is a portal frame here
   local minC
   local maxC
   local portal_pos
   local param2
   minC, maxC, portal_pos, param2 = portalat(pos)
   if minC ~= nil and maxC ~= nil and portal_pos ~= nil and param2 ~= nil then
      local link_minC = {x = minC.x, y = math.random(nether_depth + 100, nether_depth + 500), z = minC.z}
      local link_maxC = {x = link_minC.x + 1, y = link_minC.y + 2, z = link_minC.z}
      local link_portal_pos = {
         {x = link_minC.x - 1, y = link_minC.y - 1, z = link_minC.z},
         {x = link_minC.x - 1, y = link_minC.y, z = link_minC.z},
         {x = link_minC.x - 1, y = link_minC.y + 1, z = link_minC.z},
         {x = link_minC.x - 1, y = link_minC.y + 2, z = link_minC.z},
         {x = link_minC.x - 1, y = link_minC.y + 3, z = link_minC.z},
         {x = link_minC.x, y = link_minC.y + 3, z = link_minC.z},
         {x = link_minC.x + 1, y = link_minC.y + 3, z = link_minC.z},
         {x = link_minC.x + 2, y = link_minC.y + 3, z = link_minC.z},
         {x = link_minC.x + 2, y = link_minC.y + 2, z = link_minC.z},
         {x = link_minC.x + 2, y = link_minC.y + 1, z = link_minC.z},
         {x = link_minC.x + 2, y = link_minC.y, z = link_minC.z},
         {x = link_minC.x + 2, y = link_minC.y - 1, z = link_minC.z},
         {x = link_minC.x + 1, y = link_minC.y + 1, z = link_minC.z},
         {x = link_minC.x, y = link_minC.y - 1, z = link_minC.z},
      }
      for _, pos in pairs(link_portal_pos) do
         minetest.set_node(pos, {name = "nether:obsidian_enchanted"})
      end
      minetest.emerge_area(
         {x = link_minC.x - 4, y = link_minC.y - 4, z = link_minC.z - 4},
         {x = link_maxC.x + 4, y = link_maxC.y + 4, z = link_maxC.z + 4})
      makeportal(minC, maxC, portal_pos, param2)
      minetest.after(3, makeportal, link_minC, link_maxC, link_portal_pos, 0)
      minetest.chat_send_all(dump(link_minC))
   end
end

obsidian_def.on_destruct = function(pos)
   -- Get portal info
   local meta = minetest.get_meta(pos)
   local portal_str = meta:get_string("portal")
   if portal_str == "" then return end
   local portal_info = minetest.deserialize(portal_str)
   if portal_info == nil then return end
   -- Remove portal nodes
   local minC = portal_info[1]
   local maxC = portal_info[2]
   for x = minC.x, maxC.x do
      for y = minC.y, maxC.y do
         for z = minC.z, maxC.z do
            local pos = {x = x, y = y, z = z}
            minetest.set_node(pos, {name = "air"})
         end
      end
   end
   -- Update metadata for the enchanted obsidian
   for _, pos in pairs(portal_info[3]) do
      local meta = minetest.get_meta(pos)
      meta:set_string("portal", "")
   end
end

minetest.register_node("nether:obsidian_enchanted", obsidian_def)
