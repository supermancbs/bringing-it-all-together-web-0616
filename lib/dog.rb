class Dog 
  attr_accessor :name, :breed, :id 

  def initialize(id: nil, name:, breed:)
    @name=name 
    @breed = breed 
    @id = id 
  
  end 

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed INTEGER
      )
    SQL
  end 

  def self.drop_table
     DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end 

  def save 
    sql = <<-SQL 
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, name, breed)
   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save 
    dog
  end 

  def self.find_by_id(id)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end 

  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if !dog.empty?
      dog = dog[0]
    #  binding.pry 
      dog = Dog.new({id: dog[0], name: dog[1], breed: dog[2]})
    else
      dog = self.create(hash)
    end
    dog
  end 
    

  def self.new_from_db(row)
    hash = {id: row[0], name: row[1], breed: row[2]}
    Dog.new(hash)

  end 

  def self.find_by_name(name)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
    new_from_db(result[0]) 
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)

  end 



end 