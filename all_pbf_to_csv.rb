IN_FILES = Dir.glob("michigan_pbf/*.pbf")

IN_FILES.each do |path|
  fork do
    out_path = path.gsub("pbf", "csv")
    exec "ruby pbf_nodes_to_csv.rb #{path} > #{out_path}"
  end
end

Process.wait