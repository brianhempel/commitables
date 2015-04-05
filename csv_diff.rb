require "csv"

# Primary key is the first column.

a = CSV.parse(File.read(ARGV[0]))
b = CSV.parse(File.read(ARGV[1]))

headers = a.shift
b.shift

id_to_a_row = a.map { |row| [row[0], row] }.to_h
id_to_b_row = b.map { |row| [row[0], row] }.to_h

diff = []

b.each do |b_row|
  a_row = id_to_a_row[b_row[0]]
  if a_row
    if a_row != b_row
      diff << ["update", *b_row]
    end
  else
    diff << ["create", *b_row]
  end
end

a.each do |a_row|
  unless b_row = id_to_b_row[a_row[0]]
    diff << ["delete", *a_row]
  end
end

print ["change_type", *headers].to_csv

diff.shuffle.each do |row|
  print row.to_csv
end
