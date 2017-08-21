#!/bin/bash

bundle exec rake testing_support:clean
bundle exec rake active_fedora_testing:all
bundle exec rake testing_support:clean
bundle exec rake fedora_testing:all
bundle exec rake testing_support:clean
bundle exec rake postgres_testing:all
