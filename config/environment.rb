require 'pg'
require_relative '../lib/student'
require_relative '../lib/department'
require_relative '../lib/course'
require_relative '../lib/registration'

DB = {:conn => PG.connect(dbname: 'school_domain_querying')}
