---
title: Configuring Pow including SSL
date: 2015-01-20
---

I used pow in the past and didn't like it. I've given it a second chance and it seems to be working out. I'd like to give [Invoker](http://invoker.codemancers.com) a try though but I'll save that for another day.

Pow is a daemon that runs your rack (Rails) apps in the background when you request them at a special `example_app.dev` domain. You don't have to start your app manually anymore (e.g. `rails s`). If you don't use your app for 15 minutes it kills your app's process to free up memory (restarting it on the next request). It doesn't run workers (I recommend inline [que](https://github.com/chanks/que) workers via ActiveJob) or other daemons such as those in your `Procfile`. It just looks for a `config.ru` and (presumably) does a `rackup` on it. It's very simple to set up and it's Mac OS X only.

# Configuring Pow (including SSL)

## Install Pow

- Before running the install script, configure pow to use port `3300` rather than `80`; this makes port forwarding easier and avoids unnecessary sudoing. You may prefer to skip this step or choose another port besides `3300`.
```
echo 'export POW_DST_PORT=3300' >> ~/.powconfig
```

- Run the [pow](http://pow.cx) install script and configure pow to serve your app
```
curl get.pow.cx | sh
cd ~/.pow
ln -s ~/Code/example_co/example_app # Or where ever your repo is
```
- Ensure your application is running:
```
open http://example_app.dev:3300
```

## Configure SSL with tunnelss
- Install [tunnelss](https://github.com/rchampourlier/tunnelss) on your system:
```
gem install tunnelss
```
- Start tunnelss (I recommend 4430 as it does not require `sudo`):
```
tunnelss 4430 3300 # Change port 3300 if you changed DST_PORT (80 is default)
```
- Open the SSL URL to the app:
```
open https://example_app.dev:4430
```
- Trust the "unverified" self-signed certificate when prompted (should require admin password). [Screenshot for Safari](https://cloud.githubusercontent.com/assets/28198/5825515/9d33e926-a0b1-11e4-8fa2-8fb5157b2e86.png).

### Adding the SSL certificate to iOS
- In your shell, run `open ~/.tunnelss`.
- Send `cert.pem` to yourself (email/iMessage).
- Open the attachment on your iOS device and install the certificate (should require your pass code and warn you about it not be a verified certificate).
- To access your application, use [xip.io](http://xip.io). On your mac run `ipconfig getifaddr en0` to get your local IP to use in the xip.io URL (e.g. https://example\_app.10.0.1.4.xip.io:4430).

Note: If you're testing remotely you will need an SSH or VPN tunnel.

## Logs, restarting, pry and misc
- Logs can be viewed in `log/development.log`. A useful alias for this is:
```
alias devlogs='tail -f ~/Code/*/*/log/development.log' # May need to change the path
```
- Restart the application using:
```
touch tmp/restart.txt # Will restart on next page load
```
As usual, Rails handles much of the code reloading for you so you won't have to do this with every request. Just the typical reasons you'd need to restart the server for (modifying initializers, adding gems, modifying load paths, etc).
- Since [pry](http://pryrepl.org) isn't connected to a tty, you won't be able to start a debugger from your code the normal way (`binding.pry`). [pry-remote](https://github.com/Mon-Ouie/pry-remote) has our back. Use `binding.remote_pry` in your code and then run `pry-remote`. This will attach your terminal to the pry debugging session.
```
binding.remote_pry # In your code
pry-remote # In your shell
```
- For memory efficiency, pow will shut down applications that are not used for some time (default is 15 minutes). Your application will take a few extra seconds to load the first time you come back to it.

