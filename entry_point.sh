#!/bin/bash

rails db:migrate
rails server -e stagging
