module ActiveAdmin
  module Views
    # Renders the index block's content exactly once, with no <table>/<tr>
    # wrapper — for index pages built entirely from a custom partial that
    # handles its own collection querying, filtering and pagination.
    #
    # `index do ... end` defaults to `as: :table` (ActiveAdmin::Views::IndexAsTable),
    # which always builds a real <table> and one (possibly empty) <tr> per
    # record regardless of whether the block calls `column`. Dumping raw
    # partial HTML inside that table via `render partial:` produces invalid
    # markup (div/table nested inside <tbody>) that browsers silently "fix"
    # by hoisting content around, which caused layout/overflow bugs.
    #
    # Usage:
    #   index as: :content do
    #     render partial: "active_admin/my_custom_index"
    #   end
    class IndexAsContent < ActiveAdmin::Component
      def build(page_presenter, collection)
        instance_exec(&page_presenter.block)
      end

      def self.index_name
        "content"
      end
    end
  end
end
