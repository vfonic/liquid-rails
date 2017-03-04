module Liquid
  module Rails
    module PaginateFilter
      def default_pagination(paginate)
        html = []
        html << %(<span class="prev"><a href="#{paginate['previous']['url']}" rel="prev">#{paginate['previous']['title']}</a></span>) if paginate['previous']

        for part in paginate['parts']
          if part['is_link']
            html << %(<span class="page"><a href="#{part['url']}">#{part['title']}</a></span>)
          elsif part['title'].to_i == paginate['current_page'].to_i
            html << %(<span class="page current">#{part['title']}</span>)
          else
            html << %(<span class="deco">#{part['title']}</span>)
          end
        end

        html << %(<span class="next"><a href="#{paginate['next']['url']}" rel="next">#{paginate['next']['title']}</a></span>) if paginate['next']
        html.join(' ')
      end
    end
  end
end

Liquid::Template.register_filter(Liquid::Rails::PaginateFilter)
