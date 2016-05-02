class User < ActiveRecord::Base
 has_many :tweets

 def self.find_by_slug(arg)
   self.all.detect {|object| object.slug == arg}
 end

 def slug
   self.username.downcase.split(' ').join('-')
 end

 def authenticate(passphrase)
   self.password == passphrase ? self : false
 end
end