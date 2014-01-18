These are some small tools for aiding in analysing Skype!MSNP. You need the json gem for them to work.

## login.rb
Log in to Skype. When run, writes this object to stdout:

    {"url": "https://login.live.com/..."}

Open the URL from that in your browser and log in. When you reach the end, the second object is written. Keep hold of that one, it's the auth tokens.