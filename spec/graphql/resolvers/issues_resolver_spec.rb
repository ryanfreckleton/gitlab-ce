require 'spec_helper'

describe Resolvers::IssuesResolver do
  include GraphqlHelpers

  let(:current_user) { create(:user) }
  set(:project) { create(:project) }
  set(:issue1) { create(:issue, project: project, state: :opened, created_at: 3.hours.ago, updated_at: 3.hours.ago) }
  set(:issue2) { create(:issue, project: project, state: :closed, title: 'foo', created_at: 1.hour.ago, updated_at: 1.hour.ago, closed_at: 1.hour.ago) }
  set(:label1) { create(:label, project: project) }
  set(:label2) { create(:label, project: project) }

  before do
    project.add_developer(current_user)
    create(:label_link, label: label1, target: issue1)
    create(:label_link, label: label1, target: issue2)
    create(:label_link, label: label2, target: issue2)
  end

  describe '#resolve' do
    it 'finds all issues' do
      expect(resolve_issues).to contain_exactly(issue1, issue2)
    end

    it 'filters by state' do
      expect(resolve_issues(state: 'opened')).to contain_exactly(issue1)
      expect(resolve_issues(state: 'closed')).to contain_exactly(issue2)
    end

    it 'filters by labels' do
      expect(resolve_issues(label_name: [label1.title])).to contain_exactly(issue1, issue2)
      expect(resolve_issues(label_name: [label1.title, label2.title])).to contain_exactly(issue2)
    end

    describe 'filters by created_at' do
      it 'filters by created_before' do
        expect(resolve_issues(created_before: 2.hours.ago)).to contain_exactly(issue1)
      end

      it 'filters by created_after' do
        expect(resolve_issues(created_after: 2.hours.ago)).to contain_exactly(issue2)
      end
    end

    describe 'filters by updated_at' do
      it 'filters by updated_before' do
        expect(resolve_issues(updated_before: 2.hours.ago)).to contain_exactly(issue1)
      end

      it 'filters by updated_after' do
        expect(resolve_issues(updated_after: 2.hours.ago)).to contain_exactly(issue2)
      end
    end

    describe 'filters by closed_at' do
      let!(:issue3) { create(:issue, project: project, state: :closed, title: 'foo', closed_at: 3.hours.ago) }

      it 'filters by closed_before' do
        expect(resolve_issues(closed_before: 2.hours.ago)).to contain_exactly(issue3)
      end

      it 'filters by closed_after' do
        expect(resolve_issues(closed_after: 2.hours.ago)).to contain_exactly(issue2)
      end
    end

    it 'searches issues' do
      expect(resolve_issues(search: 'foo')).to contain_exactly(issue2)
    end

    it 'sort issues' do
      expect(resolve_issues(sort: 'created_desc')).to eq [issue2, issue1]
    end

    it 'returns issues user can see' do
      project.add_guest(current_user)

      create(:issue, confidential: true)

      expect(resolve_issues).to contain_exactly(issue1, issue2)
    end

    it 'finds a specific issue with iids' do
      expect(resolve_issues(iids: issue1.iid)).to contain_exactly(issue1)
    end

    it 'finds multiple issues with iids' do
      expect(resolve_issues(iids: [issue1.iid, issue2.iid]))
        .to contain_exactly(issue1, issue2)
    end

    it 'finds only the issues within the project we are looking at' do
      another_project = create(:project)
      iids = [issue1, issue2].map(&:iid)

      iids.each do |iid|
        create(:issue, project: another_project, iid: iid)
      end

      expect(resolve_issues(iids: iids)).to contain_exactly(issue1, issue2)
    end
  end

  def resolve_issues(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
