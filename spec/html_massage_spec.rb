# -*- encoding: utf-8 -*-

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'html_massage'))

describe HtmlMassager::HtmlMassage do

  include HtmlMassager

  #describe "#massage!" do
  #  pending 'should convert an HTML sample as expected'
  #
  #  it 'should leave HTML entities intact' do
  #    pending 'improve ::Node.massage_html -- handling of html entities, utf8 chars'
  #    original = "This &ldquo;branching&rdquo; of creative works"
  #    massage = HtmlMassager::HtmlMassage.new( original )
  #    massage.massage!.should == original
  #  end
  #end
  #
  #describe ".sanitize_html" do
  #  it 'should remove <style> tags and their contents' do
  #    html = %~<!-- Remix button --><br />
  #      <style type='text/css'>
  #          a.remix_on_wikinodes_tab {
  #          top: 25%; left: 0; width: 42px; height: 100px; color: #FFF; cursor:pointer; text-indent:-99999px; overflow:hidden; position: fixed; z-index: 99999; margin-left: -7px; background-image: url(http://www.openyourproject.org/images/remix_tab.png); _position: absolute; right: 0 !important; left: auto !important; margin-right: -7px !important; margin-left: auto !important; } a.remix_on_wikinodes_tab:hover { margin-left: -4px; margin-right: -4px !important; margin-left: auto !important;
  #        }
  #      </style>
  #      <p> <script type="text/javascript" language="javascript"> document.write( '<a style="background-color: #2a2a2a;" class="remix_on_wikinodes_tab" href="http://www.openyourproject.org/nodes/new?parent=' + window.location + '" title="Remix this content on WikiNodes -- creative collaboration designed to set you free" >Remix This</a>' ); </script> <noscript>Note: you can turn on Javascript to see the &#8216;Remix This&#8217; link.</noscript></p>
  #    ~
  #    html_massager = HtmlMassage.new( html )
  #    html_massager.sanitize_html!.should_not =~ /remix_on_wikinodes_tab/
  #  end
  #
  #  it 'should remove <noscript> tags and their contents' do
  #    html = %{ <noscript>Note: you can turn on Javascript to see the 'Remix This' link. </noscript> }
  #    ::Node.sanitize_html(html).should == ''
  #  end
  #end
  #
  #describe "#content_text" do
  #  it 'should convert an HTML sample as expected' do
  #    html = "
  #      <html><body>
  #      <h1>Title</h1>
  #      This is the body.
  #      Testing <a href='http://www.google.com/'>link to Google</a>.
  #      <p />
  #      Testing image <img src='/noimage.png'>.
  #      <br />
  #      The End.
  #      </body></html>
  #      "
  #    node = Factory( :node, :content => html )
  #    node.content_text.should == "Title
  #
  #      This is the body. Testing link to Google.
  #
  #      Testing image .
  #      The End.
  #      ".strip_lines! + "\n"
  #  end
  #
  #  it 'should convert a native HTML page (from Open Source Genius Club) as expected' do
  #    html = IO.read(File.join(Rails.root, 'spec/sample_data/trust_osgc.html'))
  #    text = IO.read(File.join(Rails.root, 'spec/sample_data/trust_osgc.txt'))
  #    node = Factory( :node, :content => html )
  #    node.content_text.should == text.strip_lines! + "\n"
  #  end
  #
  #  it 'should convert a native HTML page (from Open Source Mystery School) as expected' do
  #    html = IO.read(File.join(Rails.root, 'spec/sample_data/trillions_osms.html'))
  #    text = IO.read(File.join(Rails.root, 'spec/sample_data/trillions_osms.txt'))
  #    node = Factory( :node, :content => html )
  #    node.content_text.should == text.strip_lines! + "\n"
  #  end
  #
  #  it 'should remove HTML "doctype"' do
  #    html = '
  #      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
  #      <html xmlns="http://www.w3.org/1999/xhtml">
  #      <body>
  #        foobar
  #      </body>
  #      </html>
  #      '
  #    node = Factory( :node, :content => html )
  #    node.content_text.should == "foobar\n"
  #  end
  #
  #  it 'should remove <noscript> tags' do
  #    html = '
  #      <html>
  #      <body>
  #        foobar
  #        <noscript>Hm,
  #          no JS?</noscript>
  #      </body>
  #      </html>
  #      '
  #    node = Factory( :node, :content => html )
  #    node.content_text.should == "foobar\n"
  #  end
  #
  #  it 'should play nice with UTF8 HTML source' do
  #    html = '
  #      <html>
  #      <head>
  #        <meta content="text/html; charset=utf-8" http-equiv="content-type" />
  #      </head>
  #      <body>
  #        Summer is a performer → Angry, arrogant, &amp; so admired.  &nbsp;
  #      </body>
  #      </html>
  #      '
  #    node = Factory( :node, :content => html )
  #    node.content_text.should == "Summer is a performer → Angry, arrogant, & so admired.\n"
  #  end
  #
  #  context 'invalid html' do
  #    [
  #      "<html><body>foobar</body>",
  #      "<html><body>foobar</html>",
  #      "<body>foobar</body></html>",
  #      "<html>foobar</body></html>",
  #    ].each do |broken_html|
  #      it "should return 'foobar' when given #{broken_html.inspect}" do
  #        node = Factory( :node, :content => broken_html )
  #        node.content_text.should == "foobar\n"
  #      end
  #    end
  #  end
  #
  #end

  describe '.absolutify_links' do
    it 'should work for absolute path links' do
      source_url = 'http://en.wikipedia.org/wiki/Singularity'
      original_html = '<a href="/wiki/Ray_Kurzweil">Ray</a>'
      html_massager = HtmlMassage.new( original_html, :source_url => source_url )
      html_massager.absolutify_links!.should ==
          '<a href="http://en.wikipedia.org/wiki/Ray_Kurzweil">Ray</a>'
    end

    it 'should work for relative links' do
      source_url = 'http://en.wikipedia.org/wiki/Singularity'
      original_html = '<a href="../wiki/Ray_Kurzweil">Ray</a>'
      html_massager = HtmlMassage.new( original_html, :source_url => source_url )
      html_massager.absolutify_links!.should ==
          '<a href="http://en.wikipedia.org/wiki/../wiki/Ray_Kurzweil">Ray</a>'
    end

    it 'should work for relative links' do
      source_url = 'http://p2pfoundation.net/NextNet'
      original_html = '<a href="/Ten_Principles_for_an_Autonomous_Internet" title="Ten Principles for an Autonomous Internet">Ten Principles for an Autonomous Internet</a>'
      html_massager = HtmlMassage.new( original_html, :source_url => source_url )
      html_massager.absolutify_links!.should ==
          '<a href="http://p2pfoundation.net/Ten_Principles_for_an_Autonomous_Internet" title="Ten Principles for an Autonomous Internet">Ten Principles for an Autonomous Internet</a>'
    end

    it 'should leave full URLs alone' do
      source_url = 'http://en.wikipedia.org/wiki/Singularity'
      original_html = '<a href="http://www.wired.com/wiredscience">wired science</a>'
      html_massager = HtmlMassage.new( original_html, :source_url => source_url )
      html_massager.absolutify_links!.should == original_html
    end

    it 'should leave "jump links" alone' do
      source_url = 'http://en.wikipedia.org/wiki/Singularity'
      original_html = '<a href="#cite_1">1</a>'
      html_massager = HtmlMassage.new( original_html, :source_url => source_url )
      html_massager.absolutify_links!.should == original_html
    end
  end

  #describe "Old API v0.0.2 -- code sample from README" do
  #  before do
  #    html = "<html><body><div id='header'>My Site</div><div>This is some great content!</div></body></html>"
  #    @html_massage = HtmlMassage.new( html, :ignored_selectors => [ '#header' ] )
  #  end
  #
  #  it '#to_html' do
  #    @html_massage.to_html.should == "<div>This is some great content!</div>"
  #  end
  #
  #  it '#to_html' do
  #    @html_massage.to_text.should == "This is some great content!\n"
  #  end
  #end

end
