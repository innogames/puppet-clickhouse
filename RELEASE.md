# Steps to create a new release

## Prerequisites
For being able to work with the repository, you should have either installed `ruby-bundler` or Puppet Development Kit `pdk`.
If you choose to use `bundle`, then to invoke `pdk` you'll use `bundle exec pdk`.

The following commands are more or less similar, so in examples `bundle` command will be used:

- `bundle ...`
- `pdk bundle ...`

*Note*: although they are similar, they are not the same because of possible different ruby version. So you have to stick to one of them.

## Release a new version check-list
- [ ] Install or update bundle in the repository root: `bundle install`
- [ ] Check if [REFERENCE.md](./REFERENCE.md) is updated: `bundle exec rake strings:generate:reference`.
- [ ] [optional] Check if pdk and templates have updates `bundle exec pdk update`.
- [ ] Bump version. It could be done manually in [metadata.json](./metadata.json) or with `bundle exec rake module:bump:{patch|minor|major}`. The rake task `module:bump_commit:{patch|minor|major}` will create a commit as well.
- [ ] Create a tag `bundle exec rake module:tag` with the version from the previous step. Travis will build and push the module to https://forge.puppet.com automatically after you push the tag.
- [ ] Create a release on Github.
