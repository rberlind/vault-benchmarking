-- Script that writes a list of secrets to k/v engine in Vault

local counter = 1
local threads = {}

function setup(thread)
   thread:set("id", counter)
   table.insert(threads, thread)
   counter = counter + 1
end

function init(args)
   requests  = 0
   writes = 0
   responses = 0
   method = "POST"
   local msg = "thread %d created"
   print(msg:format(id))
end

function request()
   writes = writes + 1
   -- cycle through paths from 1 to N in order
   path = "/v1/secret/list-test/secret-" .. writes 
   body = '{"key" : "1234567890"}'
   requests = requests + 1
   return wrk.format(method, path, nil, body)
end

function response(status, headers, body)
   responses = responses + 1
   if responses == 100 then
      os.exit()
   end
end

function done(summary, latency, requests)
   for index, thread in ipairs(threads) do
      local id        = thread:get("id")
      local requests  = thread:get("requests")
      local writes    = thread:get("writes")
      local responses = thread:get("responses")
      local msg = "thread %d made %d requests including %d writes and got %d responses"
      print(msg:format(id, requests, writes, responses))
   end
end
