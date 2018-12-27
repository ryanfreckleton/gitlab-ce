# frozen_string_literal: true

module SnippetsUrl
  extend ActiveSupport::Concern

  private

  attr_reader :snippet

  def authorize_secret_snippet!
    if snippet&.secret?
      return if params[:secret] == snippet.secret_word

      return render_404
    end

    current_user ? render_404 : authenticate_user!
  end

  def ensure_complete_url
    redirect_to complete_url unless url_contains_secret?
  end

  def url_contains_secret?
    request.query_parameters['secret'] == snippet.secret_word
  end

  def complete_url
    @complete_url ||= begin
      url = current_url.clone
      query_hash = current_url_query_hash.clone
      query_hash['secret'] = snippet.secret_word
      url.tap do |u|
        u.query = query_hash.to_query
      end.to_s
    end
  end

  def current_url
    @current_url ||= URI.parse(request.original_url)
  end

  def current_url_query_hash
    @current_url_query_hash ||= Rack::Utils.parse_nested_query(current_url.query)
  end
end
