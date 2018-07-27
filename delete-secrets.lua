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
   path = "/v1/secret/read-test/secret-0"
   body = ''
   local msg = "thread %d created"
   print(msg:format(id))
end

function request()
   -- First request is not actually invoked
   -- So, don't process it in order to delete secret-1
   if requests > 0 then
      deletes = deletes + 1
      -- Set the path to the desired path with secrets you want to delete
      path = "/v1/secret/read-test/secret-" .. deletes
      body = ''
   end
   requests = requests + 1
   return wrk.format(method, path, nil, body)
end

function response(status, headers, body)
   responses = responses + 1
   if responses == 1001 then
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
