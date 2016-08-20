# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(name: 'anonymous', email: 'anonymous@citrite.net')
VoteSession.create(name: 'Q3', start_date: Date.today.to_s, end_date: '2016-09-01', budget: 1000)
