module ApplicationHelper

  def display_sex s
    
    return (s == 1) ? "Male" : ((s == 0) ? 'Female' : 'Undetermined')
  end
  
  def display_user u, ou
    html = ''
    if u
      html = (u.username and !u.username.strip.empty?) ? u.username : ((ou and ou.name) ? (ou.name + " <span class='nowrap'>" + image_tag('orcid.svg', :width => '20px') + " <i>" + link_to(ou.key, "https://orcid.org/#{ou.key}") + "</i></span>") : 'Anonymous')
    else
      html = 'Deleted user'
    end
    return html
  end

  def display_assertion assertion, assertion_type
    
    index = -1
    html = assertion.content.gsub(/\#link[^\s]*|\#doi[^\s]*|\#[\d\w\-_:\/\|]+/){|s|
     index+=1
     display_tag(s, Regexp.last_match.begin(0), index, Basic.safe_parse_json(assertion.all_tags_json, []), assertion_type)
     }
    return html
  end
  
  def display_tag match, pos, index, all_tags, assertion_type
    tag = all_tags[index]
    html = ''
    if tag and match[-1] != '!' #and tag['label'][-1] != '!'
      if tag['type'] == 'gene'
        html = "<span class='badge badge-tag #{assertion_type.badge_tag_classes} gene_tag gene-id_" + ((tag['id']) ? tag['id'] : '') + "'>" + (tag['label'] || 'NO_LABEL') + "</span>"
        #<sup><a class='text-light' href='https://flybase.org/reports/" + tag['val'] + "'><i class='fa fa-link'></i></a></sup>"
      elsif tag['type'] == 'tag'
        html = "<span class='badge badge-tag #{assertion_type.badge_tag_classes} tag_tag'>" + tag['val'].gsub(/_/, " ") + "</span>"
      elsif tag['type'] == 'link' 
#        t =  tag['tag'].split("|")
#        if t.size == 2
        html = "<a href = '" + (tag['url'] || '') + "' title='" + (tag['url'] || '') + "' class='badge #{assertion_type.badge_tag_classes} #{assertion_type.badge_tag_classes}-link'>" + (tag['text'] || 'NA') + "</span></a>"
        #  html = "<a href = '" + (t[1] || '') + "'><span class='badge badge-tag #{assertion_type.badge_tag_classes} tag_tag'>" + (t[0] || 'NA') + "</span></a>"
        # end
      elsif tag['type'] == 'pmid'
        html = "<a href = 'https://pubmed.ncbi.nlm.nih.gov/" + (tag['val'] || '') + "' title='https://pubmed.ncbi.nlm.nih.gov/" + (tag['val'] || '') + "' class='badge #{assertion_type.badge_tag_classes}  #{assertion_type.badge_tag_classes}-link'>[Pubmed]</a>"
      elsif tag['type'] == 'doi'
        url = "https://doi.org/" + (tag['val'] || '')
         html = "<a href = '" + url + "' class='badge #{assertion_type.badge_tag_classes}  #{assertion_type.badge_tag_classes}-link'>[DOI link]</a>"
      end
    end
    return html
  end  

  def display_ref a  
    authors =  a.authors_txt.split(";")
    html = authors.first + ((authors.size > 1) ? '<i> et al.</i>' : '') + ", " + a.year.to_s
    return html
  end

  def display_date_short(c)
    n = Time.now
    html = "" #<table class='display_date'><tr><td class='day'>"                                                                                                                                                           
    if n.day == c.day and n.month == c.month and n.year == c.year
      html += "today"
    elsif n.day == c.day + 1 and n.month == c.month and n.year == c.year
      html += "yesterday"
    else
      html += "on #{c.year}-#{"0" if c.month < 10}#{c.month}-#{"0" if c.day < 10}#{c.day}"
    end
    #   html += "</td><td>"                                                                                                                                                                                                
    html += " #{"0" if c.hour < 10}#{c.hour}:#{"0" if c.min < 10}#{c.min}" #</td></tr></table>"                                                                                                                            
  end

  def display_rel_count(h_rels, rel_type_name, complement_id)
    html = ''
    if tmp_h = h_rels[:by_compl][rel_type_name] and tmp_h[complement_id]
      html = tmp_h[complement_id].size
    else
      html = '0'
    end
    return html
  end

end
