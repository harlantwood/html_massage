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
          <div>This is some <i>great</i> content!</div>
        </body>
      </html>
    }

    HtmlMassage.html( html )
    # => "<div>This is some <i>great</i> content!</div>"

    HtmlMassage.markdown( html )
    # => "This is some _great_ content!"

    HtmlMassage.text( html )
    # => "This is some great content!"

### Custom includes and excludes

    html = %{
      <html>
        <body>
          <div class="custom_navigation">some links to other pages...</div>
          <div>This is some <i>great</i> content!</div>
        </body>
      </html>
    }

    html_massage = HtmlMassage.new( html )
    html_massage.exclude!( [ '.custom_navigation' ] )
    html_massage.include!( [ 'body' ] )
    html_massage.to_html
    # => <div>This is some <i>great</i> content!</div>

### Sanitize HTML

    html = %{
      <html>
        <head>
          <script type="text/javascript">document.write('I am a bad script');</script>
        </head>
        <body>
          <div>This is some <i>great</i> content!</div>
        </body>
      </html>
    }

    html_massage = HtmlMassage.new( html )
    html_massage.sanitize!(  :elements => ['div'] )
    html_massage.to_html
    # => <div>This is some <i>great</i> content!</div>

### Make Links Absolute

    html = %{
      <a href ="/foo/bar.html">Click this link</a>
    }

    html_massage = HtmlMassage.new( html )
    html_massage.absolutify_links!( 'http://example.com/joe/page1.html' )
    html_massage.to_html
    #     <a href ="http://example.com/foo/bar.html">Click this link</a>

