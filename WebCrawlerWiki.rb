require 'nokogiri'
require 'open-uri'
require 'mysql2'

db = Mysql2::Client.new(:host=>"localhost",:username=>"root",:password=>"****",:database=>"actress_list");
db.query("drop table if exists list")
db.query("create table list(actress varchar(30),twitter_url varchar(60))")
# define the html url
url = "http://en.wikipedia.org/wiki/List_of_American_film_actresses"
# get the nokogiri document
doc = Nokogiri::HTML(open(url))
doc.encoding = 'utf-8'
#f = open('h:/out.txt','w')
doc.search("//div[@class='div-col columns column-width']/ul/li/a[@href and @title]").each do |tr|
  name = tr.text
  href = tr['href']
  doc2 = open('http://en.wikipedia.org'+href).read
  # for condition that have twitter link in external links
  judge1 = /https:\/\/twitter\.com\/[\w]+"/.match(doc2)
  #for condition that have not twetter link in external links
  judge2 = /twitter\.com\/[\w]+/.match(doc2)
  if judge1!=nil
    res1 = /https:\/\/twitter\.com\/[\w]+/.match(judge1[0])
    db.query("insert into list(actress,twitter_url) values(\"#{name}\",'#{res1[0]}')")
    #    puts name+"|"+res1[0]
  elsif judge2!=nil
    n = judge2.size-1
    0.upto(n) do |i|
      temp = name.gsub(/\s/,"|")
      judge3 = temp.match(judge2[i])
      if judge3!=nil
        #       puts name+"|https://"+judge2[i]
        res2 = "https://"+judge2[i]
        db.query("insert into list(actress,twitter_url) values(\"#{name}\",'#{res2}')")
        break
      elsif i>=n
        #        puts name
        db.query("insert into list(actress,twitter_url) values(\"#{name}\",'')")
      end
    end
  else
    #    puts name
    db.query("insert into list(actress,twitter_url) values(\"#{name}\",'')")
  end
end
