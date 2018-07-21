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
   deletes = 0
   responses = 0
   method = "DELETE"
   local msg = "thread %d created"
   print(msg:format(id))
end

function request()
   deletes = deletes + 1
   path = "/v1/secret/benchmark-" .. deletes
   body = ''
   requests = requests + 1
   return wrk.format(method, path, nil, body)
end

function response(status, headers, body)
   responses = responses + 1
end

function done(summary, latency, requests)
   for index, thread in ipairs(threads) do
      local id        = thread:get("id")
      local requests  = thread:get("requests")
      local reads     = thread:get("reads")
      local writes    = thread:get("writes")
      local deletes   = thread:get("deletes")
      local responses = thread:get("responses")
      local msg = "thread %d made %d requests including %d reads, %d writes, and % deletes, and got %d responses"
      print(msg:format(id, requests, reads, writes, deletes, responses))
   end
end
