#!/usr/bin/env python3
import elasticsearch
import pyexcel_ods
import collections
import requests

# Elastic handler
es = elasticsearch.Elasticsearch([
        {'host': 'localhost', 'port': 9200, 'url_prefix': '', 'use_ssl': False},
])
        

# Make a "book" (an ODS file)
def makeBook(domain):
        book = collections.OrderedDict()
        
        # This is the global search. We'll adjust as needed
        query = {
            "query": {
                "bool": {
                    "must": [{
                            "query_string": {
                                "query": "vhost:\"%s\" AND document:*.html AND useragent:mozilla" % domain,
                                "analyze_wildcard": True
                            }
                        }, {
                            "range": {
                                "@timestamp": {
                                    "gte": "now-30d",
                                    "lte": "now",
                                    "format": "epoch_millis"
                                }
                            }
                        }
                    ],
                    "must_not": []
                }
            },
            "size": 0,
            "_source": {
                "excludes": []
            },
        }
        
        # Get unique IPs
        query['aggs'] = {
                "per_day": {
                    "date_histogram": {
                        "field": "@timestamp",
                        "interval": "1d",
                        "time_zone": "UTC",
                        "min_doc_count": 1
                    },
                    "aggs": {
                        "uniques": {
                            "cardinality": {
                                "field": "clientip.keyword"
                            }
                        }
                    }
                }
            }
        res = es.search(index='loggy-*', request_timeout=90, body = query)
        
        arr = [['Date', 'Unique visitors']]
        for el in res['aggregations']['per_day']['buckets']:
                d = el['key_as_string'].replace(' 00:00:00', '')
                c = el['uniques']['value']
                arr.append([d,c])
        book.update({'Unique visitors, past month': arr})
        
        
        
        # Get page views
        # We already have the data here, so no need for an additional query.
        res = es.search(index='loggy-*', request_timeout=90, body = query)
        
        arr = [['Date', 'Pageviews']]
        for el in res['aggregations']['per_day']['buckets']:
                d = el['key_as_string'].replace(' 00:00:00', '')
                c = el['doc_count']
                arr.append([d,c])
        book.update({'Pageviews, past month': arr})
        
        
        
        # Get most visited pages
        query["aggs"] = {
                "popular" : {
                        "terms" : {
                                "field" : "uri.keyword",
                                "size" : 50,
                                "order" : {"_count":"desc"}
                                }
                        }
                }
        res = es.search(index='loggy-*', request_timeout=90, body = query)
        
        arr = [['URI', 'Pageviews']]
        for el in res['aggregations']['popular']['buckets']:
                d = el['key']
                c = el['doc_count']
                arr.append([d,c])
        book.update({'Most visited pages, past month': arr})
        
        
        
        # Get top referrers
        query["aggs"] = {
                "refs" : {
                        "terms" : {
                                "field" : "referer.keyword",
                                "size" : 25,
                                "order" : {"_count":"desc"}
                                }
                        }
                }
        res = es.search(index='loggy-*', request_timeout=90, body = query)
        
        arr = [['Referrer', 'Pageviews']]
        for el in res['aggregations']['refs']['buckets']:
                d = el['key']
                c = el['doc_count']
                # We only use it if > 10 people have used it, so as to not divulge PII
                if c > 10 and d != '-':
                        arr.append([d,c])
        book.update({'Top referrers, past month': arr})
        
        
        
        # Geomapping
        # We need to weed out some things here
        query["query"]["bool"]["must_not"].append({"query_string": {"query": '(geo_country.keyword in ("EU", "AP", "A1", "A2", "SX", "SS", "-")) AND NOT geo_country.keyword:"-"'}})
        query["aggs"] = {
                "country" : {
                        "terms" : {
                                "field" : "geo_country.keyword",
                                "size" : 200,
                                "order" : {"_count":"desc"}
                                }
                        }
                }
        res = es.search(index='loggy-*', request_timeout=90, body = query)
        
        arr = [['Country', 'Pageviews']]
        for el in res['aggregations']['country']['buckets']:
                if el['key'] != '-':
                        d = el['key']
                        c = el['doc_count']
                        arr.append([d,c])
        book.update({'Geomapping, past month': arr})
        
        
        pyexcel_ods.save_data("/var/www/snappy/exports/%s.ods" % domain, book)


if __name__ == '__main__':
        # Get all projects, committees, podlings
        cmts = requests.get('https://whimsy.apache.org/public/committee-info.json').json()
        pods = requests.get('https://whimsy.apache.org/public/public_podlings.json').json()
        
        
        # Churn out a list of sub-domains to gather stats for
        subdomains = ['www.openoffice.org', 'openoffice.org', 'www.apache.org', 'apache.org']
        for k, cmt in cmts['committees'].items():
            if not '@' in cmt['mail_list']:
                subdomain = "%s.apache.org" % cmt['mail_list']
                subdomains.append(subdomain)
        
        for k, cmt in pods['podling'].items():
            subdomain = "%s.apache.org" % k
            if cmt['status'] == "current" and subdomain not in subdomains:
                subdomains.append(subdomain)
                
        for sdomain in sorted(subdomains):
                if sdomain:
                        print("Charting %s" % sdomain)
                        makeBook(sdomain)
        print("All done")
