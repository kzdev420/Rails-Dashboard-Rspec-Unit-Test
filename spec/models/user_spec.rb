require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'creating user' do
    it 'it has valid factory' do
      user = create(:user)
      expect(user.valid?).to eq(true)
    end

    it 'shouldn`t save with empty first_name and last_name' do
      user = User.create(
        email: Faker::Internet.email,
        password: Faker::Internet.password
      )
      expect(user.valid?).to eq(false)
      expect(user.errors.has_key?(:first_name)).to eq(true)
      expect(user.errors.has_key?(:last_name)).to eq(true)
    end

    it 'shouldn`t save with invalid or empty phone' do
      params = {
        email: Faker::Internet.email,
        password: Faker::Internet.password,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name
      }

      check_phone = lambda do |user|
        expect(user.valid?).to eq(false)
        expect(user.errors.has_key?(:phone)).to eq(true)
      end

      user = User.create(params)
      check_phone.call(user)
      user = User.create(params.merge(phone: '111'))
      check_phone.call(user)
    end

    it 'shouldn`t save existed email' do
      created_user = create(:user)
      user = User.create(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: created_user.email,
        password: Faker::Internet.password
      )
      expect(user.valid?).to eq(false)
      expect(user.errors.has_key?(:email)).to eq(true)
    end

  end
end
