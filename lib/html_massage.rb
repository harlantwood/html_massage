require "cgi"
require "nokogiri"
require "sanitize"
require "reverse_markdown"
require "charlock_holmes"
require File.expand_path File.join(File.dirname(__FILE__), "html_massage", "version")

module HtmlMassager

  class HtmlMassage

    INCLUDE_CONTENT_ONLY = %w[
      html
      body
    ]

    DEFAULT_EXCLUDE_OPTIONS = [
      # general:
      'head',
      'title',
      'meta',

      'div#header',
      'div.header',
      'div#banner',
      'div.banner',
      '.footer',
      '#footer',
      'div#navigation',
      'div.navigation',
      'div#nav',
      'div.nav',
      'div#sidebar',
      'div.sidebar',
      '#breadcrumbs',
      '.breadcrumbs',
      '#backfornav',
      '.backfornav',
      'div.post-footer',
      'div.navigation',

      # wordpress:
      'a#left_arrow',
      'a#right_arrow',
      'div#comments',
      'div#comment-section',
      'div#respond',

      # typepad
      '#pagebody > #pagebody-inner > #alpha',
      'p.content-nav',

      # blog widgets
      '.widget_blog_subscription',
      '.loggedout-follow-normal',


      # wikipedia

      '#bodyContent > #siteSub',
      '#bodyContent > #contentSub',
      '#bodyContent > #jump-to-nav',
      'table.metadata',
      'table.navbox',
      'table.toc',
      'div#catlinks',
      'div.printfooter',
      'h1 > span.editsection',
      'h2 > span.editsection',
      'h3 > span.editsection',
      'h4 > span.editsection',
      'h5 > span.editsection',
      'h6 > span.editsection',

      # wikipedia "message boxes" -- metadata such as "requires cleanup":
      # see http://en.wikipedia.org/wiki/Template:Ambox
      'table.ambox',
      'table.tmbox',
      'table.imbox',
      'table.cmbox',
      'table.ombox',
      'table.fmbox',
      'table.dmbox',

      # mediawiki
      '#mw-subcategories',
      '#mw-pages',
      '#mw-head',
      '#mw-panel',

      # social media sharing:
      'ul#sharebar',
      'ul#sharebarx',
      '.sharedaddy',
      '#sharing_email',

      # signup:
      '#mailchimp_signup_bottom',
    ]

    DEFAULT_SANITIZE_OPTIONS = {
              :elements => %w[
                  a abbr acronym address area b big
                  blockquote br button caption center cite
                  code col colgroup dd del dfn dir
                  div dl dt em fieldset form h1
                  h2 h3 h4 h5 h6 hr i
                  img
                  input ins kbd label legend li map menu
                  ol optgroup option p pre q s samp
                  select small span strike strong sub
                  sup table tbody td textarea tfoot th
                  thead tr tt u ul var
              ],
              :attributes => {
                  'a' => %w[ href ],
                  'img' => %w[ src ],
                  :all => %w[
                    abbr accept accept-charset
                    accesskey action align alt axis
                    border cellpadding cellspacing char
                    charoff class charset checked cite
                    clear cols colspan color
                    compact coords datetime dir
                    disabled enctype for frame
                    headers height hreflang
                    hspace id ismap label lang
                    longdesc maxlength media method
                    multiple name nohref noshade
                    nowrap prompt readonly rel rev
                    rows rowspan rules scope
                    selected shape size span
                    start summary tabindex target
                    title type usemap valign value
                    vspace width
                  ]
              },

              # medium permissive list:
              #:elements => [
              #    'a', 'b', 'blockquote', 'br', 'code', 'dd', 'del', 'dl', 'dt',
              #    'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'hr', 'i',
              #    'img', 'ins', 'li', 'ol', 'p', 'pre', 'small', 'strike', 'strong', 'sub',
              #    'sup', 'table', 'tbody', 'td', 'th',
              #    'thead', 'tr', 'u', 'ul',
              #],

              :protocols => {
                  'a' => {'href' => ['http', 'https', 'mailto', :relative]},
                  'img' => {'src' => ['http', 'https', :relative]}
              },

              # Consider including for deprecated/historical or spam-suspect pages:
              #
              #        :add_attributes => {
              #            'a' => {'rel' => 'nofollow'}
              #        }
              #
              # Gollum has a nice way to add this to your config optionally, see:
              # https://github.com/github/gollum/blob/master/lib/gollum/sanitization.rb
          }

    DEFAULTS = {
            :include => INCLUDE_CONTENT_ONLY,
            :exclude => DEFAULT_EXCLUDE_OPTIONS,
            :sanitize => DEFAULT_SANITIZE_OPTIONS,
            :links => :unchanged,
    }

    def self.html( html, options={} )
      new( html ).massage!( options ).to_html
    end

    def self.text( html, options={} )
      new( html ).massage!( options ).to_text
    end

    def self.markdown( html, options={} )
      ReverseMarkdown.convert( self.html( html, options ) )
    end

    def initialize( html )
      @html = html.dup
      detection = CharlockHolmes::EncodingDetector.detect( html ) rescue nil
      if detection
        utf8_html = CharlockHolmes::Converter.convert html, detection[:encoding], "UTF-8"
        @html = utf8_html
      end
    end

    def massage!( options={} )
      self.class.translate_old_options( options )
      options = DEFAULTS.merge( options )
      source_url = options.delete( :source_url )
      absolutify_links!(source_url)  if options.delete( :links  ) == :absolute
      absolutify_images!(source_url) if options.delete( :images ) == :absolute
      include!( options.delete( :include ) )
      exclude!( options.delete( :exclude ) )
      sanitize!( options.delete( :sanitize ) )
      tidy_whitespace!
      raise "Unexpected options #{options.inspect}" unless options.empty?
      self
    end

    def self.translate_old_options( options )
      options[ :exclude ] = options.delete( :ignored_selectors ) if options[ :ignored_selectors ]
    end

    def exclude!( selectors_to_exclude )
      doc = Nokogiri::HTML( @html )
      selectors_to_exclude.to_a.each do |selector_to_exclude|
        ( doc / selector_to_exclude ).remove
      end
      @html = doc.inner_html
    end

    def include!( selectors_to_include )
      section = Nokogiri::HTML( @html )
      selectors_to_include.to_a.each do |selector_to_include|
        subsection = section / selector_to_include
        section = subsection unless subsection.empty?
      end
      @html = section.inner_html
    end

    def sanitize!( sanitize_options={} )
      # Sanitize does not thoroughly remove these tags -- so we do a manual pass:
      %w[ script noscript style ].each do |tag|
        unless sanitize_options[ :elements ] && sanitize_options[ :elements ].include?( tag )
          @html.gsub!( %r{<#{tag}[^>]*>.*?</#{tag}>}mi, '' )
        end
      end

      @html = Sanitize.clean( @html, sanitize_options )
    end

    def absolutify_links!(source_url)
      absolutify_paths!('a', 'href', source_url)
    end

    def absolutify_images!(source_url)
      absolutify_paths!('img', 'src', source_url)
    end

    def absolutify_paths!(tag_name, attr, source_url)
      raise "When asking for absolute images or paths, please pass in source_url" unless source_url
      match = source_url.match( %r{(^[a-z]+?://[^/]+)(/.+/)?}i )
      return @html unless match
      base_url = match[ 1 ]
      resource_dir_url = match[ 0 ]   # whole regexp match
      dom = Nokogiri::HTML.fragment( @html )

      tags = dom / tag_name
      tags.each do |tag|
        value = tag[ attr ]
        if value
          tag[ attr ] =
            case value
              when %r{^//}  # eg src="//upload.wikimedia.org/wikipedia/Map.png"
                value
              when %r{^/}
                File.join( base_url, value )
              when %r{^\.\.}
                File.join( resource_dir_url, value )
              else
                value
            end
        end
      end

      @html = dom.to_s.strip
    end

    def tidy_whitespace!
      @html = strip_lines(@html)
      tidy_tables!
    end

    def tidy_tables!
      @html.gsub!(%r{(<table\b)(.+?)(</table>)}m) { open,body,close=$1,$2,$3; open + body.gsub(/\n{2,}/, "\n") + close }
    end

    def to_text
      text = CGI.unescapeHTML( @html )

      # normalize newlines
      text.gsub!(/\r\n/, "\n")
      text.gsub!(/\r/, "\n")

      # nbsp => ' '
      text.gsub!(/&nbsp;/, ' ')

      # TODO: figure out how to do these in ruby 1.9:
      # They now throw 'incompatible encoding -- ascii regexp for utf8 string'
      #    text.gsub!( /\302\240/, ' ' )  # UTF8 for nbsp
      #    text.gsub!( /\240/, ' ' )      # ascii for nbsp

      text.gsub!(/\s+/, ' ')   # all whitespace, including newlines, becomes a single space

      # replace some tags with newlines
      text.gsub!(%r{<br(\s[^>]*)?/?>}i, "\n")
      text.gsub!(%r{<p(\s[^>]*)?/?>}i, "\n\n")
      text.gsub!(%r{</(h\d|p|div|ol|ul)[^>]*>}i, "\n\n")

      # replace some tags with meaningful text markup
      text.gsub!(/<hr[^>]*>/i, "\n\n-------------------------\n\n")
      text.gsub!(/<li[^>]*>/i, "\n* ")

      # remove some tags and their inner html
      text.gsub!(%r{<noscript\b.*?</noscript>}i, '')

      # strip out all remaining tags
      text.gsub!(/<[^>]+>/, '')

      # normalize whitespace
      text.gsub!(/ +/, ' ')
      text = strip_lines(text)
      text.gsub!( /\n{3,}/, "\n\n" )
      text.strip!

      "#{text}\n"
    end

    def strip_lines(content)
      lines = content.split( $/ )    # $/ is the current ruby line ending, \n by default
      lines.map!{ |line| line.strip }
      processed = lines.join( $/ )
      processed.strip
    end


    def to_html
      @html.strip!
      @html
    end

  end

end

include HtmlMassager
