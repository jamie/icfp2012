module Lifter
end

Dir['./lib/lifter/*.rb'].each do |file|
  require file
end
