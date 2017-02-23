require 'spec_helper'

module Liquid
  module Rails
    describe MiscFilter do
      let(:context) { ::Liquid::Context.new }
      let(:parse_context) { ParseContext.new({}) }

      context '#index' do
        it 'returns value at the specified index' do
          context['array'] = [1, 2, 3]
          expect(::Liquid::Variable.new("array | index: 0", parse_context).render(context)).to eq(1)
        end

        it 'returns nil when outside range' do
          context['array'] = [1, 2, 3]
          expect(::Liquid::Variable.new("array | index: 5", parse_context).render(context)).to eq(nil)
        end
      end

      it '#jsonify' do
        context['listing'] = { name: 'Listing A' }
        expect(::Liquid::Variable.new("listing | jsonify", parse_context).render(context)).to eq(%|{"name":"Listing A"}|)
      end
    end
  end
end
