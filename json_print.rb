#!/usr/bin/env ruby

# CHANGE: this file doesn't do anything?? would delete but i'm scared so i'm just commenting it out, still passes tests
# UPDATE: reread the instructions, glad i didn't delete it

require 'json'

puts JSON.generate(JSON.parse(ARGF.read), array_nl: "\n", object_nl: "\n", indent: "    ")


