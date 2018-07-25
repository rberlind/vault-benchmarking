-- Script that deletes secrets from k/v engine in Vault

local counter = 1
local threads = {}

function setup(thread)
   thread:set("id", counter)
   table.insert(threads, thread)
   counter = counter + 1
end

function init(args)
   requests  = 0
   deletes = 0
   responses = 0
   method = "DELETE"
   local msg = "thread %d created"
   print(msg:format(id))
end

function request()
   path = "/v1/secret/write-delete-test/thread-" .. id .. "-secret-" .. deletes 
   body = ""
   deletes = deletes + 1
   requests = requests + 1
   return wrk.format(method, path, nil, body)
end

function response(status, headers, body)
   responses = responses + 1
   if responses == 1000 then
      os.exit()
   end
end

function done(summary, latency, requests)
   for index, thread in ipairs(threads) do
      local id        = thread:get("id")
      local requests  = thread:get("requests")
      local deletes   = thread:get("deletes")
      local responses = thread:get("responses")
      local msg = "thread %d made %d requests including % deletes and got %d responses"
      print(msg:format(id, requests, deletes, responses))
   end
end
