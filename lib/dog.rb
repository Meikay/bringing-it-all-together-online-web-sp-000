class Dog
  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :breed => "TEXT"
  }

  ATTRIBUTES.keys.each do |attribute_name|
    attr_accessor attribute_name
  end

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql ="DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  self
  end

  def self.create(attributes_hash)
    dog = Dog.new(attributes_hash)
    dog.save
    dog
  end

  def self.new_from_db(row)
    attributes_hash = {
        :id => row[0],
        :name => row[1],
        :breed => row[2]
      }
      self.new(attributes_hash)
  end

  def self.find_by_id(id)
    sql = <<-SQL
   SELECT * FROM dogs
   WHERE id = ?
   LIMIT 1
   SQL

   DB[:conn].execute(sql, id).map do |row|
     self.new_from_db(row)
   end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
      LIMIT 1
    SQL

    dog = DB[:conn].execute(sql, name, breed).first
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name, breed)
    end
    dog
  end

end
