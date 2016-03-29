require 'rails_helper'
require 'elo_calculator'

RSpec.describe EloCalculator do
  let(:elo1) { { rating: 1500, provisional: true } }
  let(:elo2) { { rating: 1500, provisional: true } }
  subject { EloCalculator.new(elo1, elo2) }

  describe '#elo_change' do
    it 'returns correct rating change for win' do
      expect(subject.elo_change(1)).to eql(15)
    end

    it 'uses k_factor' do
      elo1[:provisional] = false
      expect(subject.elo_change(1)).to eql(2.5)
    end

    it 'uses ev' do
      elo1[:rating] = 1649
      expect(subject.elo_change(0).round(1)).to eql(-21.1)
    end
  end

  describe '#ev' do
    it 'returns 0.5 when equal ratings' do
      expect(subject.ev).to eql(0.5)
    end

    it 'returns 0.7 when 149 points difference when equal ratings' do
      elo1[:rating] = 1649
      expect(subject.ev.round(2)).to eql(0.70)
    end
  end

  describe '#k_factor' do
    it 'returns 30 if provisional' do
      expect(subject.k_factor).to eql(30)
    end

    it 'returns 10 if neither is provisional' do
      elo1[:provisional] = false
      elo2[:provisional] = false
      expect(subject.k_factor).to eql(10)
    end

    it 'returns 5 if opponent is provisional' do
      elo1[:provisional] = false
      elo2[:provisional] = true
      expect(subject.k_factor).to eql(5)
    end
  end

  describe '#rating_diff' do
    it 'returns the rating difference' do
      elo2[:rating] = 1600
      expect(subject.rating_diff).to eql(100)
    end
  end
end
