These are some small tools for aiding in analysing Skype!MSNP. You need the `pry`, `json` and `qtbindings` gems for them to work. Pry is so that a debugger can be broken into when things fail. Easier than printf debugging if you know where the fail is going to be.

## login-browserui.rb
Run it somewhere Qt can open a window.

Log in to Skype. When run, if it doesn't crash (which happens with depressing regularity), it shows the MS Account login screen in a window. Close it after successfully logging in, and it will write

    {"status":"success", "token": <an object> }

to stdout. `token` is a JSON representation of the login token by the initial stage of login. If closed without either crashing or logging in it'll write
    {"status":"failure"}
instead.

## login.rb
Use the token you got above to make `state.json`:

    {"initial": <the token>}

then run this program. It'll rewrite `state.json` to include all the information gotten in the "Login" section of [the notes](../doc/skypenotes.ym).