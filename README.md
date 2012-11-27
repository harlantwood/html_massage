# HTML Massage

[![Build Status](https://secure.travis-ci.org/harlantwood/html_massage.png)](https://travis-ci.org/harlantwood/html_massage)

## Summary

 * Remove headers and footers and navigation, and strip to only the "content" part of the HTML
 * Sanitize tags, removing javascript and styling
 * Convert your HTML to markdown, plain text, or sanitized HTML

## Massaging from the command line

    html_massage html https://en.wikipedia.org/wiki/Technological_singularity > singularity.html
    html_massage text https://en.wikipedia.org/wiki/Technological_singularity > singularity.txt
    html_massage markdown https://en.wikipedia.org/wiki/Technological_singularity > singularity.md

These files will look something like:

    ==> singularity.html <==
    <h1 id="firstHeading" class="firstHeading"><span dir="auto">Technological singularity</span></h1>
    <p>The <b>technological singularity</b> is the theoretical emergence of greater-than-human <a href="/wiki/Superintelligence" title="Superintelligence">superintelligence</a> through technological means.<sup id="cite_ref-1" class="reference"><a href="#cite_note-1"><span>[</span>1<span>]</span></a></sup> Since the capabilities of such intelligence would be difficult for an unaided human mind to comprehend, the occurrence of a technological singularity is seen as an intellectual <a href="/wiki/Event_horizon" title="Event horizon">event horizon</a>, beyond which events cannot be predicted or understood.</p>
    ...

    ==> singularity.md <==
    # Technological singularity
    The **technological singularity** is the theoretical emergence of greater-than-human [superintelligence](https://en.wikipedia.org/wiki/Superintelligence "Superintelligence") through technological means. [1] Since the capabilities of such intelligence would be difficult for an unaided human mind to comprehend, the occurrence of a technological singularity is seen as an intellectual [event horizon](https://en.wikipedia.org/wiki/Event_horizon "Event horizon") , beyond which events cannot be predicted or understood.
    ...

    ==> singularity.txt <==
    Technological singularity
    The technological singularity is the theoretical emergence of greater-than-human superintelligence through technological means.[1] Since the capabilities of such intelligence would be difficult for an unaided human mind to comprehend, the occurrence of a technological singularity is seen as an intellectual event horizon, beyond which events cannot be predicted or understood.
    ...

## Massaging from Ruby

### Full Massage

* Use default whitelist of tags and attributes to sanitize HTML
* Use default selectors (both include and exclude lists) to attempt to capture only the "content" part of the HTML page

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



