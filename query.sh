curl -G https://query.wikidata.org/sparql \
	--header "Accept: text/csv"  \
	--data-urlencode query='SELECT DISTINCT
  ?zeitung ?zeitungLabel ?popLabel ?pop ?nuts
  
  WHERE {
    ?zeitung wdt:P31/wdt:P279* wd:Q11032 , ?zeitungart . # /wdt:P279*
    ?zeitung wdt:P291 ?pop.
    ?pop p:P605 ?nutsStatement.
    # Get value from nuts stm
    ?nutsStatement ps:P605 ?nuts . # Dont change this, statement usage is important for later MINUS of endTime

    # Only daily and regional newspapers TODO remove daily in the future
    FILTER(?zeitungart in (wd:Q11032, wd:Q1110794, wd:Q2138556)).
    FILTER(strlen(?nuts) = 5 && STRSTARTS(?nuts, "DE")).

    # TODO this can be omitted
    ?nutsStatement p:P131* ?country.

    # Remove with dissolved date
    MINUS {
          ?zeitung p:P576 ?statement_0.
          ?statement_0 psv:P576 ?statementValue_0.
          ?statementValue_0 wikibase:timeValue ?P576_0.
      }
		  
    # Remove with einstellungs-date  
    MINUS {
      ?zeitung p:P2669 ?statement_1.
      ?statement_1 psv:P2669 ?statementValue_1.
      ?statementValue_1 wikibase:timeValue ?P2669_0.
    }
	
    # Remove with end time
    MINUS {
      ?zeitung p:P582 ?stmEndTime.
    }
    
    # Remove if country has dissolved date
    MINUS {
      ?zeitung wdt:P495 ?country2.
      ?country2 p:P576 ?stm2. 
    }
    
    # Remove not valid nuts references
    MINUS{ ?nutsStatement pq:P582 ?endtime.   }

    OPTIONAL {
      ?zeitung wdt:P127 ?owner
    }
    
    OPTIONAL {
      ?zeitung wdt:P123 ?verlag
    }
	
    SERVICE wikibase:label { bd:serviceParam wikibase:language "de,[AUTO_LANGUAGE]". }
  }'
