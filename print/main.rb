require 'attr_extras'
require 'json'
require 'uri'
require 'oauth2'

class CardSide
    pattr_initialize :side_num, :side_type
    
    def to_json(_)
        {'sideNum' => side_num, 'sideType' => side_type}.to_json
    end
end

class Card
    pattr_initialize :card_number, :card_sides

    def to_json(_)
        {'cardNum' => card_number, 'cardSides' => card_sides}.to_json
    end
end

class SideData
    pattr_initialize :type, :link, :image

    def to_json(_)
        {'type' => type, 'linkId' => link, 'resourceUri' => image}.to_json
    end
end

class Side
    pattr_initialize :type, :number, :template, :data

    def to_json(_)
        {'type' => type, 'sideNum' => number, 'templateCode' => template, 'data' => [data]}.to_json
    end
end

class ImageBasketItem
    pattr_initialize :type, :resourceUri

    def to_json(_)
        {'type' => type, 'resourceUri' => resourceUri}.to_json
    end
end

class ImageBasket
    pattr_initialize :type, :name, :immutable, :items

    def to_json(_)
        {'type' => type, 'name' => name, 'immutable' => immutable, 'items' => items}.to_json
    end
end

class Pack
    pattr_initialize :version, :count, :product, :sides, :cards, :images

    def to_json
        {'productVersion' => version, 'numCards' => count, 'productCode' => product, 'sides' => sides, 'cards' => cards}.to_json
    end
end

if !ENV['CLIENT_ID'] || !ENV['CLIENT_SECRET'] || !ENV['IMAGE_HOST']
    puts 'Set CLIENT_ID and CLIENT_SECRET env vars with MOO API values, and IMAGE_HOST with host that has images'
    exit 1
end

x_count = 10
y_count = 10
card_count = x_count * y_count
side_count = card_count * 2

images = Array.new
(1..x_count).each do |s|
    (1..y_count).each do |t|
        x_coord = s.to_s.rjust(2, "0")
        y_coord = t.to_s.rjust(2, "0")
        images << ImageBasketItem.new('print', "http://#{ENV['IMAGE_HOST']}/x#{x_coord}y#{y_coord}.front.png")
    end
end
image_basket = ImageBasket.new(nil, nil, false, images)

side_data = Array.new
(1..x_count).each do |s|
    (1..y_count).each do |t|
        x_coord = s.to_s.rjust(2, "0")
        y_coord = t.to_s.rjust(2, "0")
        side_data << SideData.new('fixedImageData', 'background_template', "http://#{ENV['IMAGE_HOST']}/x#{x_coord}y#{y_coord}.front.png")
    end
end
(1..x_count).each do |s|
    (1..y_count).each do |t|
        x_coord = s.to_s.rjust(2, "0")
        y_coord = t.to_s.rjust(2, "0")
        side_data << SideData.new('fixedImageData', 'background_template', "http://#{ENV['IMAGE_HOST']}/x#{x_coord}y#{y_coord}.back.png")
    end
end

cards = Array.new(card_count)
(1..card_count).each do |c|
    cards[c] = Card.new(c, [CardSide.new(c, 'image'), CardSide.new(card_count + c, 'details')])
end

sides = Array.new(side_count)
(1..card_count).each do |s|
    sides[s] = Side.new('image', s, 'minicard_full_image_landscape', side_data[s - 1])
    sides[card_count + s] = Side.new('details', card_count + s, 'minicard_full_details_image_landscape', side_data[card_count + s - 1])
end

pack = Pack.new(1, card_count, 'minicard', sides[1..side_count], cards[1..card_count], image_basket)

pack_json = pack.to_json
#puts pack_json

client = OAuth2::Client.new(ENV['CLIENT_ID'], ENV['CLIENT_SECRET'], :site => 'http://www.moo.com/api/service/')
response = client.request(:post, '/api/service/?method=moo.pack.createPack&product=minicard', {:body => {'pack' => pack_json}})
puts response.body