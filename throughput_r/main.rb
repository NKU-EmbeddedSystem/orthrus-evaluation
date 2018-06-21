nums = [1,2,4,8]

output = File.open("output.gen.dat", "w")


for i in nums
  total = 0
  Dir.glob("#{i}/*.log") do |file|
    total += File.read(file).each_line.select{ |l| l.match("[A]")}.last.split(" ")[1].to_i
  end
  output.puts "#{i}\t#{total}"
end

output.close
