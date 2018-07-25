-- Script that writes and then deletes secrets in k/v engine in Vault

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
   deletes = 0
   responses = 0
   local msg = "thread %d created"
   print(msg:format(id))
end

function request()
   if id % 2 == 1 then
      -- Write secrets on odd threads against one of 1000 secrets for that thread
      method = "POST"
      path = "/v1/secret/write-delete-test/thread-" .. id .. "-secret-" .. (writes % 1000)
      writes = writes + 1
      body = '{"thread-' .. id .. '" : "write-' .. writes ..'","extra" : "1xxxxxxxxx2xxxxxxxxx3xxxxxxxxx4xxxxxxxxx5xxxxxxxxx6xxxxxxxxx7xxxxxxxxx8xxxxxxxxx9xxxxxxxxx0xxxxxxxxx"}'
   else
      -- Delete secrets on even threads against the 1000 secrets of the previous thread
      method = "DELETE"
      deletes = deletes + 1
      path = "/v1/secret/write-delete-test/thread-" .. id - 1 .. "-secret-" .. (deletes % 1000)
      body = ''
   end
   requests = requests + 1
   -- local msg = "method is %s, path is: %s"
   -- print(msg:format(method, path))
   return wrk.format(method, path, nil, body)
end

-- Delay even threads that do deletes at beginning
-- to give Vault time to save written secrets before deleting
function delay()
  if id  % 2 == 0 and requests == 0 then
    return 1000 --  ms
  end 
end

function response(status, headers, body)
   if status == 200  or status == 204 then
      responses = responses + 1
   end
end

function done(summary, latency, requests)
   for index, thread in ipairs(threads) do
      local id        = thread:get("id")
      local requests  = thread:get("requests")
      local writes    = thread:get("writes")
      local deletes   = thread:get("deletes")
      local responses = thread:get("responses")
      local msg = "thread %d made %d requests including %d writes and %d deletes and got %d responses"
      print(msg:format(id, requests, writes, deletes, responses))
   end
end

