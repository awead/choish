#!/bin/bash

bundle exec rake testing_support:clean
echo "Active Fedora"
time bundle exec rake active_fedora_testing:collections
echo "---------------------------------"

bundle exec rake testing_support:clean
echo "Fedora"
time bundle exec rake fedora_testing:collections
echo "---------------------------------"

bundle exec rake testing_support:clean
echo "Valkyrie"
time bundle exec rake postgres_testing:collections
echo "---------------------------------"

