-- Script that authenticates a user against Vault's userpass system many times

local counter = 1
local threads = {}

function setup(thread)
   thread:set("id", counter)
   table.insert(threads, thread)
   counter = counter + 1
end

function init(args)
   requests  = 0
   authentications = 0
   responses = 0
   method = "POST"
   path = "/v1/auth/userpass/login/loadtester"
   body = '{"password" : "benchmark" }'
   local msg = "thread %d created"
   print(msg:format(id))
end

function request()
   requests = requests + 1
   authentications = authentications + 1
   return wrk.format(method, path, nil, body)
end

function delay()
   return 5
end

function response(status, headers, body)
   responses = responses + 1
   -- print("Status: " .. status)
end

function done(summary, latency, requests)
   for index, thread in ipairs(threads) do
      local id        = thread:get("id")
      local requests  = thread:get("requests")
      local authentications    = thread:get("authentications")
      local responses = thread:get("responses")
      local msg = "thread %d made %d authentications and got %d responses"
      print(msg:format(id, authentications, responses))
   end
end

