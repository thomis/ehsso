require "spec_helper"

RSpec.describe Ehsso::Person do
  it "is creatable" do
    person = Ehsso::Person.new(id: 0, reference: '123', first_name: 'first_name', last_name: 'last_name', email: 'first_name.last_name@company.tld')

    expect(person.id).to eq(0)
    expect(person.reference).to eq('123')
    expect(person.first_name).to eq('first_name')
    expect(person.last_name).to eq('last_name')
    expect(person.email).to eq('first_name.last_name@company.tld')
    expect(person.full_name).to eq('last_name first_name')
  end

  it 'creates empty person instance' do
    person = Ehsso::Person.new

    expect(person.id).to eq(nil)
    expect(person.reference).to eq(nil)
    expect(person.first_name).to eq(nil)
    expect(person.last_name).to eq(nil)
    expect(person.email).to eq(nil)
    expect(person.full_name).to eq('')
  end

end
