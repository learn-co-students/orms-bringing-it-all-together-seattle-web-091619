class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(params = {name: name, breed: breed, id: id=nil})
    @name = params[:name]
    @breed = params[:breed]
    @id = params[:id]
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs(name, breed) VALUES (?, ?);"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(params)
    dog = self.new(params)
    dog.save
    dog
  end

  def self.create_table
    sql = "CREATE TABLE dogs(id PRIMARY KEY, name TEXT, breed TEXT);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(params = {name: name, breed: breed, id: id})
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    DB[:conn].execute(sql, id).map { |row| self.new_from_db(row) }.first

  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    DB[:conn].execute(sql, name).map { |row| self.new_from_db(row) }.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      # Nested array of dog
      dog_data = dog[0]
      id = dog_data[0]
      name = dog_data[1]
      breed = dog_data[2]
      dog = Dog.new(params = {name: name, breed: breed, id: id})
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

end