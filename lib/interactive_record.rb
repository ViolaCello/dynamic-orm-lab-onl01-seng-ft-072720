require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  

    def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  
  end

  def self.column_names
    DB[:conn].results_as_hash = true
   
    sql = "PRAGMA table_info('#{table_name}')"
   
    table_info = DB[:conn].execute(sql)
    column_names = []
   
    table_info.each do |column|
      column_names << column["name"]
    end
   
    column_names.compact
  end


  def self.table_name
    self.to_s.downcase.pluralize
  end


  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def save
     # binding.pry
     k = values_for_insert.split(", ")
     k[0].delete!("'")
     k[1].delete!("'")
    #DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (?, ?)", [values_for_insert])
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (?, ?)", [k[0], k[1]])
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
   #binding.pry
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", [name])
  end

  def self.find_by(hash)
    
    q = hash.flatten
    key = q[0].to_s
    pair = q[1]
    pair.to_i if pair.to_i > 0
    # binding.pry
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE  #{key} = ?", [pair])
   # binding.pry
  end


end