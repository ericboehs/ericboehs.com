---
title: Sharing a team Heroku account
date: 2013-03-22
---

**tl;dr**: Share a Heroku account for a single place to add/remove team members for all shared apps. Permission allocation/revocation made simple! How? Add a new key for each team member to the shared account; access app repos using the heroku-accounts plugin

Currently at Brightbit there's 4-5 team members to add to each Heroku app. And with some projects having two, three or more apps (staging, production, splash, etc) it gets a bit cumbersome adding all of us and it will only get worse with more team mates.

READMORE

What makes this problem worse is we don't re-bill hosting; we let our clients create an account and then they add us as collaborators. Some clients like this control, some just have us do it for them. Whatever the case, adding a single email for each app is much nicer.

To add to the convenience, if we want to add a team member to every Brightbit project we simply add their key to the team account. And if a team member leaves, we change the password and remove their key: instant permission revocation on every project.

So how do we achieve this? Open your favorite terminal and follow along.

### Create a work account with a new key

You can only link an SSH key to one Heroku account at a time (how else would it know what account you were pushing from?), so you'll need to create a new key for your work account.

1. Install the [Heroku accounts](http://github.com/ddollar/heroku-accounts) plugin by David Dollar:

		heroku plugins:install git://github.com/ddollar/heroku-accounts.git

2. Add a work account and login using the shared team email/password (don't add anything to your ssh config yet -- we'll get to that):

		heroku accounts:add work

3. Generate a dedicated ssh key for your work account (this is your personal key -- don't share this with your team):

		ssh-keygen -f ~/.ssh/id_rsa_heroku_work

4. Add your key to the team Heroku account:

		heroku keys:add ~/.ssh/id_rsa_heroku_work.pub --account work

5. Add the key to a `heroku.work` host (so you can push/pull with git):

		cat << 'EOF' >> ~/.ssh/config
		Host heroku.work
		  HostName heroku.com
		  IdentityFile ~/.ssh/id_rsa_heroku_work
		  IdentitiesOnly yes
		EOF

## Change team heroku repositories

Now to use the account you'll need to replace the `heroku.com` hostname with `heroku.work`. You can do this by removing and re-adding the remote or you can edit your current .git/config.

1. Here's a 3 liner to modify your current .git/config that should work on any system (it would be a 1 liner if BSD and GNU sed agreed on inline replacement). You'll need to run it on the root of each repository:

		TMP_FILE=$(mktemp /tmp/config.XXXXXXXXXX)
		sed -e "s/heroku.com/heroku.work/" .git/config > $TMP_FILE
		mv $TMP_FILE .git/config

2. Verify it worked (you'll get a public key denied if it didn't):

		git remote update

3. You also may want to set your team repo's default Heroku account (you can use --global for a system-wide change):

		git config heroku.account work
	
## Caveats
* You won't know who deployed what when you run a `heroku releases`.

## That's all, folks

Mention me on twitter ([@ericboehs](http://twitter.com/ericboehs)) if you run into any problems.

Happy coding!
