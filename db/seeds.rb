# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Layer.create!(number: 1, name: "Top", color: 4)
Layer.create!(number: 16, name: "Bottom", color: 1)
Layer.create!(number: 17, name: "Pads", color: 2)
Layer.create!(number: 22, name: "tPlace", color: 7)