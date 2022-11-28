
------------------------------------------------------------------------------------------------------
--. Ratelimiting ONLY CONSIDERING modsecurity denials .--

WHY? Imagine a cracker with a batch of thousands requests trying to xploit any website vulnerability... Modsecurity will stop hits, ok, and then LFD firewall may block that IP... ok.. but what happens until LFD blocks???? Huge number of xploiting request could be received until LFD blocks, maybe one of them may not trigger the modsecurity rules, and ooops, xploit has been done!! We may not receive minutes of xploiting requests waiting for LFD actions, so this ratelimit may BLOCK that IP if it triggers the current denials limit... it is going to be "blocked" BEFORE LFD ban the IP.

Must compile libmodsecurity with (--with-lmdb). Also compile using LUA: ensure LUA is present when libmodsecurity configure before compiling libmodsecurity install liblua5.3-0 and liblua5.3-dev for example!

Also MUST configure "working_directory" variable at /etc/nginx/nginx.conf, selecting something like /var/modsecurity, and SHOULD be writeable by user running nginx, as 'nginx' or 'www-data' for example.

Skipping libmodsecurity v2 functions to decrease values, as v3 does not support yet 'deprecatevar' or 'expirevar' functions. Using LUA script to decrease. It's a modified version of: https://github.com/loadbalancerorg/modsec_decrement_script

Decreasing hits via lua script will be done only when processing a new request, and will consider how much time it took... Also consider removing modsec-shared-collections* and reloading nginx from time to time to clean-up database and remove old garbage.

If using this script, should:

- libmodsecurity configure with --with-lmdb, to work with modsec-shared-collections
- ensure lua and lua-dev packages are installed in the system, so libmodsecurity is configured to work with lua.
- nginx configuration variable "working_directory" set to a writable directory for nginx user (nginx, www-data, nobody or whatever).
- work with CRS OWASP package of rules (at least v3)
- set the script path for lua in the rule id:5001 below!
- Execute this after loading CRS OWASP rules: "SecRuleRemoveById 901321"
- Configure maximum_hit_requests, lua_interval and lua_decrease in the rule id:5000 below!

HAVE A LOOK AND MODIFY CONF FILE... more comments on it!

