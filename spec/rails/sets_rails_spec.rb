describe "Parcels Rails sets support", :type => :rails do
  uses_rails_with_template :sets_rails_spec

  it "should put all normal assets into normal.css, whether explicitly inherited or via block" do
    normal = compiled_rails_asset('normal.css')

    normal.should_match(rails_assets do
      asset 'views/sets_rails_spec/normal_one.rb' do
        expect_wrapped_rule :span, 'color: blue'
      end

      asset 'views/sets_rails_spec/normal_one.pcss' do
        expect_wrapped_rule :'span.a', 'color: blue'
      end

      asset 'views/sets_rails_spec/normal_two.rb' do
        expect_wrapped_rule :em, 'color: yellow'
      end

      asset 'views/sets_rails_spec/normal_two.pcss' do
        expect_wrapped_rule :'em.a', 'color: yellow'
      end
    end)
  end

  it "should put all admin assets into admin.css, whether explicitly inherited or via block" do
    admin = compiled_rails_asset('admin.css')

    admin.should_match(rails_assets do
      asset 'views/admin/admin_one.rb' do
        expect_wrapped_rule :p, 'color: red'
      end

      asset 'views/admin/admin_one.pcss' do
        expect_wrapped_rule :'p.a', 'color: red'
      end

      asset 'views/admin/admin_two.rb' do
        expect_wrapped_rule :div, 'color: green'
      end

      asset 'views/admin/admin_two.pcss' do
        expect_wrapped_rule :'div.a', 'color: green'
      end
    end)
  end

  it "should put everything into all.css, whether explicitly inherited or via block" do
    all = compiled_rails_asset('all.css')

    all.should_match(rails_assets do
      asset 'views/sets_rails_spec/normal_one.rb' do
        expect_wrapped_rule :span, 'color: blue'
      end

      asset 'views/sets_rails_spec/normal_one.pcss' do
        expect_wrapped_rule :'span.a', 'color: blue'
      end

      asset 'views/sets_rails_spec/normal_two.rb' do
        expect_wrapped_rule :em, 'color: yellow'
      end

      asset 'views/sets_rails_spec/normal_two.pcss' do
        expect_wrapped_rule :'em.a', 'color: yellow'
      end

      asset 'views/admin/admin_one.rb' do
        expect_wrapped_rule :p, 'color: red'
      end

      asset 'views/admin/admin_one.pcss' do
        expect_wrapped_rule :'p.a', 'color: red'
      end

      asset 'views/admin/admin_two.rb' do
        expect_wrapped_rule :div, 'color: green'
      end

      asset 'views/admin/admin_two.pcss' do
        expect_wrapped_rule :'div.a', 'color: green'
      end
    end)
  end
end
