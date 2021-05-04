<!--
 * @Date: 2021.04.27 17:32:32
 * @LastEditors: Rustle Karl
 * @LastEditTime: 2021.05.04 13:33:50
-->

# FFmepg Generator Dart

[FFmepg Generator](https://github.com/fujiawei-dev/ffmpeg-generator) Dart language implementation, but only the core functions are implemented.

```dart
import 'package:ffmpeg_generator_dart/_ffmpeg.dart';

const input_file = '/path/to/input_file';

void main() {
  input(input_file, kwargs: {})
      .filter('flip', [], {})
      .output(
    ['output_file'],
    vn: true,
    start_position: 0,
    duration: 20,
    args: [],
    kwargs: {
      'stream_loop': 2,
    },
  )
      .compile();
}
```

```
ffmpeg -hwaccel cuda -vcodec h264_cuvid -i /path/to/input_file -filter_complex "[0]flip[tag0]" -stream_loop 2 -t 20.0 -vn -map [tag0] output_file -y -hide_banner
```
