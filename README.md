# YAML RECORD #

## Introduction ##

YAML Record is a data persistence library that complies with the ActiveModel API. Using YAMLRecord should be familiar to anyone that has used ActiveRecord before to manage your database. Using this library, the data is persisted in a YAML backed file.

## Rationale ##

*Why a YAML-based persistence store?* In certain situations, there are collections of simple data in which there are very few records which are by nature infrequently accessed and that are ideally able to be scanned easily within a text file. These can include a simple contact form, landing page interest, feedback forms, surveys, team pages, etc where there is simply no need for the overhead of a fully persisted database solution.

There are many cases where YAMLRecord is **not the correct** persistence strategy. Any collection that is going to have substantial number of records, will be frequently updated, or is accessible by a large volume of users should not be stored in a YAML text file for obvious reasons. However, for specific cases, the convenience of storing things in a simple text file becomes apparent. Being able to access the text file data as if the records were in a familiar database ORM has many conveniences and advantages such as keeping the controllers standard and leveraging existing ORM knowledge.

## Installation ##

Install using rubygems:

```bash
gem install yaml_record
```

Or add gem to your Gemfile:

```ruby
# Gemfile
gem 'yaml_record'
# OR if you're using Rails 3.1
gem 'yaml_record', :git => "git@github.com:Nico-Taing/yaml_record.git", :branch => "rails31"
```

## Usage ##

### Declaration ###

Create any ruby object and inherit from `YamlRecord:Base` to define a type:

```ruby
class Post < YamlRecord::Base
  # Declare your properties
  properties :title, :body, :user_id

  # Declare your adapter (local by default)
  adapter :local # or :redis
  
  # Declare source file path
  source Rails.root.join("config/posts")
end
```

Use this new object the same way as any ActiveRecord object.

### Retrieval ###

Retrieve the collection:

    Post.all => [@p1, @p2]

Retrieve item by id:

    Post.find("a1b2") => @p1

Retrieve by attribute:

    Post.find_by_attribute(:title, "some title") => @p

### Create ###

Initialize post:

    @p = Post.new(:title => "...", :body => "...", :user_id => 5)
    @p.save

Create post:

    @p = Post.create(:title => "...", :body => "...", :user_id => 6)

### Update ###

Update attributes using the expected method:

    @p.update_attributes(:title => "new title")

### Destroy ###

Destroy a given record:

    @p.destroy

### Access ###

Access attributes:

    @p = Post.find("a1b2")
    @p.title => "..."

Assign attributes:

    @p.title = "new title"
    @p.save

### Callbacks ###

Create callbacks:

```ruby
class Submission < YamlRecord::Base
  # ...
  before_create :do_something # or before_save, before_destroy, ...

  def do_something
    # something here
  end
end
```

## Storage Adapters ##

YAMLRecord supports pluggable storage adapters that control the storage engine used for the YAML data. By default, the adapter used is the 
`local` store which writes a file (specified by `source` path) to the local system. There are currently two available adapters: `Local` and `Redis`. 

To configure the adapter, you can simply declare within the object:

```ruby
class Submission < YamlRecord::Base
  adapter :redis, $redis # Second parameter is the redis client instance
  source "contacts" # stores yaml namespaced as 'yaml_record:contacts' in redis
end
```

Each storage adapter only defines a `read` and `write` interface and is easy to create. 
Checkout the [redis adapter](https://github.com/Nico-Taing/yaml_record/blob/master/lib/yaml_record/adapters/redis_store.rb) for an example of how simple they are to define.
Feel free to create additional adapters and send them to us via a pull request.

## Example ##

Imagine a simple contact form that accepts a name and email from a user along with a body:

```ruby
class Submission < YamlRecord::Base
  # Declare your properties
  properties :name, :email, :body

  # Declare your adapter (local by default)
  adapter :local # or :redis
  
  # Declare source file path (config/contact.yml)
  source Rails.root.join("config/contact")
end
```

Once we define the Contact model, we can setup a controller and form just the same as in ActiveRecord:

```ruby
class SubmissionsController < AC::Base
  def create
    @submission = Submission.create(params[:submission])
  end

  def index
    @submissions = Submission.all
  end

  def show
    @submission = Submission.find(params[:id])
  end

  def update
    @submission = Submission.find(params[:id])
    @submission.update_attributes(params[:submission])
  end

  def destroy
    @submission = Submission.find(params[:id])
    @submission.destroy
  end
end
```

As you can see the controller appears the same as any ActiveRecord controller would and this makes managing the YAML data easy and convenient. You can even define callbacks in your object as you would in ActiveRecord:

```ruby
class Submission < YamlRecord::Base
  # ...
  before_create :do_something # or before_save, before_destroy, ...

  def do_something
    # something here
  end
end
```

And that's all! Each record will be persisted to the source file for easy access.

## Issues ##

 * Validations should be supported `validates_presence_of :name`
 * Property type declarations should be available `property :age, Integer`

## Contributors ##

Created at Miso by Nico Taing and Nathan Esquenazi

Special thanks to [Vaudoc](https://github.com/vaudoc)

Contributors and patches are welcome! Please send a pull request!

## Notes ##

There is already an excellent project for YAML persistence if you are using [Datamapper](https://github.com/datamapper/dm-yaml-adapter). In the situation in which we were using DM and [Padrino](http://padrinorb.com), this would surely be a better choice. But if you are using ActiveRecord and Rails, this library is a lightweight and standalone solution.

## License ##

YAML Record is Copyright © 2011 Nico Taing, Miso. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
