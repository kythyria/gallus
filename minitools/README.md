These are some small tools for aiding in analysing Skype!MSNP. You need the `pry` and `json` gems for them to work. Pry is so that a debugger can be broken into when things fail. Easier than printf debugging if you know where the fail is going to be. You also need a Qt5 (it may work with Qt4) build environment for `login-browserui`.

## login-browserui/
Compile with qmake etc, then run somewhere it can open a window.

Log in to Skype. When run, if it doesn't crash (which happens with depressing regularity), it shows the MS Account login screen in a window. On successful login, `state.json` will be written to the current directory with the first-stage login token in.

## login.rb
First run the above program, then run this program. It'll rewrite `state.json` to include all the information gotten in the "Login" section of [the notes](../doc/skypenotes.ym).

## Format of the `contacts` property
It's a series of nodes. Folders:
```Javascript
{
    serverId: String,
    displayName: String,
    type: Integer,
    status: Integer,
    syncKey: String, //Used by AS to only send changes
    properties: { // This is from the <unknown:FE-05> elements
        SID: String
    },
    childFolders: [], //Array of folders
    childLeaves: [], //Array of contacts
}
```
While the individual contacts:
```Javascript
{
    serverId: String,
    contactCard: {
        // Properties that are defined in ActiveSync, LastName, FirstName, etc
    },
    properties: {
        //Aforementioned <unknown:FE-05> stuff
    }
}
```
In the `properties` objects for both, the keys are the strings in `<unknown:FE-07>` elements and the values the strings in the `<unknown:FE-08>` elements. After all, it looks like a dictionary.
