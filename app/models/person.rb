module Ehsso

  class Person

    attr_accessor :id
    attr_accessor :reference
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :email

    def initialize(args={})
      @id               = args[:id]
      @reference        = args[:reference]
      @first_name       = args[:first_name]
      @last_name        = args[:last_name]
      @email            = args[:email]
    end

    # def method_missing(method)
    #   @roles.include?(method[0..-2].to_sym)
    # end

    def full_name
      [self.last_name,self.first_name].compact.join(" ")
    end
  end

end
