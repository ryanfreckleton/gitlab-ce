# frozen_string_literal: true
require 'spec_helper'

describe Groups::SamlProvidersController, '(JavaScript fixtures)', type: :controller do
  include JavaScriptFixturesHelpers

  let(:group) { create(:group, :private) }
  let(:user) { create(:user) }

  render_views

  before(:all) do
    clean_frontend_fixtures('groups/saml_providers/')
  end

  before do
    sign_in(user)
    group.add_owner(user)
    allow(Devise).to receive(:omniauth_providers).and_return(%i(group_saml))
    stub_licensed_features(group_saml: true)
  end

  it 'groups/saml_providers/show.html.raw' do |example|
    create(:saml_provider, group: group)

    get :show, group_id: group

    expect(response).to be_success
    expect(response).to render_template 'groups/saml_providers/show'
    store_frontend_fixture(response, example.description)
  end
end