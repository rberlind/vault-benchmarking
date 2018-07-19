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
   path = "/v1/secret/benchmark-client-1-" .. id
   local msg = "thread %d created"
   print(msg:format(id))
end

function request()
   if requests < 0 then
      writes = writes + 1
      method = "POST"
      body = '{"foo-' .. id .. '" : "bar-' .. id ..'"}'
   else
      reads = reads + 1
      method = "GET"
      body = ''
   end
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
      local responses = thread:get("responses")
      local msg = "thread %d made %d requests including %d reads and %d writes, and got %d responses"
      print(msg:format(id, requests, reads, writes, responses))
   end
end
