require 'json'
require 'slugify'

@nav = Array.new

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
				
				navItem["title"] = title
				navItem["url"] = "/" + category + "/" + title.gsub(/\//,"-").slugify + ".html"
				
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

puts @nav

File.open("_data/nav.json","w") do |f|
  f.write(JSON.pretty_generate(@nav))
end
