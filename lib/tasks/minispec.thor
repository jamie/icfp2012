class Spec < Thor
  desc "all", "Run all specs"
  def all
    require 'minitest/spec'
    require 'minitest/autorun'
    Dir['./spec/**/*_spec.rb'].each do |file|
      require file
    end
  end
end