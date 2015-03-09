require 'pry'
class Registration
  attr_accessor :id, :course_id, :student_id

    def self.db
      DB[:conn]
    end

    def db
      self.class.db
    end

    def self.execute(sql, args=[])
      db.exec_params(sql, args)
    end

    def execute(sql, args=[])
      self.class.execute(sql, args)
    end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS registrations(
      id SERIAL PRIMARY KEY,
      course_id INTEGER,
      student_id INTEGER
    )
    SQL
    execute(sql)
  end

  def self.drop_table
    DB[:conn].exec('DROP TABLE IF EXISTS registrations;')
  end

  def insert
    sql = <<-SQL
    INSERT INTO registrations(course_id, student_id) VALUES($1, $2) RETURNING id
    SQL
    result = execute(sql, [course_id, student_id]).first
    @id = result["id"].to_i
  end

  def update
    sql = <<-SQL
      UPDATE registration SET student_id = $1, course_id = $2 WHERE id = $3
    SQL
    parameter = [student_id, course_id, id]
    result = execute(sql, parameter)
  end

  def save
    if id
      update
    else
      insert
    end
  end

end
