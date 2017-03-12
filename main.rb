require 'RMagick'
include Magick

file = ImageList.new('image.jpg')
width = file.columns - 1
height =  file.rows - 1

cards_across = 20
cards_down   = 20
card_width   = 70
card_height  = 28

output_mult   = 5 # Output image will be this * card_width wide, this * card_height tall
output_width  = card_width * output_mult
output_height = card_height * output_mult

subimage_width = width / cards_across
subimage_height = height / cards_down

test_output = Image.new(cards_across * output_width, cards_down * output_height)

# Text writing
text = Draw.new
text.font_family = 'menlo'
text.pointsize = 16
text.fill = '#ffffff'
text.gravity = Magick::CenterGravity

for j in 0..cards_down - 1
  for i in 0..cards_across - 1
    subimage = file.excerpt(i * subimage_width, j * subimage_height, subimage_width, subimage_height)
    # Get pixel color
    single_pixel_subimage = subimage.scale(1, 1)
    
    color = single_pixel_subimage.get_pixels(0, 0, 1, 1).first.to_color(ComplianceType::AllCompliance, false, 8, true)

    output_image = single_pixel_subimage.scale(output_width, output_height)
    output_image.annotate(text, output_width * 0.2, output_height * 0.20, output_width * 0.7, output_height * 0.7, color)
    output_image.write("#{i}.#{j}.png")

    test_output = test_output.store_pixels(i * output_width, j * output_height, output_width, output_height, output_image.get_pixels(0, 0, output_width, output_height))
  end
end

test_output.write('output.jpg')

