require 'spec_helper'

describe Gitlab::DiscussionsDiff::HighlightCache, :clean_gitlab_redis_cache do
  describe '#write_multiple' do
    it 'sets multiple keys' do
      mapping = { 'foo' => 10, 'bar' => 20 }

      described_class.write_multiple(mapping)

      mapping.each do |key, value|
        full_key = described_class.cache_key_for(key)
        found = Gitlab::Redis::Cache.with { |r| r.get(full_key) }

        expect(found).to eq(value.to_s)
      end
    end
  end

  describe '#read_multiple' do
    it 'reads multiple keys' do
      mapping = { 'foo' => 10, 'bar' => 20 }

      described_class.write_multiple(mapping)

      found = described_class.read_multiple(mapping.keys)

      expect(found).to eq(%w(10 20))
    end
  end
end
