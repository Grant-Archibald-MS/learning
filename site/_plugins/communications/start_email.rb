module Jekyll
    class EmailStartTag < Liquid::Tag
      def render(context)
        <<-HTML
<style>
    .email-container {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 0;
        background-color: #f4f4f4;
    }
    .email-container {
        width: 600px;
        margin: 20px auto;
        background-color: #fff;
        padding: 20px;
        border: 1px solid #ddd;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    }
    .email-header {
        margin-bottom: 20px;
    }
    .email-header div {
        margin-bottom: 10px;
    }
    .email-body {
        margin-bottom: 20px;
    }
    .email-footer {
        border-top: 1px solid #ddd;
        padding-top: 10px;
        color: #555;
        font-size: 12px;
    }
</style>
<div class="email-container">
        HTML
      end
    end
  end
  
  Liquid::Template.register_tag('email_start', Jekyll::EmailStartTag)