# fluent-plugin-ua-parser

[Fluentd](http://fluentd.org) filter plugin to parse user-agent.


## Installation

```bash
# for fluentd
$ gem install fluent-plugin-ua-parser

# for td-agent2
$ sudo td-agent-gem install fluent-plugin-ua-parser
```


## Usage

### Example 1:

```xml
<filter access.nginx.**>
  @type ua_parser
</filter>
```

Assuming following inputs are coming:

```json
access.nginx: {
  "remote_addr":"10.20.30.40",
  "scheme":"http", "method":"GET", "host":"example.com",
  "path":"/", "query":"-", "req_bytes":200, "referer":"-",
  "status":200, "res_bytes":800, "res_body_bytes":600, "taken_time":0.001,
  "user_agent":"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36"
}
```

then output bocomes as belows:

```json
access.nginx: {
  "remote_addr":"10.20.30.40",
  "scheme":"http", "method":"GET", "host":"example.com",
  "path":"/", "query":"-", "req_bytes":200, "referer":"-",
  "status":200, "res_bytes":800, "res_body_bytes":600, "taken_time":0.001,
  "user_agent":"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36",
  "ua":{
    "browser":{
      "family":"Chrome",
      "version":"46.0.2490",
      "major_version":46
    },
    "os":{
      "family":"Windows 7",
      "version":""
    },
    "device":"Other"
  }
}
```

### Example 2:

```xml
<filter access.apache.**>
  @type ua_parser
  key_name ua_string
  delete_key yes
  out_prefix ua
  patterns_path /etc/td-agent/data/regexes.yaml
</filter>
```

Assuming following inputs are coming:

```json
access.apache: {
  "remote_addr":"10.20.30.40",
  "scheme":"http", "method":"GET", "host":"example.com",
  "path":"/", "query":"-", "req_bytes":200, "referer":"-",
  "status":200, "res_bytes":800, "res_body_bytes":600, "taken_time":0.001,
  "ua_string":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/601.2.7 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.7"
}
```

then output bocomes as belows:

```json
access.apache: {
  "remote_addr":"10.20.30.40",
  "scheme":"http", "method":"GET", "host":"example.com",
  "path":"/", "query":"-", "req_bytes":200, "referer":"-",
  "status":200, "res_bytes":800, "res_body_bytes":600, "taken_time":0.001,
  "ua":{
    "browser":{
      "family":"Safari",
      "version":"9.0.1",
      "major_version":9
    },
    "os":{
      "family":"Mac OS X",
      "version":"10.11.1",
      "major_version":10
    },
    "device":"Other"
  }
}
```



## Parameters
- key_name *field_key*

    Target key name. default user_agent.

- delete_key *bool*

    Delete input key. default false.

- out_prefix *string*

    Output prefix key name. default ua.

- patterns_path *file_path*

    Patterns file(regexes.yaml) path.
    Get from [uap-core](https://github.com/ua-parser/uap-core)


## TODO

* flatten option (join hashed data by '_')


## Contributing

1. Fork it ( https://github.com/bungoume/fluent-plugin-ua-parser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Copyright

Copyright (c) 2015 Yuri Umezaki


## License

Apache License, Version 2.0
