# choish
A Valkyrie-based CHO application?

# Testing

Currently, this is used only to test performance with Valkyrie and compared it to our
Hyrax-based application, [cho-req](https://github.com/psu-libraries/cho-req)

## Test runs

Here's a sample of what's been done so far:

``` bash
export RAILS_ENV=production

bundle exec rake testing_support:clean postgres_testing:all
bundle exec rake testing_support:clean postgres_testing:all[100]
bundle exec rake testing_support:clean postgres_testing:all[1000]
bundle exec rake testing_support:clean postgres_testing:collections[10000]
bundle exec rake testing_support:clean postgres_testing:collections[100000]

# Failed:
time bundle exec rake postgres_testing:nested_collections[10000]

# Fedora Tests
bundle exec rake testing_support:clean fedora_testing:all
bundle exec rake testing_support:clean fedora_testing:all[100]
bundle exec rake testing_support:clean fedora_testing:all[1000]
time bundle exec rake fedora_testing:collections[10000]
time bundle exec rake fedora_testing:collections[100000]

# Failed:
time bundle exec rake fedora_testing:nested_collections[10000]

# ActiveFedora Tests
bundle exec rake testing_support:clean active_fedora_testing:all
bundle exec rake testing_support:clean active_fedora_testing:all[100]

# Test halted
bundle exec rake testing_support:clean active_fedora_testing:all[1000]

# Test halted
bundle exec time rake active_fedora_testing:collections[100000]

# Re-ran file tests
bundle exec rake testing_support:clean active_fedora_testing:files
bundle exec rake testing_support:clean active_fedora_testing:files[100]
bundle exec rake testing_support:clean
bundle exec time rake active_fedora_testing:files[1000]
```

Results are displayed and discussed: [http://awead.github.io/fedora-tests](http://awead.github.io/fedora-tests)
