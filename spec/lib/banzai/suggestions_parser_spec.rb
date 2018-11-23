require 'spec_helper'

describe Banzai::SuggestionsParser do
  describe '.parse' do
    let(:markdown) do
      <<-MARKDOWN.strip_heredoc
        ```suggestion
          foo
          bar
        ```

        ```
          nothing
        ```

        ```suggestion
          xpto
          baz
        ```

        ```thing
          this is not a suggestion, it's a thing
        ```
      MARKDOWN
    end

    it 'returns a list of suggestion contents' do
      expect(described_class.parse(markdown)).to eq(["  foo\n  bar",
                                                     "  xpto\n  baz"])
    end
  end
end
