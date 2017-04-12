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

side_data = Array.new
(1..10).each do |s|
    (1..10).each do |t|
        side_data << SideData.new('fixedImageData', 'background_template', "http:///x#{s}y#{t}.front.png")
    end
end
(1..10).each do |s|
    (1..10).each do |t|
        side_data << SideData.new('fixedImageData', 'background_template', "http:///x#{s}y#{t}.back.png")
    end
end

cards = Array.new(100)
(1..100).each do |c|
    cards[c] = Card.new(c, [CardSide.new(c, 'image'), CardSide.new(100 + c, 'details')])
end

sides = Array.new(200)
(1..100).each do |s|
    sides[s] = Side.new('image', s, 'minicard_full_image_landscape', side_data[s - 1])
    sides[100 + s] = Side.new('details', 100 + s, 'minicard_full_details_image_landscape', side_data[100 + s - 1])
end

pack = Pack.new(1, 100, 'minicard', sides[1..200], cards[1..100])

pack_json = pack.to_json
#puts pack_json

client = OAuth2::Client.new(ENV['CLIENT_ID'], ENV['CLIENT_SECRET'], :site => 'http://www.moo.com/api/service/')
response = client.request(:post, '/api/service/?method=moo.pack.createPack&product=minicard', {:body => {'pack' => pack_json}})
puts response.body