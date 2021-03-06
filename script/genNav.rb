require 'json'
require 'slugify'
require 'set'

@nav = Array.new
@allCategories = Set.new

def takeMeta(content,name)
	match = content.scan(/#{name}:[\w\-\s"\/]*?\n/)[0].gsub(/"/,"").gsub(/\n/,"")
	match = match[name.length+1,match.length-name.length-1].strip
	return match
end

def iterate(path,parent)
 	Dir.foreach(path) do |item|
		
		if !item.start_with?(".")

			navItem = Hash.new
			navItem["children"] = Array.new
			file = path + "/" + item
			if item.end_with?(".md")
				contents = File.read(file)
				title = takeMeta(contents,"title")
				category = takeMeta(contents,"categories")
				@allCategories.add(category)
				
				navItem["title"] = title
				navItem["url"] = "/" + category + "/" + item[11,item.length-14] + ".html"
				
				puts category
				puts title
				puts navItem["url"]
			else
				navItem["title"] = item
			end
			
			if parent != nil
				parent["children"].push(navItem)
			else
				@nav.push(navItem)
			end
			
			
			if File.directory?(file)
				iterate(file,navItem) 
			end
		end
	end
end

iterate('./_posts',nil)

for c in @allCategories
	File.open("category/#{c}.html","w") do |f|
  	f.write("---\n")
  	f.write("layout: category2\n")
  	f.write("title: #{c}\n")
  	f.write("category: #{c}\n")
  	f.write("---\n")
	end
end


File.open("_data/nav.json","w") do |f|
  f.write(JSON.pretty_generate(@nav))
end
