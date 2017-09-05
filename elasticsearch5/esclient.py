import copy
import json
import time
import hashlib

from elasticsearch import Elasticsearch
from elasticsearch.client import IndicesClient
import elasticsearch.exceptions

# ES 5.x
types = {
    'int':           {'type': 'integer'},
    'int_NI':        {'type': 'integer', 'index': False},
    'long':          {'type': 'long'},
    'float':         {'type': 'float'},
    'float_NI':      {'type': 'float', 'index': False},
    'keyword':       {'type': 'keyword'},
    'text':          {'type': 'text'},
    'date_yyyyddmm': {'type': 'date',   'format': 'YYYY-MM-dd'},
    'time_hhmmss':   {'type': 'date',   'format': 'HH:mm:ss'},
    'datetime':      {'type': 'date',   'format': 'YYYY-MM-dd HH:mm:ss.SSSSSSZ||YYYY-MM-dd HH:mm:ss.SSSZ||YYYY-MM-dd HH:mm:ssZ||epoch_millis'},
    'ip':            {'type': 'ip'},
    'geo_point':     {'type': 'geo_point'},
}


def chunk_generator(iterable, chunk_size):
    chunk = []
    for item in iterable:
        chunk.append(item)
        if len(chunk) == chunk_size:
            yield chunk
            chunk = []
    
    if chunk:
        yield chunk


class EsClient:
    def __init__(self, server):
        self.client = Elasticsearch(server)
        self.indices_client = IndicesClient(self.client)
        self.existing_indexes = set()
    
    def delete_index(self, index):
        try:
            self.indices_client.delete(index)
        except:
            pass
    
    def index_exists(self, index):
        if index in self.existing_indexes:
            # I'm assuming the index doesn't get deleted at runtime
            return True
        
        try:
            if self.indices_client.exists(index):
                self.existing_indexes.add(index)
                return True
        except elasticsearch.exceptions.ConnectionError:
            return False
    
    def _create_index_data(self, mappings, shards, replicas, aliases, settings):
        data = {
            'settings': {
                'number_of_shards':   shards,
                'number_of_replicas': replicas
            },
            'mappings': mappings
        }
        
        if aliases:
            data['aliases'] = aliases
        
        if settings:
            data['settings'].update(settings)
        
        return data
    
    def create_index(
        self,
        index,
        mappings,
        shards,
        replicas=0,
        aliases=None,
        settings=None,
        max_n_try=3
    ):
        if self.index_exists(index):
            return 'exists'
        
        data = self._create_index_data(mappings, shards, replicas=replicas, aliases=aliases, settings=settings)
        
        for iter in range(max_n_try + 1):
            try:
                return self.indices_client.create(index=index, body=data)
            except Exception as e:
                if iter < max_n_try:
                    # Possibly a race condition with an other process
                    time.sleep(2)
                    
                    if self.index_exists(index):
                        return 'exists'
                else:
                    raise e
    
    def create_template(
        self,
        name,
        template,
        mappings,
        shards,
        replicas=0,
        aliases=None,
        settings=None
    ):
        if aliases:
            # Not needed yet, Kibana uses wildcards
            raise NotImplementedError
        
        data = self._create_index_data(mappings, shards, replicas=replicas, aliases=aliases, settings=settings)
        data['template'] = template
        
        self.indices_client.put_template(name, body=data)
    
    def count_query(self, index, query, t=1000):
        return self.client.count(index=index, body=query, request_timeout=t)['count']
    
    def get_query(self, index, query, t=1000, scroll=None):
        # "search" is faster than "scroll" but doesn't perform well on very large result sets (over 100k)
        if scroll == False or (scroll is None and self.count_query(index, query, t) < 90000):
            yield from self.client.search(index=index, body=query, request_timeout=t)['hits']['hits']
            return
        
        query = copy.deepcopy(query)
        query['size'] = 50000
        scroll_result = self.client.search(index=index, body=query, request_timeout=t, scroll='1m')
        n_yield = 0
        
        for doc in scroll_result['hits']['hits']:
            yield doc
            n_yield += 1
        
        if n_yield == scroll_result['hits']['total']:
            # Nothing to scroll
            return
        
        while n_yield < scroll_result['hits']['total']:
            scroll_result = self.client.scroll(body={'scroll': '1m', 'scroll_id': scroll_result['_scroll_id']}, request_timeout=t)
            
            if not scroll_result:
                return
            
            for doc in scroll_result['hits']['hits']:
                yield doc
                n_yield += 1
    
    def refresh(self, index):
        self.client.indices.refresh(index=index)
    
    def exists(self, index, type, id):
        raise NotImplementedError
    
    def upload_documents(
        self, index, type, docs_iterable,
        chunk_size=5000, id_field=None, index_field=None,
        id_from_json=False
    ):
        status = []
        
        fixed_index = isinstance(index, str)
        indexes = set()
        
        if fixed_index:
            indexes.add(index)
        
        for doc_chunk in chunk_generator(docs_iterable, chunk_size):
            data = []
            
            for doc in doc_chunk:
                doc = copy.deepcopy(doc)
                meta = {'_type':  type}
                
                if fixed_index:
                    meta['_index'] = index
                elif index_field:
                    meta['_index'] = doc[index_field]
                    del doc[index_field]
                else:
                    meta['_index'] = index(doc)
                
                if not fixed_index:
                    indexes.add(meta['_index'])
                
                if id_field is not None:
                    meta['_id'] = (
                        '%d' % int(doc[id_field]) if isinstance(doc[id_field], int) else doc[id_field]
                    )
                    del doc[id_field]
                    js = json.dumps(doc)
                else:
                    js = json.dumps(doc)
                    
                    if id_from_json:
                        meta['_id'] = hashlib.sha1(js).hexdigest()
                
                data.append(json.dumps({'index': meta}))
                data.append(js)
            
            data.append('')
            
            status += [i['index']['status'] for i in self.client.bulk(body='\n'.join(data))['items']]
        
        for index in indexes:
            self.refresh(index)
        
        return status