require 'pry'
class Department
  attr_accessor :id, :name, :courses

  def self.db
    DB[:conn]
  end

  def db
    self.class.db
  end

  def self.execute(sql, args =[])
    db.exec_params(sql, args)
  end

  def execute(sql, args =[])
    self.class.execute(sql, args)
  end

  def self.drop_table
      execute('DROP TABLE IF EXISTS departments')
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS departments(
      id SERIAL,
      name TEXT);
    SQL
    execute(sql)
  end
  def insert
    sql = <<-SQL
    INSERT INTO departments(name) VALUES($1) RETURNING id
    SQL
    result = execute(sql, [name]).first
    @id = result["id"].to_i
  end

  def self.new_from_db(row)
    department = Department.new
    department.id = row["id"].to_i
    department.name = row["name"]
    department
  end

  def self.find_by_name(string)
    sql = <<-SQL
      SELECT * FROM departments WHERE name = $1
    SQL
    result = execute(sql, [string])
    return nil if result.count.zero?
    new_from_db(result.first)
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM departments WHERE id = $1
    SQL
    result = execute(sql, [id])
    return nil if result.count.zero?
    new_from_db(result.first)
  end

  def update
    sql = <<-SQL
      UPDATE departments SET name = $2 WHERE id = $1
    SQL
    parameter = [id, name]
    result = execute(sql, parameter)
  end

  def save
    if id
      update
    else
      insert
    end
  end

  def courses
    sql = <<-SQL
    SELECT * FROM courses WHERE department_id = $1
    SQL
    result = execute(sql,[id])
    result.map{|course| Course.new_from_db(course)}
  end

  def add_course(course)
    course.department_id = id
    course.save
    save
  end

end
