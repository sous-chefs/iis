module Windows
  module Helper
  end
end

require_relative '../../../libraries/helper'
require 'rexml/document'

class Test
  include Opscode::IIS::Helper
end

describe Opscode::IIS::Helper do
  let(:doc) do
    REXML::Document.new(xml)
  end

  shared_examples 'unchanged value' do
    it 'should return false' do
      test = Test.new
      expect(test.new_value?(doc.root, '@value', new_value)).to be_falsy
    end
  end

  describe '#new_value?' do
    context 'when attribute is nil' do
      let(:xml) { '<test/>' }
      let(:new_value) { nil }
      it_should_behave_like 'unchanged value'
    end

    context 'when attribut is "t&st"' do
      let(:xml) { '<test value="t&amp;st"/>' }
      let(:new_value) { 't&st' }
      it_should_behave_like 'unchanged value'
    end

    context 'when attribut is ""' do
      let(:xml) { '<test value=""/>' }
      let(:new_value) { '' }
      it_should_behave_like 'unchanged value'
    end
  end
end
