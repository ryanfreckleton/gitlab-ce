# frozen_string_literal: true

require 'spec_helper'

describe Ci::BuildAnnotation do
  def annotation(*args)
    described_class.new(*args).tap do |annotation|
      annotation.validate
    end
  end

  describe 'when validating the severity' do
    it 'produces an error if it is missing' do
      expect(annotation.errors[:severity]).not_to be_empty
    end
  end

  describe 'when validating the CI build ID' do
    it 'produces an error if it is missing' do
      expect(annotation.errors[:build_id]).not_to be_empty
    end
  end

  describe 'when validating the summary' do
    it 'produces an error if it is missing' do
      expect(annotation.errors[:summary]).not_to be_empty
    end

    it 'produces an error if it exceeds the maximum length' do
      expect(annotation(summary: 'a' * 1024).errors[:summary]).not_to be_empty
    end

    it 'does not produce an error if it is valid' do
      expect(annotation(summary: 'a').errors[:summary]).to be_empty
    end
  end

  describe 'when validating the line number' do
    it 'produces an error if it is zero' do
      expect(annotation(line_number: 0).errors[:line_number]).not_to be_empty
    end

    it 'produces an error if it is negative' do
      expect(annotation(line_number: -1).errors[:line_number]).not_to be_empty
    end

    it 'produces an error if it is too great' do
      expect(annotation(line_number: 40_000).errors[:line_number])
        .not_to be_empty
    end

    it 'produces an error if the file path is not present' do
      expect(annotation(line_number: 1).errors[:file_path]).not_to be_empty
    end

    it 'does not produce an error if it is valid' do
      row = annotation(line_number: 1, file_path: 'foo.rb')

      expect(row.errors[:line_number]).to be_empty
      expect(row.errors[:file_path]).to be_empty
    end

    it 'does not produce an error if it and the file path are not given' do
      row = annotation

      expect(row.errors[:line_number]).to be_empty
      expect(row.errors[:file_path]).to be_empty
    end
  end

  describe 'when validating the file path' do
    it 'produces an error if the line number is not present' do
      expect(annotation(file_path: 'foo.rb').errors[:line_number])
        .not_to be_empty
    end

    it 'does not produce an error if it is valid' do
      row = annotation(line_number: 1, file_path: 'foo.rb')

      expect(row.errors[:file_path]).to be_empty
      expect(row.errors[:line_number]).to be_empty
    end
  end
end
