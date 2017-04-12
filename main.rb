require 'mini_magick'
require 'prawn'

file = MiniMagick::Image.open('input/image.jpg')

cards_across = 20
cards_down   = 20
card_width   = 70
card_height  = 28

output_mult   = 10 # Output image will be this * card_width wide, this * card_height tall
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
    x_coord = i.to_s.rjust(2, "0")
    y_coord = j.to_s.rjust(2, "0")

    front_path = "output/x#{x_coord}y#{y_coord}.front.png"
    card_front = MiniMagick::Image.open('output/output.png').crop("#{output_width}x#{output_height}+#{i * output_width}+#{j * output_height}")
    card_front.write(front_path)
    puts "Completed front x#{i} y#{j} "

    # Create the back image
    back_path = "output/x#{x_coord}y#{y_coord}.back.png"
    MiniMagick::Tool::Convert.new do |s|
      s.size "#{output_width}x#{output_height}"
      s.xc "black"
      s.font 'SourceCodePro'
      s.pointsize 96
      s.gravity 'Center'
      s.fill '#ffffff'
      s.draw "text 0,0 \"x #{x_coord} y #{y_coord}\""
      s << back_path
    end
    puts "Completed back #{i} #{j}"

    Prawn::Document.generate("output/x#{x_coord}y#{y_coord}.pdf", :margin => 0, :page_size => [output_width, output_height]) do 
      image front_path
      start_new_page
      image back_path
    end
    puts "Completed PDF #{i} #{j}"
  end
end

puts 'Complete'
