require 'pry'
class Course
  attr_accessor :id, :name, :department_id, :students

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

  def self.drop_table
    execute('DROP TABLE IF EXISTS courses')
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS courses(
    id SERIAL,
    name TEXT,
    department_id INTEGER
    );
    SQL
    execute(sql)
  end

  def insert
  sql = <<-SQL
    INSERT INTO courses
    (name, department_id)
    VALUES ($1, $2) RETURNING id
  SQL
    result = execute(sql, [name, department_id])
    @id = result[0]["id"].to_i
  end

  def self.new_from_db(row)
    course = Course.new
    course.id = row["id"].to_i
    course.name = row["name"]
    course.department_id = row["department_id"].to_i
    course
  end

  def self.find_by_name(string)
    sql = <<-SQL
    SELECT * FROM courses WHERE name=$1
    SQL
    result = execute(sql, [string])
    return nil if result.count.zero?
    new_from_db(result.first)
  end

  def self.find_all_by_department_id(id)
    sql = <<-SQL
    SELECT * FROM courses WHERE department_id=$1
    SQL
    result = execute(sql,[id])
    return nil if result.count.zero?
    result.map do |course|
    new_from_db(course)
    end
  end

  def update
    sql = <<-SQL
      UPDATE courses SET name = $2, department_id = $3 WHERE id = $1
    SQL
    parameter = [id, name, department_id]
    result = execute(sql, parameter)
  end

  def save
    if self.id
      update
    else
      insert
    end
  end

  def department= department
    self.department_id = department.id
  end

  def department
    Department.find_by_id(department_id)
  end

  def add_student(student)
    sql = <<-SQL
    INSERT INTO registrations(student_id, course_id)
    VALUES ($1, $2)
    SQL
    execute(sql, [student.id, self.id])
  end

  def students
    sql = <<-SQL
    SELECT * FROM registrations WHERE course_id = $1
    SQL
    result = execute(sql, [self.id])
    result.map{|x| Student.find_by_id(x["student_id"].to_i)}
  end

end
