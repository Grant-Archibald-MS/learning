module Jekyll
    class EmailEndTag < Liquid::Tag
      def initialize(tag_name, markup, tokens)
        super
        @days_offset = markup.strip.empty? ? -1 : markup.strip.to_i
      end
  
      def render(context)
        <<-HTML
</div>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        var date = new Date();
        date.setHours(date.getHours() - 1); // Default to now - 1 hour
        date.setDate(date.getDate() + #{@days_offset}); // Adjust by days offset
        var formattedDate = date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
        document.getElementById('email-date').innerText = formattedDate;
    });
</script>
        HTML
      end
    end
  end
  
  Liquid::Template.register_tag('email_end', Jekyll::EmailEndTag)