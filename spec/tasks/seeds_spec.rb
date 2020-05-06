require 'rails_helper'

describe "db:seed", type: :task do
  before(:all) { ParkingsApp::Application.load_tasks }

  describe 'invokes database builder' do
    subject { Build::DatabaseBuilder }
    after { Rake::Task['db:seed'].execute }
    it { is_expected.to receive(:run) }
  end
end
