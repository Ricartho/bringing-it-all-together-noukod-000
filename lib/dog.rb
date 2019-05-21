class Dog 
  attr_accessor :id,:name,:breed 

  def initialize(id:nil,name:,breed:)
    @id = id
    @name = name
    @breed = breed
  end 
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
  
  def save
      if self.id 
        self.update 
      else
        DB[:conn].execute("INSERT INTO dogs (name,breed) VALUES (?,?)",self.name,self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] 
       
      end 
        self
  end 
  
  def self.create(name:,breed:)
      dog = self.new(name: name,breed: breed)
      dog.save
  end 
  
  def self.find_by_id(id)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id =?",id)[0]
    Dog.new(id: dog[0],name: dog[1],breed: dog[2])
  end 
  
  def self.find_or_create_by(name:,breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",name,breed)
    if !dog.empty?
      dog_data = dog[0]
      new_dog = self.new(id: dog_data[0],name: dog_data[1],breed: dog_data[2])
    else
      new_dog = self.create(name: name,breed: breed)
    end
    new_dog
  end 
  
  def self.new_from_db(db_row)
    dog = self.new(id: db_row[0],name: db_row[1],breed: db_row[2])
    dog
  end 
  
  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name =?",name)[0]
    dog = self.new_from_db(dog)
  end 
  
  def update
    sql = "UPDATE dogs SET name = ?,breed =? WHERE id=?"
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end 
end 