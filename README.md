# Spree Developer Tools

This is a Spree development tools gem. It helps you work with Spree applications, both extensions and standard Rails applications.

## Installation

Add it to your `Gemfile`:

```ruby
gem 'spree_dev_tools', group: [:development, :test]
```

Run:

```bash
bundle install
```

And finally run the generator:

```bash
bundle exec rails g spree_dev_tools:install
```

## Documenting your Admin API endpoints

Spree builds an agent tool (MCP server and dashboard assistant) for every Admin API action it finds documented in an OpenAPI document. Core documents its own endpoints. Your application, and each extension, documents its own in an `openapi/admin.yaml`, and Spree merges that file in.

In a Spree application (a new `create-spree-app` project ships both files already):

```bash
spree generate spree_dev_tools:openapi
spree task openapi:generate
```

In an extension, which runs against its dummy app:

```bash
bundle exec rails g spree_dev_tools:openapi
bundle exec rake spree:openapi:generate
```

The generator writes three things:

- `spec/swagger_helper.rb`, which configures rswag for your app or engine. That means the document path, the admin security schemes, `admin_operation`, `request_body_for` and `agent_tool`, and reproducible output.
- `spec/agent_tools_spec.rb`, the contract that fails when an admin action has no documented operation, an opt-out gives no reason, or two actions would derive one tool name.
- A skeleton rswag spec for every admin action your controllers serve that isn't documented yet, under `spec/integration/admin/`. Each skeleton is skipped until you fill in two things:
  - its description, which agents read to decide whether to call it;
  - the records its response is tested against.

Run the generator again after adding endpoints; it only writes what is missing. The task then writes `openapi/admin.yaml`: commit it. An extension's gemspec that ships `git ls-files` includes it already.

The app or engine is found from the directory the specs run in. An extension with more than one engine, or a different document title, sets them in `spec/swagger_helper.rb` before the require:

```ruby
SpreeDevTools::Openapi.engine = MyExtension::Engine
SpreeDevTools::Openapi.title = 'My Extension Admin API'
require 'spree_dev_tools/rspec/openapi'
```

## Configuring

If you want to disable Simplecov set the `SPREE_DEV_TOOLS_DISABLE_SIMPLECOV` ENV variable to any value.

## Contributing

If you'd like to contribute, please take a look at the
[instructions](CONTRIBUTING.md) for installing dependencies and crafting a good
pull request.
