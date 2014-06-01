require_relative '../config/environment'

PG.connect.exec("DROP DATABASE IF EXISTS school_domain_querying_test")
PG.connect.exec("CREATE DATABASE school_domain_querying_test")
DB[:conn] = PG.connect(dbname: 'school_domain_querying_test')
