#!/usr/bin/env python3
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import requests

WHIMSY = 'https://whimsy.apache.org/public/public_ldap_people.json'

js = requests.get(WHIMSY).json()

out = "(no author) = dev-null@apache.org"
for person, info in sorted(js['people'].items()):
    out += "\n%s = %s <%s@apache.org>" % (person, info['name'], person)

with open("/x1/gitbox/htdocs/authors.txt", "w") as f:
    f.write(out)
    f.close()
