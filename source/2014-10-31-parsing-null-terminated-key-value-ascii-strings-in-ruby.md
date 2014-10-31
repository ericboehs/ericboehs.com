---
title: Parsing null terminated key/value ASCII strings in Ruby
date: 2014-10-31
---

I've recently been messing with a lot of hex thanks to my current client. I ran across a key/value hex string where each key/value pair was NULL terminated (pairs separated from other pairs with a NULL character) and each key was seperated from its value by a colon. Here's the hex string:

```ruby
>> hexstr = "56494e3a3147314a433534343452373235323336370050524f544f3a3500504152414d533a302c312c322c342c372c392c31312c31342c323000494e44435452533a302830303030303030303030303131292c3128303131303031303131313129"
```

First I wanted to convert this to ASCII, Ruby makes this fairly simple:

READMORE

```ruby
>> str = [hexstr].pack 'H*'
=> "VIN:1G1JC5444R7252367\x00PROTO:5\x00PARAMS:0,1,2,4,7,9,11,14,20\x00INDCTRS:0(0000000000011),1(01100101111)"
```

Now we have an ascii string with null terminators. Ruby has escape sequences like `\n` for newline and `\t` for tab. It also has hex escape sequences, for example the letter `a` is `\x61` as `61` is its hex value. A null character is the hex value `00` so the escape sequence is `\x00`. Now to break the string apart we use split:

```ruby
>> kv_pairs = str.split "\x00"
=> ["VIN:1G1JC5444R7252367", "PROTO:5", "PARAMS:0,1,2,4,7,9,11,14,20", "INDCTRS:0(0000000000011),1(01100101111)"]
```

Finally, you can split these pairs into further pairs by mapping over them with split and then use Ruby's `Hash[]` syntax to create a hash from the array of arrays:

```ruby
>> kv_pairs_array = kv_pairs.map { |key_vals| key_vals.split ':' }
=> [["VIN", "1G1JC5444R7252367"], ["PROTO", "5"], ["PARAMS", "0,1,2,4,7,9,11,14,20"], ["INDCTRS", "0(0000000000011),1(01100101111)"]]
obdii_info = Hash[kv_pairs_array]
=> {"VIN"=>"1G1JC5444R7252367", "PROTO"=>"5", "PARAMS"=>"0,1,2,4,7,9,11,14,20", "INDCTRS"=>"0(0000000000011),1(01100101111)"}
```
If you're like me and don't like upcased strings for keys, you can symbolize the keys (thanks active support) with this oneliner (I added the downcase call to the mix):

```ruby
>> obdii_info = Hash[obdii_info.map { |(k, v)| [ k.downcase.to_sym, v ] }]
=> {:vin=>"1G1JC5444R7252367", :proto=>"5", :params=>"0,1,2,4,7,9,11,14,20", :indctrs=>"0(0000000000011),1(01100101111)"}
```

Looking nice! I've made these into methods for a util class I include. Eventually I'd like to make a special hex string class to handle this better, but for my current use case this works well.

Here are some methods you can throw in your own class:

```ruby
def hex_to_ascii hex_string
  [hex_string.delete ' '].pack 'H*'
end

def hashify_null_term_str str
  Hash[str.split("\x00").map { |key_vals| key_vals.split ':' }]
end

def symbolize_keys hash
  Hash[hash.map { |(k, v)| [ k.downcase.to_sym, v ] }]
end

# Example usage:
symbolize_keys hashify_null_term_str hex_to_ascii "56 49 4e 3a 00 50 52 4f 54 4f 3a 30 00 50 41 52 41 4d 53 3a"
# => { vin: nil, proto: "0", params: nil }
```

Happy Hacking.
