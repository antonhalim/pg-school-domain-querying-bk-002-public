class Student
  attr_accessor :id, :name, :tagline, :github, :twitter, :blog_url, :image_url, :biography, :courses

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id SERIAL PRIMARY KEY,
        name TEXT,
        tagline TEXT,
        github TEXT,
        twitter TEXT,
        blog_url TEXT,
        image_url TEXT,
        biography TEXT
      );
    SQL
    DB[:conn].exec(sql)
  end

  def self.drop_table
    DB[:conn].exec('DROP TABLE IF EXISTS students;')
  end

  def insert
    sql = <<-SQL
      INSERT INTO students
      (name, tagline, github, twitter, blog_url, image_url, biography)
      VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id
    SQL

    result = DB[:conn].exec_params(sql, [name, tagline, github, twitter, blog_url, image_url, biography]).first
    @id = result["id"].to_i
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name=$1, tagline=$2, github=$3, twitter=$4, blog_url=$5, image_url=$6, biography=$7
      WHERE id=$8
    SQL

    DB[:conn].exec_params(sql, [name, tagline, github, twitter, blog_url, image_url, biography, id])
  end

  def save
    if id
      update
    else
      insert
    end
  end

  def self.new_from_db(row)
    new.tap do |student|
      student.id = row["id"].to_i
      student.name = row["name"]
      student.tagline = row["tagline"]
      student.github = row["github"]
      student.twitter = row["twitter"]
      student.blog_url = row["blog_url"]
      student.image_url = row["image_url"]
      student.biography = row["biography"]
    end
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM students WHERE id=$1
    SQL
    result = DB[:conn].exec_params(sql, [id])

    return nil if result.count.zero?
    new_from_db(result.first)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name=$1
    SQL
    result = DB[:conn].exec_params(sql, [name])

    return nil if result.count.zero?
    new_from_db(result.first)
  end

  def add_course(course)
    sql = <<-SQL
    INSERT INTO registrations (student_id, course_id)
    VALUES
    ($1, $2)
    SQL
    parameter = id, course.id
    DB[:conn].exec_params(sql, parameter)
  end

  def courses
    sql = <<-SQL
      SELECT * FROM courses JOIN registrations
      ON registrations.course_id = courses.id
      WHERE student_id = $1
    SQL
    result =  DB[:conn].exec_params(sql, [id])
    result.map{|course| Course.new_from_db(course)}
  end

end
