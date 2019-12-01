% Single-Use SSH Keys
%
% 23 Aug 2015

**NOTE:** This is a "retroposted" article -- I originally created and
wrote this in the summer of 2015, but now (30 Nov 2019) I'm revising
it and merging it into my new blog system. There was some discussion
about this on [Hacker
News](https://news.ycombinator.com/item?id=10105661) at the time. The
concept here is a bit useless now (everyone's got an SSH client on
their phone, right?), but I think it's a neat thing to have, just in
case.

This article outlines a system of "single-use SSH keys" -- SSH keys
which, when used to log in, automatically delete themselves from the
user's `authorized_keys` file.

## Motivation

Say you're stranded without a laptop, but you need to SSH into a
remote box for some urgent maintenance. You could carry a flash drive
around with a long-term SSH key, but would you trust that to a public
computer?

This issue could be partially resolved with a "disposable" SSH key --
a key that can only be used to log in once (ideally you'd never have
to do this -- but the world is non-ideal^\[[citation
needed](https://xkcd.com/285/)\]^). The idea is that you'd generate one
or two keys in advance and use them as needed in situations like the
one above.

## How It Works

Each key in a user\'s `.ssh/authorized_keys` file can be modified to run
a command when the key is used for authentication. This mechanism can be
(ab)used to delete the key from the list after it is used to log in:

~~~ {bash}
command="sed -i \"/MYMH_user_DONOTMODIFYTHISCOMMENT_onetime0^/d\" $HOME/.ssh/authorized_keys ; $SHELL" ssh-rsa AAAA.... MYMH_user_DONOTMODIFYTHISCOMMENT_onetime0
~~~

## Threat Model

This system is far from perfect. It does *not* offer any protection
against the following:

- Theft of unused, unencrypted keys.
- Injection of commands by an SSH client.

It *does*, however, protect against a long-term key from being stolen
and being used by an attacker to authenticate later, because a key is
rendered worthless after being used.

## Script Download

To automate the process, I\'ve written a simple shell script that
automatically generates and sets up some single-use keys.

The script can be downloaded from [here](/pub/onetime_ssh.sh).\

::: {.fine}
SHA1: 5a68f99d933003dc4aac17134af5186c65d50efa\
MD5: c1e4b1d03d516711f006d96e974ce9e9
:::
