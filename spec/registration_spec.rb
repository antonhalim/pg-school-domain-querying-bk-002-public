require_relative 'spec_helper'

describe Registration do

  before do
    Registration.create_table
  end

  after do
    Registration.drop_table
  end


  describe 'attributes' do
    it 'has an id, course_id, student_id' do
      attributes = {
        :course_id => 35,
        :student_id => 84
      }

      registration = Registration.new
      registration.course_id = attributes[:course_id]
      registration.student_id = attributes[:student_id]

      expect(registration.id).to eq(attributes[:id])
      expect(registration.course_id).to eq(attributes[:course_id])
      expect(registration.student_id).to eq(attributes[:student_id])
    end
  end

  describe '.create_table' do
    it 'creates a Registrations table' do
      Registration.drop_table
      Registration.create_table

      table_check_sql = "SELECT table_name FROM information_schema.tables WHERE table_name = 'registrations';"
      expect(DB[:conn].exec(table_check_sql).first["table_name"]).to eq('registrations')
    end
  end

  describe '.drop_table' do
    it "drops the Registrations table" do
      Registration.create_table
      Registration.drop_table

      table_check_sql = "SELECT table_name FROM information_schema.tables WHERE table_name = 'registrations';"
      expect(DB[:conn].exec(table_check_sql).first).to be_nil
    end
  end
end
