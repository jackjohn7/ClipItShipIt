# ClipIt&ShipIt

Application allowing a user to share clips shorter than 10 minutes.

# Goals

- Embeddable
- Analytical
- Simple
- Beautiful
- Available

# Stack

- Gleam
  - Mist + Wisp
  - Lustre + Sketch
- PostgreSQL
- Valkey (FOSS fork of Redis)
- Docker/Podman
- [Peggy](https://github/com/jackjohn7/peggy)

# Setup

This project is tracked on GitHub *and* GitLab, so I'd recommend
getting set up with both. Syncing them any other way would just
be too bothersome for me.

1. Set up your authentication with `gh` and `glab`
2. Add all remotes
3. Create alias to push all origin: `git config --global alias.pushall '!git remote | xargs -L1 git push --all'`
   **OR** Use the script `./scripts/push_all.sh`.

# TO-DO

- Use Testcontainers to start required databases in local development and tests (elixir is supported)
- Check out tailwindcss
  - Perhaps write a library if necessary for building tailwind classes from lustre code
