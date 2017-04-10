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

class Pack
    pattr_initialize :version, :count, :product, :sides, :cards

    def to_json
        {'productVersion' => version, 'numCards' => count, 'productCode' => product, 'sides' => sides, 'cards' => cards}.to_json
    end
end

cardSides = [CardSide.new(1, 'image'), CardSide.new(2, 'details')]

cards = Array.new(2)
(0..99).each do |c|
    cards[c] = Card.new(c, cardSides)
end

side_data = SideData.new('fixedImageData', 'background_template', 'https://upload.wikimedia.org/wikipedia/commons/a/ae/AfricanWildCat.jpg')

sides = Array.new(2)
sides[0] = Side.new('image', 1, 'minicard_full_image_landscape', side_data)
sides[1] = Side.new('details', 2, 'minicard_full_details_image_landscape', side_data)

pack = Pack.new(1, 100, 'minicard', sides, cards)

pack_json = pack.to_json
# puts pack_json

client = OAuth2::Client.new(ENV['CLIENT_ID'], ENV['CLIENT_SECRET'], :site => 'http://www.moo.com/api/service/')
response = client.request(:post, '/api/service/?method=moo.pack.createPack&product=minicard', {:body => {'pack' => pack_json}})
puts response.body