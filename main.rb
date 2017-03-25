require 'mini_magick'
require 'prawn'

module MiniMagick
  class Image
    def pixel_at x, y
      run_command("convert", "#{path}[1x1+#{x.to_i}+#{y.to_i}]", 'txt:').split("\n").each do |line|
        return $1 if /^0,0:.*(#[0-9a-fA-F]+)/.match(line)
      end
      nil
    end
  end
end

# MiniMagick.configure do |config|
#   config.cli = :graphicsmagick
# end

file = MiniMagick::Image.open('image.jpg')

cards_across = 20
cards_down   = 20
card_width   = 70
card_height  = 28

output_mult   = 2 # Output image will be this * card_width wide, this * card_height tall
output_width  = card_width * output_mult
output_height = card_height * output_mult

puts "Input image width #{file.width} height #{file.height}"
puts "Mapped to output width #{output_width} height #{output_height}"

print 'Writing large combined output...'
file.resize("#{cards_across}x#{cards_down}!")
    .sample("#{cards_across * output_width}x#{cards_down * output_height}!")
    .write('output/output.png')
puts 'done'

for j in 0..cards_down - 1
  for i in 0..cards_across - 1
    front_path = "output/x#{i.to_s.rjust(2, "0")}y#{j.to_s.rjust(2, "0")}.front.png"
    card_front = MiniMagick::Image.open('output/output.png').crop("#{output_width}x#{output_height}+#{i * output_width}+#{j * output_height}")
    card_front.write(front_path)
    # Get pixel color
    card_front.scale('1x1')
    color = card_front.pixel_at(0, 0)
    puts "Completed front x#{i} y#{j} color #{color}"

    # Create the blank image for the background
    back_path = "output/x#{i.to_s.rjust(2, "0")}y#{j.to_s.rjust(2, "0")}.back.png"
    MiniMagick::Tool::Convert.new do |s|
      s.size "#{output_width}x#{output_height}"
      s.xc "black"
      s << back_path
    end

    # Add text to the back image and write the file out
    MiniMagick::Image.new(back_path) do |s|
      s.font 'Helvetica'
      s.pointsize 40
      s.gravity 'Center'
      s.fill '#ffffff'
      s.draw "text 0,0 #{color}"
      s.write(back_path)
    end
    puts "Completed back #{i} #{j}"

    Prawn::Document.generate("output/x#{i.to_s.rjust(2, "0")}y#{j.to_s.rjust(2, "0")}.pdf", :margin => 0, :page_size => [output_width, output_height]) do 
      image front_path
      start_new_page
      image back_path
    end
    puts "Completed PDF #{i} #{j}"
  end
end

puts 'Complete'
