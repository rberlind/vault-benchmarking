-- Script that writes and reads secrets from k/v engine in Vault

local counter = 1
local threads = {}

function setup(thread)
   thread:set("id", counter)
   table.insert(threads, thread)
   counter = counter + 1
end

function init(args)
   requests  = 0
   reads = 0
   writes = 0
   responses = 0
   -- give each thread different random seed
   math.randomseed(os.time() + id*1000)
   method = "GET"
   local msg = "thread %d created"
   print(msg:format(id))
end

function request()
   reads = reads + 1
   -- cycle through paths from 1 to N in order
   -- path = "/v1/secret/benchmark-" .. (reads % 100) + 1
   -- randomize path to secret
   path = "/v1/secret/benchmark-" .. math.random(10000)
   body = ''
   requests = requests + 1
   return wrk.format(method, path, nil, body)
end

function response(status, headers, body)
   responses = responses + 1
   --[[
   body_object = json.decode(body)
   for k,v in pairs(body_object) do 
      if k == "data" then
         for k1,v1 in pairs(v) do
            local msg = "read secrets: %s : %s"
            print(msg:format(k1, v1)) 
         end
      end
   end
   ]]
end

function done(summary, latency, requests)
   for index, thread in ipairs(threads) do
      local id        = thread:get("id")
      local requests  = thread:get("requests")
      local reads     = thread:get("reads")
      local writes    = thread:get("writes")
      local responses = thread:get("responses")
      local msg = "thread %d made %d requests including %d reads and %d writes, and got %d responses"
      print(msg:format(id, requests, reads, writes, responses))
   end
end
