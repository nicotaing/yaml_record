require File.dirname(__FILE__) + '/test_helper'

class YamlObject < YamlRecord::Base
  properties :title, :body, :child_ids
  source File.dirname(__FILE__) + "/../tmp/yaml_object"
end

class BaseTest < Test::Unit::TestCase

  def setup
    @obj_title = "Simple Title"
    @obj_id = "1234"
    @obj2_id = "5678"
    @obj2_title = "Simple Title 2"

    @attr = {
      :child_ids  =>  [@obj_id],
      :title =>  @obj_title,
      :body => "Body!!"
    }

    @attr2 = {
      :child_ids  =>  [@obj2_id],
      :title =>  @obj2_title,
      :body => "Body!!"
    }

    clean_yaml_record(YamlObject)
    @fs = YamlObject.create(@attr)
  end

  context "for instance methods" do

    context "for [] method" do
      should("get attribute with [attribute]"){ assert_equal @fs.title, @fs[:title] }
    end

    context "for []= method" do
      setup do
        @fs[:title] = "Toto"
      end
      should("set attribute with [attribute]="){ assert_equal @fs[:title], "Toto" }
    end

    context "for save method" do
      setup do
        @fs2 = YamlObject.new(@attr)
        @fs2.save
      end

      should("save on yaml file"){ assert_equal YamlObject.last.attributes.diff(@attr), {:id => @fs2.reload.id } }
    end

    context "for update_attributes method" do
      setup do
        @fs.update_attributes(:title => "Toto", :body  => "http://somewhereelse.com")
        @fs.reload
      end
      should("update title") { assert_equal @fs.title, "Toto" }
      should("update body") { assert_equal @fs.body, "http://somewhereelse.com"  }
    end

    context "for column_names method" do
      should("return an array with attributes names") { assert_equal @fs.column_names.sort!, YamlObject.properties.map { |p| p.to_s }.sort! }
    end

    context "for persisted_attributes method" do
      should("return persisted attributes") { assert_equal [:title, :body, :child_ids, :id ].sort_by {|sym| sym.to_s}, @fs.persisted_attributes.keys.sort_by {|sym| sym.to_s} }
    end

    context "for new_record? method" do
      setup do
        @fs3 = YamlObject.new
      end
      should("be a new record") { assert @fs3.new_record? }
      should("not be a new record") { assert_false @fs.new_record? }
    end

    context "for destroyed? method" do
      setup do
        @fs4 = YamlObject.create(@attr)
        @fs4.destroy
      end
      should("be a destoyed") { assert @fs4.destroyed? }
      should("not be destroyed") { assert_false @fs.destroyed? }
    end

    context "for destroy method" do
      setup do
        @fs5 = YamlObject.create(@attr)
        @fs5.destroy
      end
      should("not find @fs5"){ assert_nil YamlObject.find(@fs5.id) }
    end

    context "for reload method" do
      setup do
        @fs.title = "Foo"
      end
      should("equal to Foo"){ assert_equal @fs.title, "Foo" }
      should("equal to correct title"){ assert_equal @fs.reload.title, @obj_title }
    end

    context "for to_param method" do
      setup { @fs.id = "a1b2c3" }

      should("return id of record") { assert_equal(@fs.to_param, @fs.id) }
    end
  end

  context "for class methods" do
    context "for self.find_by_attribute method" do
      setup do
        @fs_found = YamlObject.find_by_attribute(:title, @obj_title)
      end
      should("be same object as @fs"){ assert_equal @fs_found, YamlObject.find(@fs.id) }
    end

    context "for self.find_by_id method" do
      setup do
        @fs_found = YamlObject.find_by_id(@fs.id)
        @fs_found2 = YamlObject.find(@fs.id)
      end
      should("be same object as @fs"){ assert_equal @fs.attributes, @fs_found.attributes }
      should("be same object as @fs bis"){ assert_equal @fs.attributes, @fs_found2.attributes }
    end

    context "for self.all method" do
      setup do
        clean_yaml_record(YamlObject)
        @fs, @fs2 = YamlObject.create(@attr), YamlObject.create(@attr2)
      end
      should("retrieve 2 YamlObject obj"){ assert_equal YamlObject.all.size, 2 }
      should("return as first item @fs"){ assert_equal YamlObject.all.first.attributes, @fs.attributes }
      should("return as last item @fs2"){ assert_equal YamlObject.all.last.attributes, @fs2.attributes }
    end

    context "for self.first method" do
      setup do
        clean_yaml_record(YamlObject)
        @fs, @fs2 = YamlObject.create(@attr), YamlObject.create(@attr2)
      end

      should("return @fs as the first item"){ assert_equal YamlObject.first.attributes, @fs.attributes }
      should("return @fs"){ assert_equal YamlObject.first(2).first.attributes, @fs.attributes }
      should("return @fs2"){ assert_equal YamlObject.first(2).last.attributes, @fs2.attributes }
    end

    context "for self.last method" do
      setup do
        clean_yaml_record(YamlObject)
        @fs, @fs2 = YamlObject.create(@attr), YamlObject.create(@attr2)
      end

      should("return @fs as the first item"){ assert_equal YamlObject.last.attributes, @fs2.attributes }
      should("return @fs"){ assert_equal YamlObject.last(2).first.attributes, @fs.attributes }
      should("return @fs2"){ assert_equal YamlObject.last(2).last.attributes, @fs2.attributes }
    end

    context "for self.write_contents method" do
      setup do
        clean_yaml_record(YamlObject)
        @attributes = [ @attr, @attr2 ]
        YamlObject.write_contents(@attributes)
      end
      should("write in yaml file"){ assert_equal YAML.load_file(YamlObject.source), [ @attr, @attr2 ] }
    end

    context "for self.create method" do
      setup do
        clean_yaml_record(YamlObject)
        @fs = YamlObject.create(@attr)
        @fs_not_created = YamlObject.new(@attr)
      end
      should("create @fs"){ assert_equal YamlObject.last.attributes, @fs.attributes }
      should("set its is_created to true"){ assert @fs.is_created }
      should("set @fs_not_created is_created field  to false"){ assert_false @fs_not_created.is_created }
    end

    context "for set_id!" do
      setup do
        @fs_no_id = YamlObject.new(@attr)
        @fs_with_id = YamlObject.create(@attr)
        @id = @fs_with_id.id
        @fs_with_id.update_attributes(:title =>  "Gomiso")
      end
      should("not have any id"){ assert_nil @fs_no_id.id }
      should("have a id"){ assert @fs_with_id.id }
      should("keep the same id"){ assert_equal @fs_with_id.id, @id }
    end
  end

end
