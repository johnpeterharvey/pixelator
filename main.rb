require 'mini_magick'

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

output_mult   = 1 # Output image will be this * card_width wide, this * card_height tall
output_width  = card_width * output_mult
output_height = card_height * output_mult

subimage_width = file.width / cards_across
subimage_height = file.height / cards_down

p "Input image width #{file.width} height #{file.height}"
p "Subimage width #{subimage_width} height #{subimage_height}"
p "Mapped to output width #{output_width} height #{output_height}"

# MiniMagick::Tool::Convert.new do |s|
#   s.size "#{cards_across * output_width}x#{cards_down * output_height}"
#   s.xc "white"
#   s << "output/output.png"
# end
# output = MiniMagick::Image.new('output/output.png')

for j in 0..cards_down - 1
  for i in 0..cards_across - 1
    subimage_front = MiniMagick::Image.open('image.jpg').crop("#{subimage_width}x#{subimage_height}+#{i * subimage_width}+#{j * subimage_height}")
    # Get pixel color
    subimage_front.scale('1x1')
    color = subimage_front.pixel_at(0, 0)
    # Scale up to output size
    subimage_front.scale("#{[output_width, output_height].max}").crop("#{output_width}x#{output_height}+0+0")
    
    p "Writing front x#{i} y#{j}"
    subimage_front.write("output/x#{i.to_s.rjust(2, "0")}y#{j.to_s.rjust(2, "0")}.front.png")
    
    # Create the blank image for the background
    # MiniMagick::Tool::Convert.new do |s|
    #   s.size "#{output_width}x#{output_height}"
    #   s.xc "black"
    #   s << "output/#{i}.#{j}.back.png"
    # end

    # Add text to the back image and write the file out
    # p "Writing back #{i} #{j}"
    # MiniMagick::Image.new("output/#{i}.#{j}.back.png") do |s|
    #   s.font 'Helvetica'
    #   s.pointsize 40
    #   s.gravity 'Center'
    #   s.fill '#ffffff'
    #   s.draw "text 0,0 #{color}"
    #   s.write("output/#{i}.#{j}.back.png")
    # end
  
    # Add to the large output image
    # MiniMagick::Image.new('output/output.png').append("output/#{i}.#{j}.back.png").write('output/output.png')

    #test_output = test_output.store_pixels(i * output_width, j * output_height, output_width, output_height, output_image)
  end
end

# test_output.write('output/output.png')

