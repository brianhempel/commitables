CSV_PATHS = Dir.glob("michigan_csv/*.csv").sort

CSV_PATHS.each_cons(2) do |a_path, b_path|
  fork do
    out_path = a_path.gsub("michigan_csv", "michigan_csv_diff")
    out_path = out_path.gsub(".csv", "") + "-to-#{b_path[/[^\/]+\.csv/]}"
    exec "ruby csv_diff.rb #{a_path} #{b_path} > #{out_path}"
  end
end

Process.wait