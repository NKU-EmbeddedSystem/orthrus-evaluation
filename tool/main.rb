ar = []

log_name = "busy_1s_write_ortddl"


File.open "busy_1s_write_ortddl.log", "r" do |f|
  f.each_line do |l|
    ar <<l.to_f
  end
end


ar.sort!

data_num = ar.size


output = []

File.open "busy_1s_write_ortddl.dat", "w" do |f|
  for i in 0...data_num
    f.puts "#{ar[i]}\t#{i.to_f/data_num}"
  end
end
