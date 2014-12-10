describe "Parcels Rails support with compression enabled", :type => :rails do
  uses_rails_with_template :compression_rails_spec

  it "should still seem to contain our inline and alongside CSS" do
    asset = compiled_rails_asset('application.css')
    source = asset.source

    expect(source).to match(/.parcels_class__views__compression_rails_spec__inline_and_alongside_css\s+div{color:blue}/i)
    expect(source).to match(/.parcels_class__views__compression_rails_spec__inline_and_alongside_css\s+p{color:green}/i)
  end
end
