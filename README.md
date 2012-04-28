# html_massage

Give your HTML a massage, in just the ways it loves:

 * Remove headers and footers and navigation, and strip to only the "content" part of the HTML
 * Sanitize tags, removing javascript and styling
 * Convert your HTML to nicely-formatted plain text

## Sample Usage

### Full Massage

    require 'html_massage'

    html = %{
      <html>
        <head>
          <script type="text/javascript">document.write('I am a bad script');</script>
        </head>
        <body>
          <div id="header">My Site</div>
          <div>This is some great content!</div>
          <a href ="foo/bar.html">Click this link</a>
        </body>
      </html>
    }

    puts HtmlMassage.html( html )
    #

    puts HtmlMassage.text( html )
    #

### Content Only

    html_massage = HtmlMassage.new( html,
            :exclude => [ '#header' ] )
    # => #<HtmlMassager::HtmlMassage ... >

    puts html_massage.exclude!
    # <div>This is some great content!</div>
    # <a href="foo/bar.html">Click this link</a>

### Sanitize HTML

    html_massage = HtmlMassage.new( html,
            :exclude => [ '#header' ] )
    # => #<HtmlMassager::HtmlMassage ... >

    puts html_massage.sanitize_html!
    # <html>
    #   <head>
    #   </head>
    #   <body>
    #     <div id="header">My Site</div>
    #     <div>This is some great content!</div>
    #   </body>
    # </html>

### Make Links Absolute

    html_massage = HtmlMassage.new( html,
            :exclude => [ '#header' ],
            :source_url => 'http://example.com/joe/page1.html' )

    puts html_massage.absolutify_links!
    # <html>
    #   <head>
    #     <script type="text/javascript">document.write('I am a bad script');</script>
    #   </head>
    #   <body>
    #     <div id="header">My Site</div>
    #     <div>This is some great content!</div>
    #     <a href ="http://example.com/joe/foo/bar.html">Click this link</a>
    #   </body>
    # </html>

