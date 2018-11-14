---
title: Adding a Custom Postgres Type in Rails 4.2
date: 2015-09-17
---

In a Rails app at work, we are using a PostGIS data type of `geometry` and we were getting this warning in our logs:

```
unknown OID 16391: failed to recognize type of 'geo'. It will be treated as String.
```

This is because by default, Active Record doesn't support the OID 16391 for this data type. We can add our own in Rails 4.1 as [recommended by Rob Di Marco](http://www.innovationontherun.com/fixing-unknown-oid-geography-errors-with-postgis-and-rails-4-0/).

READMORE

In Rails 4.2, the OID module got reworked a bit and that solution doesn't work anymore. Well Rob helps as again by [recommending a new solution for Rails 4.2](http://www.innovationontherun.com/adding-a-custom-postgresql-type-with-rails-4-2/). The site isn't loading for me so I pulled the code from Google Cache, cleaned it up a little and represent it to you here.

In `config/initializers/add_custom_oid_types_to_active_record.rb`:

```ruby
# ActiveRecrod will `warn` (to stdout) when first connecting to the adapter:
#  unknown OID 16391: failed to recognize type of 'geo'. It will be treated as...

# Registering the `geometry` type (typically not supported by Active Record) will
# prevent this warning but AR will continue to treat it the same. This cleans up
# logs and test output.

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  def initialize_type_map_with_postgres_oids mapping
    initialize_type_map_without_postgres_oids mapping
    register_class_with_limit mapping, 'geometry',
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::OID::Integer
  end

  alias_method_chain :initialize_type_map, :postgres_oids
end
```
