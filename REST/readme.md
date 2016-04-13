Little REST Server
=====================

## Requirements

- Ruby - like the one that comes on your Mac by default
- The Sinatra gem - http://www.sinatrarb.com
- The json gem

```
    #### (Hint) You won't need 'sudo' if you're using rbenv 
    $ sudo gem install sinatra
    $ sudo gem install json
```

## Change the password to the REST server

```
    $ vi TexLegeServer.rb 
```

## Run the server

```
    $ ruby TexLegeServer.rb
```

## Configuring TexLege

- Edit TXLConstants.m ...
- server URL = http://localhost:4567/texlege/v1
- login = texlegeRead / *<server_pwd>*
