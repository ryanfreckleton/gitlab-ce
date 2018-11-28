# frozen_string_literal: true

require 'spec_helper'

describe Banzai::Filter::SuggestionFilter do
  include FilterSpecHelper

  it 'includes `js-render-suggestion` class' do
    input = "<pre class='code highlight js-syntax-highlight suggestion'><code>foo\n</code></pre>"

    doc = filter(input)
    result = doc.css('code').first

    expect(result[:class]).to include('js-render-suggestion')
  end

  it 'includes no `js-render-suggestion` when feature disabled' do
    stub_feature_flags(diff_suggestions: false)

    input = "<pre class='code highlight js-syntax-highlight suggestion'><code>foo\n</code></pre>"

    doc = filter(input)
    result = doc.css('code').first

    expect(result[:class]).to be_nil
  end
end
