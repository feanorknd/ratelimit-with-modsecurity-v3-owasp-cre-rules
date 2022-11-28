-- Copyright 2022 Gino Morilla
-- Copyright 2020 Andrew Howe
--
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not
-- use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
-- License for the specific language governing permissions and limitations under
-- the License.
--
--
-- ratelimit.lua (working for libmodsecurity v3)
-- v2.0
-- Written by Gino Morilla
-- Based in the original work by Andrew Howe (andrew.howe@loadbalancer.org)
--

function main()
	-- Get the name of the variable to be decremented
	local lua_hits = m.getvar("TX.lua_hits");
        -- Get tha name of the variable to set timestamp
	local lua_epoch = m.getvar("TX.lua_epoch");
        -- Get the value of the time interval in seconds
        local lua_interval = tonumber(m.getvar("TX.lua_interval"));
        -- Get the amount to decrement by each time
        local lua_decrease = tonumber(m.getvar("TX.lua_decrease"));
        -- Get the current Unix time and store it as a variable
        local lua_current_time = tonumber(m.getvar("TX.lua_current_time"));

	-- Test if it's possible to get the specified variable in the collection
	-- (we cannot set to 0, because then every request including legits will be collected)
	if not (m.getvar(lua_hits)) then return nil; end

	-- Get the value of the specified variable in the collection
	local var_value = tonumber(m.getvar(lua_hits));

	-- If the variable's value is 0 then there's nothing to do
	if (var_value == 0) then
		return nil;
	end

	-- Test if it's possible to get the variable's timestamp and, if not,
	--   set one (equal to the current time) and then return
	if not (m.getvar(lua_epoch)) then
		m.setvar(lua_epoch, lua_current_time);
		return nil;
	end

	-- Get the timestamp of when the specified variable was last updated
	local last_update_time = tonumber(m.getvar(lua_epoch));

	-- Calculate the number of seconds since the variable was last updated
	local time_since_update = lua_current_time - last_update_time;

	-- Test if the time since last update >= interval between decrements
	if time_since_update >= lua_interval then

		-- Calculate by how much the variable needs to be decremented
		local total_lua_decrease = math.floor(time_since_update / lua_interval) * lua_decrease;
		var_value = var_value - total_lua_decrease;

		-- Don't give negative results (interpreted as 'x-=var_value')
		if (var_value < 0) then
			var_value = 0;
		end

		-- UPDATE VARIABLES IN THE COLLECTION!!!!
		-- Set the variable to its new, decremented value
		m.setvar(lua_hits, var_value);
		-- Update the variable's 'last updated' timestamp
		m.setvar(lua_epoch, lua_current_time);
	end

	return nil;
end
