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

output_mult   = 20 # Output image will be this * card_width wide, this * card_height tall
output_width  = card_width * output_mult
output_height = card_height * output_mult

subimage_width = file.width / cards_across
subimage_height = file.height / cards_down

p "Input image width #{file.width} height #{file.height}"
p "Subimage width #{subimage_width} height #{subimage_height}"
p "Mapped to output width #{output_width} height #{output_height}"

test_output = MiniMagick::Image.new(cards_across * output_width, cards_down * output_height)

# Text writing
# text = MiniMagick::Draw.new
# text.font_family = 'menlo'
# text.pointsize = 54
# text.fill = '#ffffff'
# text.gravity = Magick::CenterGravity

for j in 0..cards_down - 1
  for i in 0..cards_across - 1
    subimage = MiniMagick::Image.open('image.jpg').crop("#{subimage_width}x#{subimage_height}+#{i * subimage_width}+#{j * subimage_height}")
    # Get pixel color
    subimage.scale('1x1')
    color = subimage.pixel_at(0, 0)
    # Scale up to output size
    subimage.scale("#{output_width}x#{output_height}")
    # output_image.annotate(text, output_width * 0.2, output_height * 0.2, output_width * 0.7, output_height * 0.7, color)
    subimage.annotate('')

    p "Writing #{i} #{j}"
    subimage.write("output/#{i}.#{j}.png")

    #test_output = test_output.store_pixels(i * output_width, j * output_height, output_width, output_height, output_image)
  end
end

# test_output.write('output/output.png')

