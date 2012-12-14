# fluent-plugin-delay-inspector

## DelayInspectorOutput

Fluentd plugin to inspect diff of real-time and log-time, and emit message as:

* new message with single key-value pair (DEFAULT)
* whole message with original attributes and injected delay information (with `reserve_data true`)

## Configuration

To get delay information only with specified tag `delayinfo` and key name `delay`(default):

    <match message.whatever.**>
      type delay_inspector
      tag  delayinfo
    </match>

Specify `remove_prefix` and/or `add_prefix` to get tags based on original tag:

    <match message.whatever.**>
      type delay_inspector
      remove_prefix message
      add_prefix    delayinfo        #=> get tags as: 'delayinfo.whatever.you.want'
    </match>

To add delay info into original messages with specified key name (and pass these to other plugins):

    <match raw.message.whatever.**>
      type delay_inspector
      remove_prefix raw
      key_name      delay_seconds
      reserve_data  yes
    </match>

## TODO

* patches welcome!

## Copyright

* Copyright
  * Copyright (c) 2012- TAGOMORI Satoshi (tagomoris)
* License
  * Apache License, Version 2.0
