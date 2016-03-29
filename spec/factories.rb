FactoryGirl.define do
  factory :player do
    sequence(:name) { |n| "Player#{n}" }
  end

  factory :elo do
    player
    rating 1500
    provisional true
  end

  factory :frame do
    game_type 'eight_ball'
  end
end
