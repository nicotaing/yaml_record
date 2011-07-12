# YAML RECORD #

## Introduction ##

YAML Record allows you to persist data to a yaml file and manage it with activemodel API

## Installation ##

    gem install yaml_record
    
## Usage ##

To use YAML Record add gem to your Gemfile

    # Gemfile
    gem 'yaml_record'
    
Next define your YAML Record class 
    
    class Post < YamlRecord::Base
      # Declare your properties
      properties :title, :body, :user_id
      
      # Declare source file path
      source Rails.root.join("config/posts")
    end
    
Use as any activerecord object.

Retrieve all items:

    Post.all => [@p1, @p2]
    
Retrieve item by ID:

    Post.find("a1b2") => @p1
    
Retrieve by attribute

    Post.find_by_attribute(:title, "some title") => @p
    
Initialize post:

    @p = Post.new(:title => "...", :body => "...", :user_id => 5)
    
Save post:

    @p.save
    # or Post.create(:title => "...", :body => "...", :user_id => 5)
    
Access attributes

    @p = Post.find("a1b2")
    @p.title => "..."
    
Assign attributes 

    @p.title = "new title"

Update attributes

    @p.update_attributes(:title => "new title")
    
Destroy record

    @p.destroy

## Contributors ##

Created at Miso by Nico Taing and Nathan Esquenazi

Contributors are welcome!

## License ##

YAML Record is Copyright © 2011 Nico Taing, Miso. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.